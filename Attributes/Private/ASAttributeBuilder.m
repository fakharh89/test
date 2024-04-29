//
//  ASAttributeBuilder.m
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASAttributeBuilder.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "ASAttribute.h"
#import "ASBLEDefinitions.h"
#import "ASDevicePrivate.h"
#import "ASLog.h"

#import "ASServiceV1.h"
#import "ASServiceV3.h"
#import "ASServiceV4.h"
#import "ASBatteryService.h"
#import "ASDeviceInfoService.h"

#import "ASHardwareRevisionCharacteristic.h"
#import "ASSerialNumberCharacteristic.h"
#import "ASSoftwareRevisionCharacteristic.h"

#import "ASBatteryCharacteristic.h"

#import "ASEnvironmentalDataCharacteristic.h"
#import "ASEnvironmentalMeasurementIntervalCharacteristic.h"
#import "ASEnvironmentalAlertIntervalCharacteristic.h"
#import "ASEnvironmentalAlarmLimitsCharacteristic.h"
#import "ASEnvironmentalRealtimeModeCharacteristic.h"
#import "ASImpactDataCharacteristic.h"
#import "ASActivityDataCharacteristic.h"
#import "ASAccelerometerModeCharacteristic.h"
#import "ASImpactThresholdCharacteristic.h"
#import "ASErrorStateCharacteristic.h"
#import "ASPIOCharacteristic.h"
#import "ASAIOCharacteristic.h"
#import "ASBlinkCharacteristic.h"
#import "ASRegistrationCharacteristic.h"

#import "ASTimeSyncCharacteristicV3.h"
#import "ASRegistrationCharacteristicV3.h"
#import "ASErrorStateCharacteristicV3.h"
#import "ASBlinkCharacteristicV3.h"
#import "ASEnvironmentalBufferCharacteristic.h"
#import "ASEnvironmentalBufferSizeCharacteristic.h"
#import "ASEnvironmentalMeasurementIntervalCharacteristicV3.h"
#import "ASAccelerometerModeCharacteristicV3.h"
#import "ASImpactBufferCharacteristic.h"
#import "ASImpactBufferSizeCharacteristic.h"
#import "ASImpactThresholdCharacteristicV3.h"
#import "ASActivityBufferCharacteristic.h"
#import "ASActivityBufferSizeCharacteristic.h"
#import "ASPIOBufferCharacteristic.h"
#import "ASPIOBufferSizeCharacteristic.h"
#import "ASAIOCharacteristicV3.h"

#import "ASOTAUApplicationService.h"

#import "ASOTAUCurrentAppCharacteristic.h"
#import "ASOTAUDataTransferCharacteristic.h"
#import "ASOTAUKeyBlockCharacteristic.h"
#import "ASOTAUVersionCharacteristic.h"

#import "ASOTAUBootService.h"
#import "ASOTAUKeyCharacteristic.h"
#import "ASOTAUControlTransferCharacteristic.h"

#import "ASBeaconModeCharacteristic.h"
#import "ASBLEParametersCharacteristic.h"
#import "ASBLEConnectionModeCharacteristic.h"

@implementation ASAttributeBuilder

+ (Class<ASService>)serviceClassForServiceUUID:(NSString *)serviceUUID {
    static NSDictionary *services;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<Class<ASService>> *serviceClasses =
        @[[ASServiceV1 class],
          [ASServiceV3 class],
          [ASServiceV4 class],
          [ASBatteryService class],
          [ASDeviceInfoService class],
          [ASOTAUApplicationService class],
          [ASOTAUBootService class]];
        
        NSMutableDictionary *mutableServices = [[NSMutableDictionary alloc] init];
        for (Class<ASService> class in serviceClasses) {
            [mutableServices addEntriesFromDictionary:@{[class identifier].lowercaseString : class}];
        }
        
        services = [[NSDictionary alloc] initWithDictionary:mutableServices];
    });
    
    return services[serviceUUID.lowercaseString];
}

