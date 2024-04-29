//
//  ASOverTheAirUpdateModeHandler.m
//  Blustream
//
//  Created by Michael Gordon on 10/7/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASOverTheAirUpdateModeHandler.h"

#import "ASAttribute.h"
#import "ASBLEDefinitions.h"
#import "ASCloudPrivate.h"
#import "ASConnectionEventPrivate.h"
#import "ASContainerPrivate.h"
#import "ASDevicePrivate.h"
#import "ASDevice+BLEUpdate.h"
#import "ASDevice+OTAUPrivate.h"
#import "ASDeviceManagerPrivate.h"
#import "ASErrorDefinitions.h"
#import "ASHub.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASOverTheAirUpdateConnectionRoutine.h"
#import "ASRemoteNotificationManager.h"
#import "ASSystemManagerPrivate.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

@implementation ASOverTheAirUpdateModeHandler

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    return [super initWithSystemManager:systemManager];
}

- (void)didDiscoverDevice:(ASDevice *)device {
    if (device.serialNumber) {
        [super didDiscoverDevice:device];
    }
    else {
        ASLog(@"New stuck device discovered");
        [self.systemManager.deviceManager addStuckDevice:device];
    }
}

- (void)didConnectToDevice:(ASDevice *)device {
    ASLog(@"Connected to %@ in OTAU mode", device.serialNumber);
    
    [device.peripheral readRSSI];
    
    // Automatically discover services for any newly connected device
    ASLog(@"Discovering services for %@ in OTAU mode", device.serialNumber);
    
    NSArray *services = [ASOverTheAirUpdateConnectionRoutine supportedServices];
    [device.peripheral discoverServices:services];
    
    if (device.container) {
        ASHub *hub = self.systemManager.cloud.remoteNotificationManager.currentHub;
        ASConnectionEvent *connectionEvent = [[ASConnectionEvent alloc] initWithDate:[NSDate date] ingestionDate:nil hubIdentifier:hub.identifier type:ASConnectionEventTypeConnected reason:ASConnectionEventReasonOTAUStarting];
        [device.container addNewConnectionEvent:connectionEvent];
    }
    
    device.lastConnectedDate = [NSDate date];
    
    // Broadcast notification
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceConnectedNotification object:device];
}

- (void)didDisconnectFromDevice:(ASDevice *)device error:(NSError *)error {
    ASLog(@"Disconnected from %@ (%@) in OTAU mode", device.serialNumber, error.localizedDescription);

    for (id<ASService> service in device.services.allValues) {
        for (id<ASCharacteristic> characteristic in service.characteristics.allValues) {
            [characteristic didDisconnectWithError:error];
        }
    }
    
    if (device.container) {
        ASHub *hub = self.systemManager.cloud.remoteNotificationManager.currentHub;
        ASConnectionEventReason reason = ASConnectionEventReasonNormal;
        if (device.shouldReconnect) {
            reason = ASConnectionEventReasonOTAUStarting;
        }
        else if (error) {
            reason = ASConnectionEventReasonError;
        }
        ASConnectionEvent *connectionEvent = [[ASConnectionEvent alloc] initWithDate:[NSDate date] ingestionDate:nil hubIdentifier:hub.identifier type:ASConnectionEventTypeDisconnected reason:reason];
        [device.container addNewConnectionEvent:connectionEvent];
    }
    
    if (device.shouldReconnect) {
        [self.systemManager.BLEInterface connectToDevice:device mode:device.connectionMode];
        
        return;
    }
    
    if (!error) {
        error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorUserInitiatedDisconnected underlyingError:error];
    }
    else if (([error.domain compare:CBErrorDomain] == NSOrderedSame) && (error.code == CBErrorPeripheralDisconnected)) {
        error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorDeviceInitiatedDisconnect underlyingError:error];
    }
    else {
        error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorUnknown underlyingError:error];
    }
    
    
    [self deviceOTAUDidFail:device error:error];
    
    device.lastDisconnectedDate = [NSDate date];
    
    // Broadcast notification
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceDisconnectedNotification object:device];
}

- (void)didFailToConnectToDevice:(ASDevice *)device error:(NSError *)error {
    ASLog(@"Failed connecting to %@ (%@) in OTAU mode", device.serialNumber, error.localizedDescription);
    
    device.connectionMode = ASDeviceConnectionModeDefault;
    
    NSError *ASError = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorUnknown underlyingError:error];
    [self deviceOTAUDidFail:device error:ASError];
}

- (void)device:(ASDevice *)device didDiscoverServicesWithError:(NSError *)error {
    if (error) {
        ASLog(@"Failed discovering services of %@ (%@) in OTAU mode", device.serialNumber, error.localizedDescription);
        NSError *ASError = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorServiceError underlyingError:error];
        [self deviceOTAUDidFail:device error:ASError];
        
        return;
    }
    
    if (device.peripheral.services.count == 0) {
        ASLog(@"Error: No services found on %@ in OTAU mode", device.serialNumber);
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorServicesMissing underlyingError:nil];
        [self deviceOTAUDidFail:device error:error];
        
        return;
    }
    
    for (CBService *service in device.peripheral.services) {
        NSArray *characteristics = [ASOverTheAirUpdateConnectionRoutine supportedCharacteristicsForService:service.UUID.UUIDString];
        [device.peripheral discoverCharacteristics:characteristics forService:service];
    }
}

- (void)device:(ASDevice *)device didDiscoverCharacteristicsForService:(id<ASService>)service error:(NSError *)error {
    ASLog(@"Discovered characteristic for %@ in OTAU mode", device.serialNumber);
    if (error) {
        ASLog(@"Failed discovering characteristics of %@ for service %@ (%@) in OTAU mode", device.serialNumber, [[service class] identifier], error.localizedDescription);
        NSError *ASError = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicError underlyingError:error];
        [self deviceOTAUDidFail:device error:ASError];
        
        return;
    }
    
    if (service.characteristics.count == 0) {
        ASLog(@"No characteristics found on %@ for service %@ in OTAU mode", device.serialNumber, [[service class] identifier]);
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicsMissing underlyingError:nil];
        [self deviceOTAUDidFail:device error:error];
        
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
        [ASOverTheAirUpdateConnectionRoutine didFinishSetupForDevice:device];
    }
}

- (void)device:(ASDevice *)device didUpdateValueForCharacteristic:(id<ASUpdatableCharacteristic>)characteristic error:(NSError *)error {
    [characteristic didReadDataWithError:error];
}

- (void)device:(ASDevice *)device didWriteValueForCharacteristic:(id<ASWriteableCharacteristic>)characteristic error:(NSError *)error {
    [characteristic didCompleteWriteWithError:error];
}

- (void)device:(ASDevice *)device didUpdateNotificationStateForCharacteristic:(id<ASNotifiableCharacteristic>)characteristic error:(NSError *)error {
    ASBLELog([NSString stringWithFormat:@"BLE flow: Serial Number: %@, Did update notification state for characteristic: %@, error: %@", device.serialNumber, [characteristic class], error.description]);
    [characteristic didSetNotifyWithError:error];
}

- (void)deviceOTAUDidFail:(ASDevice *)device error:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceOTAUModeFailed" object:device userInfo:error ? @{@"error":error} : nil];
}

@end
