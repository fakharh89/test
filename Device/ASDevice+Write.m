//
//  ASDevice+Write.m
//  Blustream
//
//  Created by Michael Gordon on 2/4/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice+Write.h"

#import "ASConfig.h"
#import "ASAlarmLimits.h"
#import "ASAttribute.h"
#import "ASServiceV1.h"
#import "ASDevicePrivate.h"
#import "ASServiceV3.h"
#import "ASServiceV4.h"
#import "ASEnvironmentalMeasurementIntervalCharacteristicV3.h"
#import "ASEnvironmentalMeasurementIntervalCharacteristic.h"
#import "ASSystemManager.h"
#import "ASErrorDefinitions.h"
#import "NSError+ASError.h"
#import "ASEnvironmentalAlarmLimitsCharacteristic.h"
#import "ASEnvironmentalAlertIntervalCharacteristic.h"
#import "ASAccelerometerModeCharacteristicV3.h"
#import "ASImpactThresholdCharacteristic.h"
#import "ASImpactThresholdCharacteristicV3.h"
#import "ASPIOCharacteristic.h"
#import "ASWritePendingOperation.h"
#import "ASBlinkCharacteristic.h"
#import "ASBlinkCharacteristicV3.h"
#import "ASEnvironmentalRealtimeModeCharacteristic.h"
#import "ASEnvironmentalBufferCharacteristic.h"
#import "ASLog.h"

@implementation ASDevice (Write)

- (void)writeEnvironmentalMeasurementInterval:(NSNumber *)interval completion:(void (^)(NSError *error))completion {
    NSParameterAssert(interval);

    NSString *characteristicString = nil;
    NSString *serviceString = nil;

    if ([@"4.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        serviceString = [ASServiceV4 identifier];
        characteristicString = [ASEnvironmentalMeasurementIntervalCharacteristicV3 identifier];
    }
    else if ([@"3.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        serviceString = [ASServiceV3 identifier];
        characteristicString = [ASEnvironmentalMeasurementIntervalCharacteristicV3 identifier];
    }
    else {
        serviceString = [ASServiceV1 identifier];
        characteristicString = [ASEnvironmentalMeasurementIntervalCharacteristic identifier];
    }

    id<ASWriteableCharacteristic> characteristic = (id<ASWriteableCharacteristic>)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];

    if (!characteristic) {
        if (completion) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorCharacteristicUndiscovered underlyingError:nil];
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
        return;
    }

    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, Write env measurement interval: %@", self.serialNumber, interval]);
    
    [characteristic write:interval withCompletion:^(NSError *error) {
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
    }];
}

- (void)writeEnvironmentalAlertInterval:(NSNumber *)interval completion:(void (^)(NSError *error))completion {
    NSParameterAssert(interval);

    ASEnvironmentalAlertIntervalCharacteristic *characteristic = ((ASServiceV1 *)self.services[[ASServiceV1 identifier].lowercaseString]).environmentalAlertIntervalCharacteristic;

    if (!characteristic) {
        if (completion) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorCharacteristicUndiscovered underlyingError:nil];
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
        return;
    }
    
    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, Write env alert interval: %@", self.serialNumber, interval]);

    [characteristic write:interval withCompletion:^(NSError *error) {
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
    }];
}

- (void)writeEnvironmentalAlarmLimitsHumidityHigh:(NSNumber *)hHigh humidityLow:(NSNumber *)hLow temperatureHigh:(NSNumber *)tHigh temperatureLow:(NSNumber *)tLow completion:(void (^)(NSError *error))completion {
    NSParameterAssert(hHigh);
    NSParameterAssert(hLow);
    NSParameterAssert(tHigh);
    NSParameterAssert(tLow);

    ASEnvironmentalAlarmLimitsCharacteristic *characteristic = ((ASServiceV1 *)self.services[[ASServiceV1 identifier].lowercaseString]).environmentalAlarmLimitsCharacteristic;

    if (!characteristic) {
        if (completion) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorCharacteristicUndiscovered underlyingError:nil];
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
        return;
    }

    ASAlarmLimits *limits = [[ASAlarmLimits alloc] init];

    limits.maximumHumidity = hHigh;
    limits.minimumHumidity = hLow;
    limits.maximumTemperature = tHigh;
    limits.minimumTemperature = tLow;
    
    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, Write env alarm limits: hHigh: %@, hLow: %@, tHigh: %@, tLow: %@.", self.serialNumber, hHigh, hLow, tHigh, tLow]);

    [characteristic write:limits withCompletion:^(NSError *error) {
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
    }];
}

