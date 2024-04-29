//
//  ASV4ConnectionRoutine.m
//  Blustream
//
//  Created by Michael Gordon on 3/19/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import "ASV4ConnectionRoutine.h"

#import "ASActivityState.h"
#import "ASBLEDefinitions.h"
#import "ASConfig.h"
#import "ASContainerPrivate.h"
#import "ASDevicePrivate.h"
#import "ASDevice+BLEUpdate.h"
#import "ASEnvironmentalMeasurement.h"
#import "ASErrorState.h"
#import "ASImpact.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASSystemManagerPrivate.h"
#import "ASRealtimeMode.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#import "ASSystemManager.h"
#import "ASCloudPrivate.h"
#import "ASPUTQueue.h"
#import "ASBLEResult.h"

#import "ASServiceV4.h"
#import "ASWritePendingOperation.h"
#import "ASEnvironmentalMeasurementIntervalCharacteristicV3.h"
#import "ASAccelerometerModeCharacteristicV3.h"
#import "ASImpactThresholdCharacteristicV3.h"
#import "ASErrorStateCharacteristicV3.h"
#import "ASBatteryService.h"
#import "ASBatteryCharacteristic.h"
#import "ASDeviceInfoService.h"
#import "ASHardwareRevisionCharacteristic.h"

#import "ASEnvironmentalBufferCharacteristic.h"
#import "ASEnvironmentalBufferSizeCharacteristic.h"
#import "ASImpactBufferCharacteristic.h"
#import "ASImpactBufferSizeCharacteristic.h"
#import "ASActivityBufferCharacteristic.h"
#import "ASActivityBufferSizeCharacteristic.h"

#import "ASTimeSyncCharacteristicV3.h"

#import "ASBeaconModeCharacteristic.h"
#import "ASBLEParametersCharacteristic.h"
#import "ASBLEConnectionModeCharacteristic.h"

#import "MSWeakTimer.h"

@implementation ASV4ConnectionRoutine

+ (NSArray<CBUUID *> *)supportedServices {
    static NSArray *services;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        services = @[[CBUUID UUIDWithString:ASServiceUUIDv4],
                     [CBUUID UUIDWithString:ASBatteryServiceUUID],
                     [CBUUID UUIDWithString:ASDevInfoServiceUUID],
                     [CBUUID UUIDWithString:ASOTAUApplicationServiceUUID]];
    });
    
    return services;
}

+ (NSArray<CBUUID *> *)supportedCharacteristicsForService:(NSString *)service {
    static NSArray *ASCharacteristics, *ASBatteryCharacteristics, *ASDevInfoCharacteristics, *ASOTAUApplicationCharacteristics;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ASCharacteristics        = @[[CBUUID UUIDWithString:ASTimeSyncCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASRegistrationCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASErrorStateCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASBlinkCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASEnvironmentalMeasurementBufferCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASEnvironmentalMeasurementBufferSizeCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASEnvironmentalMeasurementIntervalCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASAccelerometerModeCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASImpactBufferCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASImpactBufferSizeCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASImpactThresholdCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASActivityBufferCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASActivityBufferSizeCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASPIOBufferCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASPIOBufferSizeCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASAIOCharacteristicUUIDv3],
                                     [CBUUID UUIDWithString:ASBeaconModeUUID],
                                     [CBUUID UUIDWithString:ASBLEParametersUUID],
                                     [CBUUID UUIDWithString:ASBLEConnectionModeUUID]];
        ASBatteryCharacteristics = @[[CBUUID UUIDWithString:ASBatteryCharactUUID]];
        ASDevInfoCharacteristics = @[[CBUUID UUIDWithString:ASHardwareRevCharactUUID],
                                     [CBUUID UUIDWithString:ASSoftwareRevCharactUUID]];
        ASOTAUApplicationCharacteristics = @[[CBUUID UUIDWithString:ASOTAUCurrentAppCharacteristicUUID],
                                             [CBUUID UUIDWithString:ASOTAUKeyBlockCharacteristicUUID],
                                             [CBUUID UUIDWithString:ASOTAUDataTransferCharacteristicUUID],
                                             [CBUUID UUIDWithString:ASOTAUVersionCharacteristicUUID]];
    });
    
    if ([service caseInsensitiveCompare:ASServiceUUIDv4] == NSOrderedSame) {
        return ASCharacteristics;
    }
    else if ([service caseInsensitiveCompare:ASBatteryServiceUUID] == NSOrderedSame) {
        return ASBatteryCharacteristics;
    }
    else if ([service caseInsensitiveCompare:ASDevInfoServiceUUID] == NSOrderedSame) {
        return ASDevInfoCharacteristics;
    }
    else if ([service caseInsensitiveCompare:ASOTAUApplicationServiceUUID] == NSOrderedSame) {
        return ASOTAUApplicationCharacteristics;
    }
    
    return nil;
}

