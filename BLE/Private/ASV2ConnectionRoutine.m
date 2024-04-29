//
//  ASV2ConnectionRoutine.m
//  Blustream
//
//  Created by Michael Gordon on 7/5/16.
//
//

#import "ASV2ConnectionRoutine.h"

#import "ASBLEDefinitions.h"
#import "ASBLEInterface.h"
#import "ASConfig.h"
#import "ASDevicePrivate.h"
#import "ASLog.h"
#import "ASRealtimeMode.h"
#import "ASSystemManagerPrivate.h"
#import "ASServiceV1.h"
#import "ASEnvironmentalMeasurementIntervalCharacteristic.h"
#import "ASEnvironmentalAlertIntervalCharacteristic.h"
#import "ASEnvironmentalAlarmLimitsCharacteristic.h"
#import "ASAccelerometerModeCharacteristic.h"
#import "ASImpactThresholdCharacteristic.h"
#import "ASErrorStateCharacteristic.h"
#import "ASBatteryService.h"
#import "ASBatteryCharacteristic.h"
#import "ASDeviceInfoService.h"
#import "ASHardwareRevisionCharacteristic.h"
#import "ASPIOCharacteristic.h"
#import "ASTimeSyncCharacteristic.h"
#import "ASEnvironmentalDataCharacteristic.h"
#import "ASImpactDataCharacteristic.h"
#import "ASActivityDataCharacteristic.h"

@implementation ASV2ConnectionRoutine

+ (NSArray<CBUUID *> *)supportedServices {
    static NSArray *services;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        services = @[[CBUUID UUIDWithString:ASServiceUUID],
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
        ASCharacteristics = @[[CBUUID UUIDWithString:ASEnvDataCharactUUID],
                              [CBUUID UUIDWithString:ASEnvMeasIntervalCharactUUID],
                              [CBUUID UUIDWithString:ASEnvAlertIntervalCharactUUID],
                              [CBUUID UUIDWithString:ASEnvAlarmLimitsCharactUUID],
                              [CBUUID UUIDWithString:ASEnvRealtimeCharactUUID],
                              [CBUUID UUIDWithString:ASAccDataCharactUUID],
                              [CBUUID UUIDWithString:ASAccActivityCharactUUID],
                              [CBUUID UUIDWithString:ASAccEnableCharactUUID],
                              [CBUUID UUIDWithString:ASAccThresholdCharactUUID],
                              [CBUUID UUIDWithString:ASErrorCharactUUID],
                              [CBUUID UUIDWithString:ASPIOCharactUUID],
                              [CBUUID UUIDWithString:ASAIOCharactUUID],
                              [CBUUID UUIDWithString:ASBlinkCharactUUID],
                              [CBUUID UUIDWithString:ASRegistrationCharactUUID],
                              [CBUUID UUIDWithString:ASTimeSyncCharactUUID]];
        ASBatteryCharacteristics = @[[CBUUID UUIDWithString:ASBatteryCharactUUID]];
        ASDevInfoCharacteristics = @[[CBUUID UUIDWithString:ASHardwareRevCharactUUID],
                                     [CBUUID UUIDWithString:ASSoftwareRevCharactUUID]];
        ASOTAUApplicationCharacteristics = @[[CBUUID UUIDWithString:ASOTAUCurrentAppCharacteristicUUID],
                                             [CBUUID UUIDWithString:ASOTAUKeyBlockCharacteristicUUID],
                                             [CBUUID UUIDWithString:ASOTAUDataTransferCharacteristicUUID],
                                             [CBUUID UUIDWithString:ASOTAUVersionCharacteristicUUID]];
    });
    
    if ([service caseInsensitiveCompare:ASServiceUUID] == NSOrderedSame) {
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
    ASServiceV1 *service = device.services[[ASServiceV1 identifier].lowercaseString];
    
    // Measurement Interval Characteristic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
        [service.environmentalMeasurementIntervalCharacteristic readProcessUpdateDeviceAndSendNotification];
    });
    
    // Alert Interval Characteristic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
        [service.environmentalAlertIntervalCharacteristic readProcessUpdateDeviceAndSendNotification];
    });
    
    // Alarm Limits Characteristic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
        [service.environmentalAlarmLimitsCharacteristic readProcessUpdateDeviceAndSendNotification];
    });
    
    // Realtime Bit Characteristic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
        if ((ASSystemManager.shared.config.realtimeMode) && ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)) {
            [ASSystemManager.shared.BLEInterface.realtimeMode writeRealtimeMode:device];
        }
    });
    
    // Enable Accelerometer Characteristic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
        [service.accelerometerModeCharacteristic readProcessUpdateDeviceAndSendNotification];
    });
    
    // Accelerometer Threshold Characteristic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
        [service.impactThresholdCharacteristic readProcessUpdateDeviceAndSendNotification];
    });
    
    // Acoustic Stream Error Characteristic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
        [service.errorStateCharacteristic readProcessUpdateDeviceAndSendNotification];
        __block ASDevice *blockSafeDevice = device;
        [service.errorStateCharacteristic setNotify:YES withCompletion:^(NSError *error) {
            if (error) {
                ASLog(@"Error setting error notifiy to YES for %@", blockSafeDevice.serialNumber);
            }
        }];
    });
    
    // Acoustic Stream PIO Characteristic
    if (device.type == ASDeviceTypeTaylor) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
            __block ASDevice *blockSafeDevice = device;
            [service.PIOCharacteristic setNotify:YES withCompletion:^(NSError *error) {
                if (error) {
                    ASLog(@"Error setting PIO notify to YES for %@", blockSafeDevice.serialNumber);
                }
            }];
        });
    }
    
    // Battery Service
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
        ASBatteryService *batteryService = device.services[[ASBatteryService identifier].lowercaseString];
        [batteryService.batteryCharacteristic readProcessUpdateDeviceAndSendNotification];
        __block ASDevice *blockSafeDevice = device;
        [batteryService.batteryCharacteristic setNotify:YES withCompletion:^(NSError *error) {
            if (error) {
                ASLog(@"Error setting battery notify to YES for %@", blockSafeDevice.serialNumber);
            }
        }];
    });
    
    // Read value if not known
    if (!device.hardwareRevision) {
        ASLog(@"Getting hardware revision");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), device.processingQueue, ^{
            ASDeviceInfoService *deviceInfoService = device.services[[ASDeviceInfoService identifier].lowercaseString];
            [deviceInfoService.hardwareRevisionCharacteristic readProcessUpdateDeviceAndSendNotification];
        });
    }
    
    [[self class] setupTimeReadForDevice:device];
}

