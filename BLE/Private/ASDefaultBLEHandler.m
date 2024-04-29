//
//  ASBLEInterfaceDelegate.m
//  Blustream
//
//  Created by Michael Gordon on 7/10/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDefaultBLEHandler.h"

#import <UIKit/UIKit.h>

#import "ASAttribute.h"
#import "ASBLEDefinitions.h"
#import "ASCloudPrivate.h"
#import "ASConnectionEventPrivate.h"
#import "ASContainerPrivate.h"
#import "ASDevicePrivate.h"
#import "ASDevice+BLEUpdate.h"
#import "ASDeviceManagerPrivate.h"
#import "ASErrorDefinitions.h"
#import "ASHub.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASPUTQueue.h"
#import "ASRealtimeMode.h"
#import "ASRemoteNotificationManager.h"
#import "ASRoutineConglomerate.h"
#import "ASSystemManagerPrivate.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#import "ASDeviceInfoService.h"
#import "ASSoftwareRevisionCharacteristic.h"

#import "ASAdvertisementData.h"
#import "ASManufacturerData.h"
#import "ASEnvironmentalMeasurement.h"

@implementation ASDefaultBLEHandler

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _systemManager = systemManager;
    }
    
    return self;
}

#pragma mark - ASDeviceHandler Methods

- (void)didDiscoverDevice:(ASDevice *)device {
    ASLog(@"New device discovered: %@", device.serialNumber);
    [self.systemManager.deviceManager addDevice:device];
}

- (void)device:(ASDevice *)device advertisedWithData:(ASAdvertisementData *)advertisementData {
//    ASLog(@"Device advertised: %@", device.serialNumber);
    [device updateFromAdvertisementData:advertisementData];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceAdvertisedNotification object:device];
    
    if (device.autoconnect) {
        if (device.peripheral.state == CBPeripheralStateDisconnected) {
            [self.systemManager.BLEInterface connectToDevice:device];
        }
    }
}

- (void)didConnectToDevice:(ASDevice *)device {
    ASBLELog([NSString stringWithFormat:@"BLE flow: Serial Number: %@, Connected.", device.serialNumber]);
    
    if (!device.container) {
        ASBLELog([NSString stringWithFormat:@"BLE flow: Error: Device (%@) is unlinked but connected.  Disconnecting now.", device.serialNumber]);
        [device setAutoConnect:NO error:nil];
        return;
    }
    
    [device.peripheral readRSSI];
    
    // Automatically discover services for any newly connected device
    ASLog([NSString stringWithFormat:@"Discovering services for %@", device.serialNumber]);
    
    NSArray *services = [ASRoutineConglomerate allServices];
    [device.peripheral discoverServices:services];
    
    if (device.container) {
        ASHub *hub = self.systemManager.cloud.remoteNotificationManager.currentHub;
        ASConnectionEvent *connectionEvent = [[ASConnectionEvent alloc] initWithDate:[NSDate date] ingestionDate:nil hubIdentifier:hub.identifier type:ASConnectionEventTypeConnected reason:ASConnectionEventReasonNormal];
        [device.container addNewConnectionEvent:connectionEvent];
    }
    
    device.lastConnectedDate = [NSDate date];
    
    // Broadcast notification
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceConnectedNotification object:device];
}

- (void)didDisconnectFromDevice:(ASDevice *)device error:(NSError *)error {
    ASBLELog([NSString stringWithFormat:@"BLE flow: Serial Number: %@, Disconnected. Error: %@.", device.serialNumber, error.localizedDescription]);
    
    for (id<ASService> service in device.services.allValues) {
        for (id<ASCharacteristic> characteristic in service.characteristics.allValues) {
            [characteristic didDisconnectWithError:error];
        }
    }
    
    // If device should autoconnect, go ahead and reconnect, else remove it from discovered devices
    if (device.autoconnect) {
        [self.systemManager.BLEInterface connectToDevice:device];
    }
    
    if (device.container) {
        ASHub *hub = self.systemManager.cloud.remoteNotificationManager.currentHub;
        ASConnectionEventReason reason = ASConnectionEventReasonNormal;
        if (error) {
            reason = ASConnectionEventReasonError;
        }
        ASConnectionEvent *connectionEvent = [[ASConnectionEvent alloc] initWithDate:[NSDate date] ingestionDate:nil hubIdentifier:hub.identifier type:ASConnectionEventTypeDisconnected reason:reason];
        [device.container addNewConnectionEvent:connectionEvent];
    }
    
    // Broadcast notification
    if (!error) {
        error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorUserInitiatedDisconnected underlyingError:error];
    }
    else if (([error.domain compare:CBErrorDomain] == NSOrderedSame) && (error.code == CBErrorPeripheralDisconnected)) {
        error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorDeviceInitiatedDisconnect underlyingError:error];
    }
    else {
        error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorUnknown underlyingError:error];
    }
    
    device.lastDisconnectedDate = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceDisconnectedNotification object:device userObject:(error ? @{@"error":error} : nil)];
}

- (void)didFailToConnectToDevice:(ASDevice *)device error:(NSError *)error {
    ASBLELog([NSString stringWithFormat:@"BLE flow: Failed connecting to %@ (error: %@)", device.serialNumber, error.localizedDescription]);
    
    if (error) {
        error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorUnknown underlyingError:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceConnectFailedNotification object:device userObject:@{@"error":error}];
    
    // Try to connect again
    if (device.autoconnect) {
        [self.systemManager.BLEInterface connectToDevice:device];
    }
}