+ (void)didFinishSetupForDevice:(ASDevice *)device {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:ASContainerCharacteristicReadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDisconnected:) name:ASDeviceDisconnectedNotification object:nil];
    });
    
    ASServiceV4 *service = device.services[[ASServiceV4 identifier].lowercaseString];
    ASBeaconModeCharacteristic *beaconModeCharacteristic = service.beaconModeCharacteristic;
    
    if (ASSystemManager.shared.config.disableiBeaconForV4) {
        [beaconModeCharacteristic write:@(0x01) withCompletion:^(NSError *error) {
            [self continueSetup:device];
        }];
    }
    else {
        [self continueSetup:device];
    }
}

+ (void)continueSetup:(ASDevice *)device {

    ASServiceV4 *service = device.services[[ASServiceV4 identifier].lowercaseString];
    
    // Enable Accelerometer Characteristic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
#warning reading this while disconnected is really bad since the characteristics changed
        [service.accelerometerModeCharacteristic readProcessUpdateDeviceAndSendNotification];
    });
    
    // Accelerometer Threshold Characteristic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
        [service.impactThresholdCharacteristic readProcessUpdateDeviceAndSendNotification];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
        [service.environmentalMeasurementIntervalCharacteristic readProcessUpdateDeviceAndSendNotification];
    });
    
    if (!device.hardwareRevision) {
        ASLog(@"Getting hardware revision");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
            ASDeviceInfoService *deviceInfoService = device.services[[ASDeviceInfoService identifier].lowercaseString];
            [deviceInfoService.hardwareRevisionCharacteristic readProcessUpdateDeviceAndSendNotification];
        });
    }
    
    [self setupTimeReadForDevice:device];
}

// TODO Error handling for all v4 handlers

+ (void)setupTimeReadForDevice:(ASDevice *)device {
    ASServiceV4 *service = device.services[[ASServiceV4 identifier]];
    [service.timeSyncCharacteristic write:[NSDate date] withCompletion:^(NSError *error) {
        if (error) {
            [self device:device didFailToSetup:error];
            return;
        }
        
        ASBatteryService *batteryService = device.services[[ASBatteryService identifier].lowercaseString];
        [batteryService.batteryCharacteristic readWithCompletion:^(NSError *error) {
            [batteryService.batteryCharacteristic processUpdateDeviceAndSendNotificationWithError:error];
            
            [self writePendingOperationsForDevice:device withCompletion:^{
                ASServiceV4 *service = device.services[[ASServiceV4 identifier].lowercaseString];
                
                [service.errorStateCharacteristic readProcessUpdateDeviceAndSendNotification];
                
                __block ASDevice *blockSafeDevice = device;
                [service.errorStateCharacteristic setNotify:YES withCompletion:^(NSError *error) {
                    if (error) {
                        ASLog(@"Error setting error state notify to YES for %@", blockSafeDevice.serialNumber);
                    }
                }];
            }];
        }];
    }];
}

+ (void)writePendingOperationsForDevice:(ASDevice *)device withCompletion:(void (^)(void))completion {
    ASWritePendingOperation *operation = device.pendingOperations.firstObject;
    
    if (!operation) {
        if (completion) {
            completion();
        }
        
        return;
    }
    
    id<ASWriteableCharacteristic> characteristic = (id<ASWriteableCharacteristic>)device.services[operation.serviceString.lowercaseString].characteristics[operation.characteristicString.lowercaseString];
    
    [characteristic write:operation.data withCompletion:^(NSError *error) {
        if (operation.completion) {
            operation.completion(error);
        }
        
        [device.pendingOperations removeObject:operation];
        [self writePendingOperationsForDevice:device withCompletion:completion];
    }];
}