- (void)writeAccelerometerSetting:(ASAccelerometerMode)setting completion:(void (^)(NSError *error))completion {
    [self writeAccelerometerSetting:setting pendingWriteCompletion:nil completion:completion];
}

- (void)writeAccelerometerSetting:(ASAccelerometerMode)setting pendingWriteCompletion:(void(^)(void))pendingWriteCompletion completion:(void (^)(NSError *error))completion {
    NSString *characteristicString = nil;
    NSString *serviceString = nil;
    
    BOOL isV4Sensor = [@"4.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending;
    BOOL isV3Sensor = ([@"3.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) && !isV4Sensor;
    
    if (isV4Sensor) {
        serviceString = [ASServiceV4 identifier];
        characteristicString = [ASAccelerometerModeCharacteristicV3 identifier];
    }
    else if (isV3Sensor) {
        serviceString = [ASServiceV3 identifier];
        characteristicString = [ASAccelerometerModeCharacteristicV3 identifier];
    }
    else {
        serviceString = [ASServiceV1 identifier];
        characteristicString = [ASAccelerometerModeCharacteristic identifier];
    }
    
    id<ASWriteableCharacteristic> characteristic = (id<ASWriteableCharacteristic>)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        if (!isV4Sensor) {
            if (completion) {
                NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorCharacteristicUndiscovered underlyingError:nil];
                dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                    completion(error);
                });
            }
            
            return;
        }
        
        ASWritePendingOperation *operation = [[ASWritePendingOperation alloc] initWithServiceString:serviceString characteristicString:characteristicString data:@(setting) completion:completion];
        [self queuePendingWriteOperation:operation];
        
        if (pendingWriteCompletion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                pendingWriteCompletion();
            });
        }
        
        return;
    }
    
    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, Write Accelerometer Setting Mode: %@", self.serialNumber, @(setting)]);
    
    [characteristic write:@(setting) withCompletion:^(NSError *error) {
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
    }];
}

- (void)writeAccelerometerThreshold:(NSNumber *)threshold completion:(void (^)(NSError *error))completion {
    [self writeAccelerometerThreshold:threshold pendingWriteCompletion:nil completion:completion];
}

- (void)writeAccelerometerThreshold:(NSNumber *)threshold pendingWriteCompletion:(void(^)(void))pendingWriteCompletion completion:(void (^)(NSError *error))completion {
    NSParameterAssert(threshold);
    
    NSString *characteristicString = nil;
    NSString *serviceString = nil;
    
    BOOL isV4Sensor = [@"4.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending;
    BOOL isV3Sensor = ([@"3.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) && !isV4Sensor;
    
    if (isV4Sensor) {
        serviceString = [ASServiceV4 identifier];
        characteristicString = [ASImpactThresholdCharacteristicV3 identifier];
    }
    else if (isV3Sensor) {
        serviceString = [ASServiceV3 identifier];
        characteristicString = [ASImpactThresholdCharacteristicV3 identifier];
    }
    else {
        serviceString = [ASServiceV1 identifier];
        characteristicString = [ASImpactThresholdCharacteristic identifier];
    }

    id<ASWriteableCharacteristic> characteristic = (id<ASWriteableCharacteristic>)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        if (!isV4Sensor) {
            if (completion) {
                NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorCharacteristicUndiscovered underlyingError:nil];
                dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                    completion(error);
                });
            }
            
            return;
        }
        
        ASWritePendingOperation *operation = [[ASWritePendingOperation alloc] initWithServiceString:serviceString characteristicString:characteristicString data:threshold completion:completion];
        [self queuePendingWriteOperation:operation];
        
        if (pendingWriteCompletion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                pendingWriteCompletion();
            });
        }
        
        return;
    }
    
    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, Write Accelerometer Threshold: %@", self.serialNumber, threshold]);
    
    [characteristic write:threshold withCompletion:^(NSError *error) {
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
    }];
}

