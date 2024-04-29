//
//  ASDevice.m
//  Blustream
//
//  Created by Michael Gordon on 6/17/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevicePrivate.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "ASBatteryLevel.h"
#import "ASBLEInterface.h"
#import "ASCloudPrivate.h"
#import "ASConfig.h"
#import "ASContainer.h"
#import "ASDeviceManagerPrivate.h"
#import "ASDeviceAPIService.h"
#import "ASDeviceSyncManager.h"
#import "ASEnvironmentalMeasurement.h"
#import "ASErrorDefinitions.h"
#import "ASErrorState.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASPUTQueue.h"
#import "ASSystemManagerPrivate.h"
#import "MSWeakTimer.h"
#import "NSError+ASError.h"
#import "NSString+ASCompatibility.h"
#import "SWWTB+NSNotificationCenter+Addition.h"
#import "AFHTTPSessionManager.h"
#import "ASDateFormatter.h"
#import "ASUtils.h"
#import "MSWeakTimer.h"
#import "NSDictionary+ASStringToJSON.h"
#import "NSDate+ASRoundDate.h"

static NSString * const ASLastUpdateKey = @"LastUpdate";
static NSString * const ASUUIDKey = @"UUID";
static NSString * const ASAutoConnect = @"AutoConnect";
static NSString * const ASMeasurementInterval = @"MeasurementInterval";
static NSString * const ASAlertInterval = @"AlertInterval";
static NSString * const ASHardwareHumidAlarmMax = @"HardwareHumidAlarmMax";
static NSString * const ASHardwareHumidAlarmMin = @"HardwareHumidAlarmMin";
static NSString * const ASHardwareTempAlarmMax = @"HardwareTempAlarmMax";
static NSString * const ASHardwareTempAlarmMin = @"HardwareTempAlarmMin";

static NSString * const ASAccelEnabled = @"AccelEnabled";
static NSString * const ASAccelThreshold  = @"AccelThreshold";

static NSString * const ASSerialNumber  = @"SerialNumber";
static NSString * const ASHardwareRevision = @"HardwareRevision";
static NSString * const ASSoftwareRevision = @"SoftwareRevision";
static NSString * const ASLastSynced = @"LastSynced";
static NSString * const ASFullMetadata = @"FullMetadata";
static NSString * const ASSyncedForFirstTime = @"SyncedForFirstTime";

@implementation ASDevice

#pragma mark - Lifecycle

- (void)dealloc {
    // Remove observers when deallocating so messages don't get sent into the void
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    NSAssert(false, @"ASDevices can not be manually initialized");
    return nil;
}

- (instancetype)initWithSerialNumber:(NSString *)serialNumber {
    return [self initWithSerialNumber:serialNumber peripheral:nil];
}

- (instancetype)initWithSerialNumber:(NSString *)serialNumber peripheral:(CBPeripheral *)peripheral {
    NSParameterAssert(serialNumber);
    
    self = [super init];
    
    if (self) {
        _serialNumber = serialNumber;
        _lastUpdate = [NSDate date];
        _autoconnect = NO;
        _syncedForFirstTime = NO;
        _pendingOperations = [NSMutableArray new];
        
        if (peripheral) {
            // Real device
            _uuid = peripheral.identifier;
            _peripheral = peripheral;
        }
        [self queueInit];
    }
    return self;
}

- (instancetype)initInBootloaderModeWithPeripheral:(CBPeripheral *)peripheral {
    NSParameterAssert(peripheral);
    
    self = [super init];
    if (self) {
        _uuid = peripheral.identifier;
        _peripheral = peripheral;
        _connectionMode = ASDeviceConnectionModeOverTheAirUpdate;
        _pendingOperations = [NSMutableArray new];
        [self queueInit];
    }
    
    return self;
}