+ (void)startBufferDownloadForDevice:(ASDevice *)device bufferCharacteristic:(id<ASBufferCharacteristic>)bufferCharacteristic sizeCharacteristic:(id<ASReadableCharacteristic, ASWriteableCharacteristic>)sizeCharacteristic loggingTag:(NSString *)tag completion:(void (^)(NSError *error))completion {
    ASLog(@"Reading %@ buffer size for %@", tag, device.serialNumber);
    
    [sizeCharacteristic readWithCompletion:^(NSError *error) {
        if (error) {
            ASLog(@"Failed to read %@ data buffer size for %@", tag, device.serialNumber);
            if (completion) {
                completion(error);
            }
            return;
        }
        
        ASBLEResult<NSNumber *> *result = [sizeCharacteristic process];
        
        if (result.error) {
            ASLog(@"Failed to read %@ data buffer size for %@", tag, device.serialNumber);
            if (completion) {
                completion(result.error);
            }
            return;
        }
        
        NSNumber *bufferSize = result.value;
        
        if (bufferSize.unsignedIntValue == 0) {
            ASLog(@"%@ buffer is empty for %@", tag, device.serialNumber);
            if (completion) {
                completion(nil);
            }
            return;
        }
        
        ASLog(@"%@ buffer has %@ point%@ on %@", tag, bufferSize, (bufferSize.unsignedIntValue == 1) ? @"" : @"s", device.serialNumber);
        
        const uint16_t maxSize = 48;
        uint16_t sizeAvailable = bufferSize.unsignedShortValue;
        uint8_t sizeToRead = 0;
        if (sizeAvailable > maxSize) {
            sizeToRead = maxSize;
        }
        else {
            sizeToRead = sizeAvailable;
        }
        
        ASLog(@"Preparing to read %d %@ point%@ from %@", sizeToRead, tag, (sizeToRead == 1) ? @"" : @"s", device.serialNumber);
        
        [bufferCharacteristic write:@(sizeToRead) withCompletion:^(NSError *error) {
            if (error) {
                ASLog(@"Prepare request for %@ data failed for %@", tag, device.serialNumber);
                if (completion) {
                    completion(error);
                }
                return;
            }
            
            ASLog(@"Reading %@ buffer for %@", tag, device.serialNumber);
            [bufferCharacteristic readWithCompletion:^(NSError *error) {
                if (error) {
                    ASLog(@"Failed to read %@ data buffer for %@", tag, device.serialNumber);
                    if (completion) {
                        completion(error);
                    }
                    return;
                }
                
                ASBLEResult<NSArray<ASBLEResult<ASMeasurement *> *> *> *packetResult = [bufferCharacteristic process];
                
                if (packetResult.error) {
                    ASLog(@"Failed to read %@ data buffer for %@", tag, device.serialNumber);
                    if (completion) {
                        completion(packetResult.error);
                    }
                    return;
                }
                
                NSArray<ASBLEResult<ASMeasurement *> *> *allResults = packetResult.value;
                NSMutableArray<ASMeasurement *> *mutableGoodMeasurements = [[NSMutableArray alloc] init];
                
                for (ASBLEResult<ASMeasurement *> *r in allResults) {
                    if (!r.error) {
                        [mutableGoodMeasurements addObject:r.value];
                    }
                }
                
                NSArray<ASMeasurement *> *goodMeasurements = [NSArray arrayWithArray:mutableGoodMeasurements];
                
                // Check if result is type
                if (!packetResult.error && (allResults.count == goodMeasurements.count)) {
                    uint16_t sizeToDelete = goodMeasurements.count;
                    
                    [self deleteDataFromDevice:device bufferCharacteristic:bufferCharacteristic sizeCharacteristic:sizeCharacteristic size:sizeToDelete measurements:goodMeasurements loggingTag:tag completion:^(NSError *error) {
                        if (completion) {
                            completion(error);
                        }
                    } recheckCompletion:^{
                        [self startBufferDownloadForDevice:device bufferCharacteristic:bufferCharacteristic sizeCharacteristic:sizeCharacteristic loggingTag:tag completion:completion];
                    }];
                    return;
                }
                
                // read again
                [bufferCharacteristic readWithCompletion:^(NSError *error) {
                    if (error) {
                        ASLog(@"Failed to read %@ data buffer for %@", tag, device.serialNumber);
                        if (completion) {
                            completion(error);
                        }
                        return;
                    }
                    
                    ASBLEResult<NSArray<ASBLEResult<ASMeasurement *> *> *> *secondPacketResult = [bufferCharacteristic process];
                    
                    if ([packetResult.data isEqualToData:secondPacketResult.data]) {
                        // Problem here
                        uint16_t sizeToDelete = allResults.count;
                        [self deleteDataFromDevice:device bufferCharacteristic:bufferCharacteristic sizeCharacteristic:sizeCharacteristic size:sizeToDelete measurements:goodMeasurements loggingTag:tag completion:^(NSError *error) {
                            if (completion) {
                                completion(error);
                            }
                        } recheckCompletion:^{
                            [self startBufferDownloadForDevice:device bufferCharacteristic:bufferCharacteristic sizeCharacteristic:sizeCharacteristic loggingTag:tag completion:completion];
                        }];
                    }
                    else {
                        NSArray<ASBLEResult<ASMeasurement *> *> *secondAllResults = packetResult.value;
                        NSMutableArray<ASMeasurement *> *secondMutableGoodMeasurements = [[NSMutableArray alloc] init];
                        
                        for (ASBLEResult<ASMeasurement *> *r in secondAllResults) {
                            if (!r.error) {
                                [secondMutableGoodMeasurements addObject:r.value];
                            }
                        }
                        
                        NSArray<ASMeasurement *> *secondGoodMeasurements = [NSArray arrayWithArray:secondMutableGoodMeasurements];
                        
                        
                        if (!secondPacketResult.error && (secondAllResults.count == secondGoodMeasurements.count)) {
                            ASLog(@"Failed to read %@ data buffer for %@", tag, device.serialNumber);
                            if (completion) {
                                completion(error);
                            }
                            return;
                        }
                        
                        // Carry on as usual
                        uint16_t sizeToDelete = secondGoodMeasurements.count;
                        [self deleteDataFromDevice:device bufferCharacteristic:bufferCharacteristic sizeCharacteristic:sizeCharacteristic size:sizeToDelete measurements:secondGoodMeasurements loggingTag:tag completion:^(NSError *error) {
                            if (completion) {
                                completion(error);
                            }
                        } recheckCompletion:^{
                            [self startBufferDownloadForDevice:device bufferCharacteristic:bufferCharacteristic sizeCharacteristic:sizeCharacteristic loggingTag:tag completion:completion];
                        }];
                    }
                }];
            }];
        }];
    }];
}