- (void)writePIO:(NSNumber *)PIO completion:(void (^)(NSError *error))completion {
    NSParameterAssert(PIO);

    ASPIOCharacteristic *characteristic = ((ASServiceV1 *)self.services[[ASServiceV1 identifier].lowercaseString]).PIOCharacteristic;

    if (!characteristic) {
        if (completion) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorCharacteristicUndiscovered underlyingError:nil];
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
        return;
    }
    
    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, Write PIO: %@", self.serialNumber, PIO]);

    [characteristic write:PIO withCompletion:^(NSError *error) {
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
    }];
}

- (void)blinkNTimes:(NSNumber *)nBlinks completion:(void (^)(NSError *error))completion {
    [self blinkNTimes:nBlinks pendingWriteCompletion:nil completion:completion];
}

- (void)blinkNTimes:(NSNumber *)nBlinks pendingWriteCompletion:(void(^)(void))pendingWriteCompletion completion:(void (^)(NSError *error))completion {
    NSParameterAssert(nBlinks);
    
    NSString *characteristicString = nil;
    NSString *serviceString = nil;
    
    BOOL isV4Sensor = [@"4.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending;
    BOOL isV3Sensor = ([@"3.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) && !isV4Sensor;
    
    if (isV4Sensor) {
        serviceString = [ASServiceV4 identifier];
        characteristicString = [ASBlinkCharacteristicV3 identifier];
    }
    else if (isV3Sensor) {
        serviceString = [ASServiceV3 identifier];
        characteristicString = [ASBlinkCharacteristicV3 identifier];
    }
    else {
        serviceString = [ASServiceV1 identifier];
        characteristicString = [ASBlinkCharacteristic identifier];
    }
    
    id<ASWriteableCharacteristic> characteristic = (id<ASWriteableCharacteristic>)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        if (!isV4Sensor) {
            if (completion) {
                NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorCharacteristicUndiscovered underlyingError:nil];
                dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                    completion(error);
                });
            }
            
            return;
        }
        
        ASWritePendingOperation *operation = [[ASWritePendingOperation alloc] initWithServiceString:serviceString characteristicString:characteristicString data:nBlinks completion:completion];
        [self queuePendingWriteOperation:operation];
        
        if (pendingWriteCompletion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                pendingWriteCompletion();
            });
        }
        
        return;
    }
    
    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, Write Blink %@ times", self.serialNumber, nBlinks]);
    
    [characteristic write:nBlinks withCompletion:^(NSError *error) {
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
    }];
}

- (void)writeRealtimeModeForAllSoftwareRevision:(BOOL)allowAllRevisions
                                 withCompletion:(void (^)(NSError *error))completion {
    NSString *characteristicString = nil;
    NSString *serviceString = nil;

    if ([@"4.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        if (!allowAllRevisions) {
            if (completion) {
                NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain
                                                       code:ASDeviceWriteErrorVersionUnsupported
                                            underlyingError:nil];
                dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                    completion(error);
                });
            }
            
            return;
        }
        
        serviceString = [ASServiceV4 identifier];
        characteristicString = [ASEnvironmentalBufferCharacteristic identifier];
        
    }
    else if ([@"3.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        serviceString = [ASServiceV3 identifier];
        characteristicString = [ASEnvironmentalBufferCharacteristic identifier];
    }
    else {
        serviceString = [ASServiceV1 identifier];
        characteristicString = [ASEnvironmentalRealtimeModeCharacteristic identifier];
    }

    id<ASWriteableCharacteristic> characteristic = (id<ASWriteableCharacteristic>)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];

    if (!characteristic) {
        if (completion) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorCharacteristicUndiscovered underlyingError:nil];
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
        return;
    }
    
    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, Write Real time mode", self.serialNumber]);

    // Doesn't matter what we write for the old version
    [characteristic write:@(0) withCompletion:^(NSError *error) {
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue, ^{
                completion(error);
            });
        }
    }];
}

#pragma mark - Helpers

- (void)queuePendingWriteOperation:(ASWritePendingOperation *)operation {
    if ([self.pendingOperations containsObject:operation]) {
        [self.pendingOperations removeObject:operation];
    }
    
    [self.pendingOperations addObject:operation];
}

@end