+ (void)setupTimeReadForDevice:(ASDevice *)device {
    ASServiceV1 *service = device.services[[ASServiceV1 identifier].lowercaseString];
    if ([service.environmentalDataCharacteristic isNotifying]) {
        return;
    }
    
    __block ASDevice *blockSafeDevice = device;
    [service.timeSyncCharacteristic write:[NSDate date] withCompletion:^(NSError *error) {
        if (!error) {
            ASLog(@"Wrote current time.  Setting buffered data notify");
            [service.environmentalDataCharacteristic setNotify:YES withCompletion:^(NSError *error) {
                if (error) {
                    ASLog(@"Error setting env data notify to YES for %@", blockSafeDevice.serialNumber);
                }
                else {
                    ASLog(@"Set env data notify");
                }
            }];
            
            [service.impactDataCharacteristic setNotify:YES withCompletion:^(NSError *error) {
                if (error) {
                    ASLog(@"Error setting accelerometer data notify to YES for %@", blockSafeDevice.serialNumber);
                }
                else {
                    ASLog(@"Set accelerometer data notify");
                }
            }];
            
            [service.activityDataCharacteristic setNotify:YES withCompletion:^(NSError *error) {
                if (error) {
                    ASLog(@"Error setting activity data notify to YES for %@", blockSafeDevice.serialNumber);
                }
                else {
                    ASLog(@"Set activity data notify");
                }
            }];
        }
        else {
            ASLog(@"Couldn't write time sync!  No error handling for this condition yet...");
        }
    }];
}

+ (void)device:(ASDevice *)device didFailToSetup:(NSError *)error {
    
}

@end