+ (void)deleteDataFromDevice:(ASDevice *)device bufferCharacteristic:(id<ASBufferCharacteristic>)bufferCharacteristic sizeCharacteristic:(id<ASReadableCharacteristic, ASWriteableCharacteristic>)sizeCharacteristic size:(uint16_t)sizeToDelete measurements:(NSArray<ASMeasurement *> *)measurements loggingTag:(NSString *)tag completion:(void (^)(NSError *error))completion recheckCompletion:(void (^)(void))restartCompletion {
    ASLog(@"Deleting %d %@ points for %@", sizeToDelete, tag, device.serialNumber);
    
    [sizeCharacteristic write:@(sizeToDelete) withCompletion:^(NSError *error) {
        if (error) {
            ASLog(@"Failed to delete %@ data %@", tag, device.serialNumber);
            if (completion) {
                completion(error);
            }
            return;
        }
        
        for (ASMeasurement *measurement in measurements) {
            NSError *updateError = nil;
            if ([bufferCharacteristic updateDeviceWithMeasurement:measurement error:&updateError]) {
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASContainerCharacteristicReadNotification object:device.container userObject:@{@"characteristic":[[bufferCharacteristic class] notificationCharacteristicString]} waitUntilDone:YES];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASContainerDataDownloadedFromDeviceNotification object:device.container userObject:nil waitUntilDone:NO];
        
        restartCompletion();
    }];
}