- (void)queueInit {
    // Note: These UUIDs don't match the containers because they are created before the container is loaded from the disk.
    NSString *uuidString = NSUUID.UUID.UUIDString;
    NSString *memberQueueName = [NSString stringWithFormat:@"com.acoustic-stream.device.member.%@", uuidString];
    NSString *processingQueueName = [NSString stringWithFormat:@"com.acoustic-stream.device.processing.%@", uuidString];
    
    _memberQueue = dispatch_queue_create([memberQueueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
    _processingQueue = dispatch_queue_create([processingQueueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    dispatch_barrier_sync(self.memberQueue, ^{
        [encoder encodeObject:self->_lastUpdate forKey:ASLastUpdateKey];
        [encoder encodeObject:self->_uuid forKey:ASUUIDKey];
        [encoder encodeObject:@(self->_autoconnect) forKey:ASAutoConnect];
        
        [encoder encodeObject:self->_measurementInterval forKey:ASMeasurementInterval];
        [encoder encodeObject:self->_alertInterval forKey:ASAlertInterval];
        [encoder encodeObject:self->_hardwareHumidAlarmMax forKey:ASHardwareHumidAlarmMax];
        [encoder encodeObject:self->_hardwareHumidAlarmMin forKey:ASHardwareHumidAlarmMin];
        [encoder encodeObject:self->_hardwareTempAlarmMax forKey:ASHardwareTempAlarmMax];
        [encoder encodeObject:self->_hardwareTempAlarmMin forKey:ASHardwareTempAlarmMin];
        [encoder encodeObject:@(self->_accelSetting) forKey:ASAccelEnabled];
        [encoder encodeObject:self->_accelThreshold forKey:ASAccelThreshold];
        
        [encoder encodeObject:self->_serialNumber forKey:ASSerialNumber];
        [encoder encodeObject:self->_hardwareRevision forKey:ASHardwareRevision];
        [encoder encodeObject:self->_softwareRevision forKey:ASSoftwareRevision];
        
        [encoder encodeObject:self->_lastSynced forKey:ASLastSynced];
        [encoder encodeObject:self->_fullMetadata forKey:ASFullMetadata];
        [encoder encodeObject:@(self->_syncedForFirstTime) forKey:ASSyncedForFirstTime];
    });
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    [self queueInit];
    
    if (self) {
        _pendingOperations = [NSMutableArray new];
        
        dispatch_barrier_sync(self.memberQueue, ^{
            self->_lastUpdate = [decoder decodeObjectForKey:ASLastUpdateKey];
            self->_uuid = [decoder decodeObjectForKey:ASUUIDKey];
            
            self->_autoconnect = [[decoder decodeObjectForKey:ASAutoConnect] boolValue];
            
            self->_measurementInterval = [decoder decodeObjectForKey:ASMeasurementInterval];
            self->_alertInterval = [decoder decodeObjectForKey:ASAlertInterval];
            
            self->_hardwareHumidAlarmMax = [decoder decodeObjectForKey:ASHardwareHumidAlarmMax];
            self->_hardwareHumidAlarmMin = [decoder decodeObjectForKey:ASHardwareHumidAlarmMin];
            self->_hardwareTempAlarmMax = [decoder decodeObjectForKey:ASHardwareTempAlarmMax];
            self->_hardwareTempAlarmMin = [decoder decodeObjectForKey:ASHardwareTempAlarmMin];
            self->_accelSetting = [[decoder decodeObjectForKey:ASAccelEnabled] unsignedIntegerValue];
            self->_accelThreshold = [decoder decodeObjectForKey:ASAccelThreshold];
            
            self->_serialNumber = [decoder decodeObjectForKey:ASSerialNumber];
            self->_hardwareRevision = [decoder decodeObjectForKey:ASHardwareRevision];
            self->_softwareRevision = [decoder decodeObjectForKey:ASSoftwareRevision];
            
            self->_fullMetadata = [decoder decodeObjectForKey:ASFullMetadata];
            self->_lastSynced = [decoder decodeObjectForKey:ASLastSynced];
            
            NSNumber *syncedForFirstTime = [decoder decodeObjectForKey:ASSyncedForFirstTime];
            if (syncedForFirstTime) {
                self->_syncedForFirstTime = syncedForFirstTime.boolValue;
            }
            else {
                self->_syncedForFirstTime = NO;
            }
        });
    }
    return self;
}

#pragma mark - Private Methods

- (void)updateRSSI {
    if (!self.peripheral) {
        return;
    }
    
    dispatch_async(self.processingQueue, ^{
        if (self.state == ASDeviceBLEStateConnected) {
            [self.peripheral readRSSI];
        }
    });
}

// Like the terminal command, this updates the lastUpdate date to now (doesn't create a file)
- (void)touch {
    _lastUpdate = [NSDate date];
}

- (void)unsafeSetAutoConnect:(BOOL)newAutoConnect {
    _autoconnect = newAutoConnect;
    
    if (newAutoConnect) {
        [ASSystemManager.shared.BLEInterface connectToDevice:self];
    }
    else {
        [ASSystemManager.shared.BLEInterface disconnectFromDevice:self];
    }
    
    ASDeviceManager *syncManager = [[ASDeviceManager alloc] initWithSystemManager:ASSystemManager.shared];
    [syncManager saveDevice:self];
}

#pragma mark - Public Methods

- (BOOL)setAutoConnect:(BOOL)newAutoConnect error:(NSError * __autoreleasing *)error {
    // Automatically connect/disconnect on device discovery
    // Send out notifications as well
    
    // Always allow setting auto connect to false
    if (!newAutoConnect) {
        [self unsafeSetAutoConnect:newAutoConnect];
        if (error) {
            *error = nil;
        }
        return YES;
    }
    
    NSError *errorCanAutoConnect = nil;
    if (![self canAutoConnectWithError:&errorCanAutoConnect]) {
        if (error) {
            *error = errorCanAutoConnect;
        }
        return NO;
    }
    
    [self unsafeSetAutoConnect:newAutoConnect];
    
    return YES;
}

- (BOOL)canAutoConnectWithError:(NSError * __autoreleasing *)error {
    if (self.connectionMode == ASDeviceConnectionModeOverTheAirUpdate) {
        return YES;
    }
    
    if (![self.serialNumber as_serialNumberIsCompatible]) {
        if (error) {
            *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorIncompatible underlyingError:nil];
        }
        
        return NO;
    }
    
    if (!self.container) {
        if (error) {
            *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorUnlinked underlyingError:nil];
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark Getters

- (ASDeviceBLEState)state {
    if (self.peripheral) {
        switch (self.peripheral.state) {
            case CBPeripheralStateDisconnected:
                return ASDeviceBLEStateDisconnected;
                break;
                
            case CBPeripheralStateConnecting:
                return ASDeviceBLEStateConnecting;
                break;
                
            case CBPeripheralStateConnected:
                return ASDeviceBLEStateConnected;
                break;
                
            default:
                return ASDeviceBLEStateDisconnected;
                break;
        }
    }
    else {
        return ASDeviceBLEStateDisconnected;
    }
}

- (ASDeviceType)type {
    if (!self.serialNumber) {
        return ASDeviceTypeUnknown;
    }
    
    NSString *serialNumberType = [self.serialNumber substringFromIndex:[self.serialNumber length] - 2];
    if ([serialNumberType caseInsensitiveCompare:@"10"] == NSOrderedSame) {
        return ASDeviceTypeTaylor;
    }
    
    if ([serialNumberType caseInsensitiveCompare:@"01"] == NSOrderedSame) {
        return ASDeviceTypeDAddario;
    }
    
    if ([serialNumberType caseInsensitiveCompare:@"02"] == NSOrderedSame) {
        return ASDeviceTypeTKL;
    }
    
    if ([serialNumberType caseInsensitiveCompare:@"42"] == NSOrderedSame) {
        return ASDeviceTypeBlustream;
    }
    
    if ([serialNumberType caseInsensitiveCompare:@"ff"] == NSOrderedSame) {
        return ASDeviceTypeSoftware;
    }
    
    if ([serialNumberType caseInsensitiveCompare:@"43"] == NSOrderedSame) {
        return ASDeviceTypeBoveda;
    }
    
    return ASDeviceTypeUnknown;
}

- (NSNumber *)getErrorByte {
    return self.container.errors.lastObject.state;
}

- (NSNumber *)advertisementBattery {
    return self.advertisedBatteryLevel.level;
}

- (NSNumber *)advertisementErrorState {
    return self.advertisedErrorState.state;
}

- (NSNumber *)advertisementHumidity {
    return self.advertisedEnvironmentalMeasurement.humidity;
}

- (NSNumber *)advertisementTemperature {
    return self.advertisedEnvironmentalMeasurement.temperature;
}

- (NSDictionary *)metadata {
    NSDictionary *metadata = _fullMetadata[[NSBundle mainBundle].bundleIdentifier];
    
    if ([metadata isKindOfClass:[NSNull class]]) {
        metadata = nil;
    }
    
    return metadata;
}

#pragma mark Setters

- (void)setSoftwareRevision:(NSString *)softwareRevision {
    if ([ASUtils detectChangeBetweenString:_softwareRevision string:softwareRevision]) {
        self.lastSynced = [[NSDate date] as_roundMillisecondsToThousands];
    }
    _softwareRevision = softwareRevision;
}

- (void)setHardwareRevision:(NSString *)hardwareRevision {
    if ([ASUtils detectChangeBetweenString:_hardwareRevision string:hardwareRevision]) {
        self.lastSynced = [[NSDate date] as_roundMillisecondsToThousands];
    }
    _hardwareRevision = hardwareRevision;
}

- (void)setRSSI:(NSNumber *)newRSSI {
    if ([newRSSI intValue] == 127) {
        _RSSI = nil;
    }
    else {
        _RSSI = newRSSI;
    }
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceRSSIUpdatedNotification object:self];
}

- (void)setContainer:(ASContainer *)container {
    _container = container;
    if (!_container) {
        [self setAutoConnect:NO error:nil];
    }
}

- (void)setMetadata:(NSDictionary *)metadata {
    NSMutableDictionary *mutableFullMetadata = [NSMutableDictionary dictionaryWithDictionary:_fullMetadata];
    [mutableFullMetadata setObject:(metadata ? [metadata copy] : [NSNull null]) forKey:[NSBundle mainBundle].bundleIdentifier];
    _fullMetadata = [NSDictionary dictionaryWithDictionary:mutableFullMetadata];
    
    self.lastSynced = [[NSDate date] as_roundMillisecondsToThousands];
}

#pragma mark - NSLog Method

- (NSString *)description {
    NSString *text = [NSString stringWithFormat:@"Serial Number: %@, Container: %@, ", self.serialNumber, self.container ? self.container.identifier : @"Not Linked"];
    text = [text stringByAppendingString:[NSString stringWithFormat:@"Last Updated: %@, AutoConnect: %d, RSSI: %@\n", self.lastUpdate, self.autoconnect, self.RSSI]];
    return text;
}

- (void)delayedSave {
    [self.saveTimer invalidate];
    
    ASDeviceManager *deviceManager = [[ASDeviceManager alloc] initWithSystemManager:ASSystemManager.shared];
    [deviceManager addDevice:self];
    self.saveTimer = [MSWeakTimer scheduledTimerWithTimeInterval:5 target:deviceManager selector:@selector(saveDevices) userInfo:nil repeats:NO dispatchQueue:self.processingQueue];
}

- (void)deleteLocalCache {
    dispatch_barrier_sync(self.memberQueue, ^{
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self getDataPath]];
        if (exists) {
            NSError *error;
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self getDataPath] error:&error];
            if (!success) {
                ASLog(@"Error deleting device (%@): %@", self.serialNumber, error);
            }
        }
    });
}

// Returns save path for data as an NSString
- (NSString *)getDataPath {
    NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
    NSString *filename = [docsPath stringByAppendingPathComponent:self.serialNumber];
    return filename;
}

@end