+ (Class<ASCharacteristic>)characteristicClassForCharacteristicUUID:(NSString *)characteristicUUID {
    static NSDictionary *characteristics;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<Class<ASCharacteristic>> *characteristicClasses =
        @[[ASHardwareRevisionCharacteristic class],
          [ASSerialNumberCharacteristic class],
          [ASSoftwareRevisionCharacteristic class],
          [ASBatteryCharacteristic class],
          [ASEnvironmentalDataCharacteristic class],
          [ASEnvironmentalMeasurementIntervalCharacteristic class],
          [ASEnvironmentalAlertIntervalCharacteristic class],
          [ASEnvironmentalAlarmLimitsCharacteristic class],
          [ASEnvironmentalRealtimeModeCharacteristic class],
          [ASImpactDataCharacteristic class],
          [ASActivityDataCharacteristic class],
          [ASAccelerometerModeCharacteristic class],
          [ASImpactThresholdCharacteristic class],
          [ASErrorStateCharacteristic class],
          [ASPIOCharacteristic class],
          [ASAIOCharacteristic class],
          [ASBlinkCharacteristic class],
          [ASRegistrationCharacteristic class],
          [ASTimeSyncCharacteristicV3 class],
          [ASRegistrationCharacteristicV3 class],
          [ASErrorStateCharacteristicV3 class],
          [ASBlinkCharacteristicV3 class],
          [ASEnvironmentalBufferCharacteristic class],
          [ASEnvironmentalBufferSizeCharacteristic class],
          [ASEnvironmentalMeasurementIntervalCharacteristicV3 class],
          [ASAccelerometerModeCharacteristicV3 class],
          [ASImpactBufferCharacteristic class],
          [ASImpactBufferSizeCharacteristic class],
          [ASImpactThresholdCharacteristicV3 class],
          [ASActivityBufferCharacteristic class],
          [ASActivityBufferSizeCharacteristic class],
          [ASPIOBufferCharacteristic class],
          [ASPIOBufferSizeCharacteristic class],
          [ASAIOCharacteristicV3 class],
          [ASOTAUControlTransferCharacteristic class],
          [ASOTAUCurrentAppCharacteristic class],
          [ASOTAUDataTransferCharacteristic class],
          [ASOTAUKeyBlockCharacteristic class],
          [ASOTAUKeyCharacteristic class],
          [ASOTAUVersionCharacteristic class],
          [ASBeaconModeCharacteristic class],
          [ASBLEParametersCharacteristic class],
          [ASBLEConnectionModeCharacteristic class]];
        
        NSMutableDictionary *mutableCharacteristics = [[NSMutableDictionary alloc] init];
        for (Class<ASCharacteristic> class in characteristicClasses) {
            [mutableCharacteristics addEntriesFromDictionary:@{[class identifier].lowercaseString : class}];
        }
        
        characteristics = [[NSDictionary alloc] initWithDictionary:mutableCharacteristics];
    });
    
    return characteristics[characteristicUUID.lowercaseString];
}

+ (NSArray<id<ASService>> *)servicesForDevice:(ASDevice *)device {
    NSMutableArray *services = [[NSMutableArray alloc] init];
    
    for (CBService *service in device.peripheral.services) {
        Class serviceClass = [self serviceClassForServiceUUID:service.UUID.UUIDString];
        id<ASService> ourService = [[serviceClass alloc] initWithDevice:device internalService:service];
        [services addObject:ourService];
    }
    
    return [NSArray arrayWithArray:services];
}

+ (NSArray<id<ASCharacteristic>> *)characteristicsForService:(id<ASService>)service device:(ASDevice *)device {
    NSMutableArray *characteristics = [[NSMutableArray alloc] init];
    
    for (CBCharacteristic *characteristic in service.internalService.characteristics) {
        Class characteristicClass = [self characteristicClassForCharacteristicUUID:characteristic.UUID.UUIDString];
        id<ASCharacteristic> ourChar = [[characteristicClass alloc] initWithDevice:device service:service internalCharacteristic:characteristic];
        if (ourChar) {
            [characteristics addObject:ourChar];
        }
        else {
            ASLog(@"Discovered unknown characteristic: %@", characteristic);
        }
    }
    
    return [NSArray arrayWithArray:characteristics];
}

@end