+ (void)device:(ASDevice *)device didFailToSetup:(NSError *)error {
    ASLog(@"FAILED %@", error);
}

+ (void)deviceDisconnected:(NSNotification *)notification {
    ASDevice *device = notification.object;
    
    if (device) {
        device.downloadCycleActive = NO;
    }
    
    if (device.container) {
        // TODO Only put this specific container
        // PER DEVICE - saving can be similar
        [ASSystemManager.shared.cloud.PUTQueue fire];
        [device.container delayedSave];
    }
}

// We use a notification here since the error byte constantly changes
+ (void)dataUpdated:(NSNotification *)notification {
    ASContainer *container = notification.object;
    
    if ([@"4.0.0" compare:container.device.softwareRevision options:NSNumericSearch] == NSOrderedDescending) {
        return;
    }
    
    NSString *characteristic = notification.userInfo[@"characteristic"];
    
    if ([ASErrorCharactUUID caseInsensitiveCompare:characteristic] != NSOrderedSame) {
        return;
    }
    
    ASErrorState *state = container.errors.lastObject;
    
    BOOL readData = state.state.unsignedCharValue & (1 << 7);
    
    // TODO The didFailToSetup isn't actually an error handling function
    if (readData && !container.device.downloadCycleActive) {
        
        container.device.downloadCycleActive = YES;
        
        ASServiceV4 *service = container.device.services[[ASServiceV4 identifier].lowercaseString];
        
        [self startBufferDownloadForDevice:container.device bufferCharacteristic:service.environmentalBufferCharacteristic sizeCharacteristic:service.environmentalBufferSizeCharacteristic loggingTag:@"env" completion:^(NSError *error) {
            if (error) {
                [self device:container.device didFailToSetup:error];
                container.device.downloadCycleActive = NO;
                return;
            }
            
            [self startBufferDownloadForDevice:container.device bufferCharacteristic:service.impactBufferCharacteristic sizeCharacteristic:service.impactBufferSizeCharacteristic loggingTag:@"impact" completion:^(NSError *error) {
                if (error) {
                    [self device:container.device didFailToSetup:error];
                    container.device.downloadCycleActive = NO;
                    return;
                }
                
                [self startBufferDownloadForDevice:container.device bufferCharacteristic:service.activityBufferCharacteristic sizeCharacteristic:service.activityBufferSizeCharacteristic loggingTag:@"activity" completion:^(NSError *error) {
                    if (error) {
                        [self device:container.device didFailToSetup:error];
                        container.device.downloadCycleActive = NO;
                        return;
                    }
                    
                    container.device.downloadCycleActive = NO;
                    
                    // We have to read the error byte again because new data might have come in while reading one of the
                    // other fifo's.  For example, if env data comes in while dumping the activity data, the error
                    // bit indicating new data will never flip back to a 1 because the buffers weren't empty.
                    // This bug is particularly easy to reproduce by slamming Taylor hardware on a table repeatedly
                    // and setting the environmental measurement interval to 5 seconds
                    ASServiceV4 *service = container.device.services[[ASServiceV4 identifier].lowercaseString];
                    ASErrorStateCharacteristicV3 *characteristic = service.errorStateCharacteristic;
                    [characteristic readWithCompletion:^(NSError *error) {
                        if (error) {
                            [characteristic sendNotificationWithError:error];
                            [self device:container.device didFailToSetup:error];
                            return;
                        }
                        
                        ASBLEResult<ASErrorState *> *result = [characteristic process];
                        
                        if (result.error) {
                            [characteristic sendNotificationWithError:error];
                            [self device:container.device didFailToSetup:result.error];
                            return;
                        }
                        
                        NSError *updateError = nil;
                        if (![characteristic updateDeviceWithData:result.value error:&updateError]) {
                            [characteristic sendNotificationWithError:updateError];
                            [self device:container.device didFailToSetup:result.error];
                            return;
                        }
                        
                        [characteristic sendNotificationWithError:nil];
                    }];
                }];
            }];
        }];
    }
}

@end
