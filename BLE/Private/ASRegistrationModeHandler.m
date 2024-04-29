//
//  ASRegistrationModeHandler.m
//  Blustream
//
//  Created by Michael Gordon on 7/10/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASRegistrationModeHandler.h"

#import "ASAttribute.h"
#import "ASBLEDefinitions.h"
#import "ASBLEInterface.h"
#import "ASBLEResult.h"
#import "ASDevicePrivate.h"
#import "ASDevice+BLEUpdate.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASRegistrationConnectionRoutine.h"
#import "ASSystemManagerPrivate.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#import "ASDeviceInfoService.h"
#import "ASSoftwareRevisionCharacteristic.h"

@implementation ASRegistrationModeHandler

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    return [super initWithSystemManager:systemManager];
}

- (void)didConnectToDevice:(ASDevice *)device {
    ASLog(@"Connected to %@ in registration mode", device.serialNumber);
    
    [device.peripheral readRSSI];
    
    // Automatically discover services for any newly connected device
    ASLog(@"Discovering services for %@ in registration mode", device.serialNumber);
    
    NSArray *services = [ASRegistrationConnectionRoutine supportedServices];
    [device.peripheral discoverServices:services];
}

- (void)didDisconnectFromDevice:(ASDevice *)device error:(NSError *)error {
    ASLog(@"Disconnected from %@ (%@) in registration mode", device.serialNumber, error.localizedDescription);
    
    device.connectionMode = ASDeviceConnectionModeDefault;
    
    if (!error) {
        error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorUserInitiatedDisconnected underlyingError:error];
    }
    else if (([error.domain compare:CBErrorDomain] == NSOrderedSame) && (error.code == CBErrorPeripheralDisconnected)) {
        error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorDeviceInitiatedDisconnect underlyingError:error];
    }
    
    NSError *ASError = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorDeviceConnectionFailed underlyingError:error];
    [self deviceRegistrationDidFail:device error:ASError];
}

- (void)didFailToConnectToDevice:(ASDevice *)device error:(NSError *)error {
    ASLog(@"Failed connecting to %@ (%@) in registration mode", device.serialNumber, error.localizedDescription);
    
    device.connectionMode = ASDeviceConnectionModeDefault;
    
    NSError *ASError = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorDeviceConnectionFailed underlyingError:error];
    [self deviceRegistrationDidFail:device error:ASError];
}

- (void)device:(ASDevice *)device didDiscoverServicesWithError:(NSError *)error {
    if (error) {
        ASLog(@"Failed discovering services of %@ (%@) in registration mode", device.serialNumber, error.localizedDescription);
        NSError *ASError = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorServiceError underlyingError:error];
        [self deviceRegistrationDidFail:device error:ASError];
        return;
    }
    
    if (device.peripheral.services.count == 0) {
        ASLog(@"Error: No services found on %@ in registration mode", device.serialNumber);
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorServicesMissing underlyingError:nil];
        [self deviceRegistrationDidFail:device error:error];
        return;
    }
    
    for (CBService *service in device.peripheral.services) {
        NSArray *characteristics = [ASRegistrationConnectionRoutine supportedCharacteristicsForService:service.UUID.UUIDString];
        [device.peripheral discoverCharacteristics:characteristics forService:service];
    }
}

- (void)device:(ASDevice *)device didDiscoverCharacteristicsForService:(id<ASService>)service error:(NSError *)error {
    ASLog(@"Discovered characteristic for %@ in registration mode", device.serialNumber);
    if (error) {
        ASLog(@"Failed discovering characteristics of %@ for service %@ (%@) in registration mode", device.serialNumber, [[service class] identifier], error.localizedDescription);
        NSError *ASError = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicError underlyingError:error];
        [self deviceRegistrationDidFail:device error:ASError];
        return;
    }
    
    if (service.characteristics.count == 0) {
        ASLog(@"No characteristics found on %@ for service %@ in registration mode", device.serialNumber, [[service class] identifier]);
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicsMissing underlyingError:nil];
        [self deviceRegistrationDidFail:device error:error];
        return;
    }
    
    BOOL characteristicsSetup = YES;
    
    for (CBService *discoveredService in device.peripheral.services) {
        if (!discoveredService.characteristics || (discoveredService.characteristics.count == 0)) {
            characteristicsSetup = NO;
        }
    }
    
    if (characteristicsSetup) {
        ASDeviceInfoService *deviceInfoService = device.services[[ASDeviceInfoService identifier].lowercaseString];
        ASSoftwareRevisionCharacteristic *softwareRevisionCharacteristic = deviceInfoService.softwareRevisionCharacteristic;
        [softwareRevisionCharacteristic readWithCompletion:^(NSError *error) {
            if (error) {
                [softwareRevisionCharacteristic sendNotificationWithError:error];
                [ASRegistrationConnectionRoutine device:device didFailToSetup:error];
                return;
            }
            
            ASBLEResult<NSString *> *result = [softwareRevisionCharacteristic process];
            if (result.error) {
                [softwareRevisionCharacteristic sendNotificationWithError:result.error];
                [ASRegistrationConnectionRoutine device:device didFailToSetup:result.error];
                return;
            }
            
            device.softwareRevision = result.value;
            [softwareRevisionCharacteristic sendNotificationWithError:error];
            [ASRegistrationConnectionRoutine didFinishSetupForDevice:device];
        }];
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

- (void)deviceRegistrationDidFail:(ASDevice *)device error:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceRegistrationModeFailed" object:device userInfo:error ? @{@"error":error} : nil];
}

@end
