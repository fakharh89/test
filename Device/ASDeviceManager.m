//
//  ASDeviceManager.m
//  Blustream
//
//  Created by Michael Gordon on 6/26/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDeviceManagerPrivate.h"

#import "ASBLEInterface.h"
#import "ASContainer.h"
#import "ASDevicePrivate.h"
#import "ASDeviceSyncManager.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASSystemManagerPrivate.h"
#import "NSArray+ASSearch.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#import <CoreBluetooth/CoreBluetooth.h>

dispatch_queue_t device_manager_member_queue() {
    static dispatch_queue_t as_device_manager_member_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        as_device_manager_member_queue = dispatch_queue_create("com.acoustic-stream.device-manager.member", DISPATCH_QUEUE_CONCURRENT);
    });
    return as_device_manager_member_queue;
}

dispatch_queue_t device_save_queue() {
    static dispatch_queue_t as_device_save_queue;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        as_device_save_queue = dispatch_queue_create("com.acoustic-stream.device.save", DISPATCH_QUEUE_SERIAL);
    });
    
    return as_device_save_queue;
}

@interface ASDeviceManager ()

@property (nonatomic, weak) ASSystemManager *systemManager;

@end

@implementation ASDeviceManager

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _systemManager = systemManager;
        _devicesInternal = [NSMutableArray new];
        _stuckDevicesInternal = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Public Methods


- (NSArray *)autoConnectingDevices {
    return [self.devices arrayWithAutoConnectingDevices];
}

- (NSArray *)autoConnectingAndConnectedDevices {
    return [self.devices arrayWithAutoConnectingAndConnectedDevices];
}

- (NSArray *)linkedDevices {
    return [self.devices arrayWithLinkedDevices];
}

- (NSArray *)unlinkedDevices {
    return [self.devices arrayWithUnlinkedDevices];
}

- (NSArray *)devices {
    __block NSArray *array;
    dispatch_sync(device_manager_member_queue(), ^{
        array = [NSArray arrayWithArray:self->_devicesInternal];
    });
    return array;
}

- (NSArray *)stuckDevices {
    __block NSArray *array;
    dispatch_sync(device_manager_member_queue(), ^{
        array = [NSArray arrayWithArray:self->_stuckDevicesInternal];
    });
    return array;
}

- (void)addDevice:(ASDevice *)device {
    if (device) {
        dispatch_barrier_sync(device_manager_member_queue(), ^{
            [self->_devicesInternal addObject:device];
        });
    }
}

- (void)cleanDeviceArray {
    dispatch_barrier_sync(device_manager_member_queue(), ^{
        NSMutableArray *mutabledevices = [[NSMutableArray alloc] init];
        for (ASDevice *device in self->_devicesInternal) {
            if (device.container) {
                [mutabledevices addObject:device];
            }
            else {
                if (device.state != ASDeviceBLEStateDisconnected) {
                    [self.systemManager.BLEInterface disconnectFromDevice:device];
                }
                [device deleteLocalCache];
                // Don't set delegate to nil - these delegate methods can still happen
                //            device.peripheral.delegate = nil;
            }
        }
        self->_devicesInternal = mutabledevices;
        [self saveDevices];
    });
}

- (void)addStuckDevice:(ASDevice *)device {
    NSParameterAssert(device);
    dispatch_barrier_sync(device_manager_member_queue(), ^{
        [self->_stuckDevicesInternal addObject:device];
    });
}

- (void)removeStuckDevice:(ASDevice *)device {
    NSParameterAssert(device);
    dispatch_barrier_sync(device_manager_member_queue(), ^{
        [self->_stuckDevicesInternal removeObject:device];
    });
}

- (BOOL)isScanning {
    return self.systemManager.BLEInterface.isScanning;
}

- (ASBluetoothState)bluetoothState {
    ASBluetoothState state = ASBluetoothStateUnknown;
    
    switch (self.systemManager.BLEInterface.centralManager.state) {
        case CBManagerStateUnknown: {
            state = ASBluetoothStateUnknown;
            break;
        }
        case CBManagerStateResetting: {
            state = ASBluetoothStateResetting;
            break;
        }
        case CBManagerStateUnsupported: {
            state = ASBluetoothStateUnsupported;
            break;
        }
        case CBManagerStateUnauthorized: {
            state = ASBluetoothStateUnauthorized;
            break;
        }
        case CBManagerStatePoweredOff: {
            state = ASBluetoothStatePoweredOff;
            break;
        }
        case CBManagerStatePoweredOn: {
            state = ASBluetoothStatePoweredOn;
            break;
        }
    }
    
    return state;
}

- (void)startScanning {
    [self.systemManager.BLEInterface startScanningForDevices];
}

- (void)stopScanning {
    [self.systemManager.BLEInterface stopScanningForDevices];
}

#pragma mark - Private Methods

- (void)resetDevices {
    dispatch_barrier_sync(device_manager_member_queue(), ^{
        for (ASDevice *device in self->_devicesInternal) {
            [device deleteLocalCache];
        }
        self->_devicesInternal = [[NSMutableArray alloc] init];
        [self saveDevices];
    });
}

// Loads devices from predetermined path
- (void)loadDevices {
    NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithFile:[self deviceSerialNumbersPath]];
    
    if (data) {
        NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
        NSMutableArray *mutableDevices = [[NSMutableArray alloc] init];
        for (NSString *deviceSerialNumber in data) {
            NSString *filename = [docsPath stringByAppendingPathComponent:deviceSerialNumber];
            ASDevice *device = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
            
            if (device) {
                [mutableDevices addObject:device];
            }
            else {
                ASLog(@"Failed to load device: %@", deviceSerialNumber);
            }
        }
        _devicesInternal = mutableDevices;
    }
    else {
        ASLog(@"Failed to load device serial numbers!");
    }
}

// Saves autoconnect devices to predetermined path
- (void)saveDevices {
    dispatch_async(device_manager_member_queue(), ^{
        NSMutableArray *deviceSerialNumbers = [[NSMutableArray alloc] init];
        for (ASDevice *device in self->_devicesInternal) {
            [deviceSerialNumbers addObject:device.serialNumber];
            [self saveDevice:device];
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:deviceSerialNumbers]];
        if (![data writeToFile:[self deviceSerialNumbersPath] atomically:YES]) {
            ASLog(@"Failed to save device serial numbers!");
        }
        
        // Set folder to not backup to iCloud.  Writing erases this attribute
        [ASSystemManager addSkipBackupAttributeToItemAtPath:[self deviceSerialNumbersPath]];
    });
}

- (void)saveDevice:(ASDevice *)device {
    dispatch_sync(device_save_queue(), ^{
        if (!device) {
            return;
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:device];
        
        if (![data writeToFile:[self serialNumberPathForDevice:device] atomically:YES]) {
            ASLog(@"Failed to save device %@!", device.serialNumber);
        }
        
        // Set folder to not backup to iCloud.  Writing erases this attribute
        [ASSystemManager addSkipBackupAttributeToItemAtPath:[self serialNumberPathForDevice:device]];
        
    });
}

// Returns save path for data as an NSString
- (NSString *)deviceSerialNumbersPath {
    NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
    NSString *filename = [docsPath stringByAppendingPathComponent:@"DeviceSerialNumbers"];
    return filename;
}

- (NSString *)serialNumberPathForDevice:(ASDevice *)path {
    NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
    NSString *filename = [docsPath stringByAppendingPathComponent:path.serialNumber];
    return filename;
}

@end