- (void)device:(ASDevice *)device didDiscoverServicesWithError:(NSError *)error {
    if (!device.container) {
        ASBLELog([NSString stringWithFormat:@"BLE flow: Error: Device (%@) is unlinked but connected.  Disconnecting now.", device.serialNumber]);
        [device setAutoConnect:NO error:nil];
        return;
    }
    
    // TODO handle error situations
    
    if (error) {
        ASBLELog([NSString stringWithFormat:@"BLE flow: Failed discovering services of %@ (error: %@)", device.serialNumber, error.localizedDescription]);
        
        return;
    }
    
    if (device.peripheral.services.count == 0) {
        ASBLELog([NSString stringWithFormat:@"BLE flow: Error: No services found on %@", device.serialNumber]);
        
        return;
    }
    
    // Automatically discover characteristics for any new service
    ASBLELog([NSString stringWithFormat:@"BLE flow: Discovering characteristics for %@", device.serialNumber]);
    
    for (CBService *service in device.peripheral.services) {
        NSArray *characteristics = [ASRoutineConglomerate allCharacteristicsForService:service.UUID.UUIDString];
        [device.peripheral discoverCharacteristics:characteristics forService:service];
    }
}

- (void)device:(ASDevice *)device didDiscoverCharacteristicsForService:(id<ASService>)service error:(NSError *)error {
    if (!device.container) {
        ASBLELog([NSString stringWithFormat:@"BLE flow: Error: Device (%@) is unlinked but connected.  Disconnecting now.", device.serialNumber]);
        [device setAutoConnect:NO error:nil];
        
        return;
    }
    
    if (error) {
        ASBLELog([NSString stringWithFormat:@"BLE flow: Failed discovering characteristics of %@ for service %@ (error: %@)", device.serialNumber, [[service class] identifier], error.localizedDescription]);
        
        return;
    }
    
    if (service.characteristics.count == 0) {
        ASBLELog([NSString stringWithFormat:@"BLE flow: No characteristics found on %@ for service %@", device.serialNumber, [[service class] identifier]]);
        
        return;
    }
    
    // Check to make sure characteristics have all been discovered
    
    BOOL characteristicsSetup = YES;
    
    for (CBService *discoveredService in device.peripheral.services) {
        if (!discoveredService.characteristics || (discoveredService.characteristics.count == 0)) {
            characteristicsSetup = NO;
        }
    }
    
    if (characteristicsSetup) {
        ASDeviceInfoService *deviceInfoService = device.services[[ASDeviceInfoService identifier].lowercaseString];
        ASSoftwareRevisionCharacteristic *characteristic = deviceInfoService.softwareRevisionCharacteristic;
        [characteristic readWithCompletion:^(NSError *error) {
            if (error) {
                [[ASRoutineConglomerate connectionRoutineForDevice:device] device:device didFailToSetup:error];
                return;
            }
            
            ASBLEResult<NSString *> *result = [characteristic process];
            if (result.error) {
                [[ASRoutineConglomerate connectionRoutineForDevice:device] device:device didFailToSetup:error];
                return;
            }
            
            device.softwareRevision = result.value;
            ASLog(@"Device: %@ - %@", device.serialNumber, device.softwareRevision);
            #warning connectionRoutineForDevice may return nil here
            [[ASRoutineConglomerate connectionRoutineForDevice:device] didFinishSetupForDevice:device];
        }];
    }
}

- (void)device:(ASDevice *)device didUpdateValueForCharacteristic:(id<ASUpdatableCharacteristic>)characteristic error:(NSError *)error {
    if (!device.container) {
        ASLog(@"Error: Device (%@) is unlinked but connected.  Disconnecting now.", device.serialNumber);
        [device setAutoConnect:NO error:nil];
        return;
    }
    
    [characteristic didReadDataWithError:error];
    
    [device.container delayedSave];
    [device delayedSave];
    [self.systemManager.cloud.PUTQueue delayedFire];
}

- (void)device:(ASDevice *)device didWriteValueForCharacteristic:(id<ASWriteableCharacteristic>)characteristic error:(NSError *)error {
    if (!device.container) {
        ASLog(@"Error: Device (%@) is unlinked but connected.  Disconnecting now.", device.serialNumber);
        [device setAutoConnect:NO error:nil];
        return;
    }
    
    [characteristic didCompleteWriteWithError:error];
    
    [device.container delayedSave];
    [device delayedSave];
    [self.systemManager.cloud.PUTQueue delayedFire];
}

- (void)device:(ASDevice *)device didUpdateNotificationStateForCharacteristic:(id<ASNotifiableCharacteristic>)characteristic error:(NSError *)error {
    if (!device.container) {
        ASLog(@"Error: Device (%@) is unlinked but connected.  Disconnecting now.", device.serialNumber);
        [device setAutoConnect:NO error:nil];
        return;
    }
    
    ASBLELog([NSString stringWithFormat:@"BLE flow: Serial Number: %@, Did update notification state for characteristic: %@, error: %@", device.serialNumber, [characteristic class], error.description]);
    
    [characteristic didSetNotifyWithError:error];
}

- (void)device:(ASDevice *)device didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    device.RSSI = RSSI;
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceRSSIUpdatedNotification object:device];
}

@end
