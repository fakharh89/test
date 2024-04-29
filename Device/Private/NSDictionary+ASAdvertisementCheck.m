//
//  NSDictionary+ASAdvertisementCheck.m
//  Blustream
//
//  Created by Michael Gordon on 2/16/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "NSDictionary+ASAdvertisementCheck.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "ASAdvertisementData.h"
#import "ASBLEDefinitions.h"
#import "ASLog.h"
#import "ASManufacturerData.h"
#import "ASSystemManager.h"
#import "NSData+ASBLEResult.h"
#import "NSString+ASCompatibility.h"

@implementation NSDictionary (ASAdvertisementCheck)

- (ASAdvertisementData *)as_advertisementData {
    ASAdvertisementData *advertisementData = [[ASAdvertisementData alloc] init];
    
    NSData *rawManufacturerData = [self objectForKey:CBAdvertisementDataManufacturerDataKey];
    
    if (rawManufacturerData) {
        ASBLEResult<ASManufacturerData *> *result = [rawManufacturerData as_manufacturerData];
        advertisementData.manufacturerData = result.value;
    }
    
    return advertisementData;
}

- (ASDeviceConnectionMode)as_deviceConnectionMode {
    NSArray *services = self[CBAdvertisementDataServiceUUIDsKey];
    if (services && services.count > 0) {
        NSString *firstServiceUUIDString = ((CBUUID *)services[0]).UUIDString;
        if (([ASServiceUUID caseInsensitiveCompare:firstServiceUUIDString] == NSOrderedSame)
            || ([ASServiceUUIDv3 caseInsensitiveCompare:firstServiceUUIDString] == NSOrderedSame)
            || ([ASServiceUUIDv4 caseInsensitiveCompare:firstServiceUUIDString] == NSOrderedSame)) {
            return ASDeviceConnectionModeDefault;
        }
    }
    
    NSString *name = self[CBAdvertisementDataLocalNameKey];
    
    if ([@"DA-OTA" caseInsensitiveCompare:name] == NSOrderedSame
        || [@"Humiditrak" caseInsensitiveCompare:name] == NSOrderedSame
        || [@"Humiditrak-OTA" caseInsensitiveCompare:name] == NSOrderedSame
        || [@"AS-D'Addario" caseInsensitiveCompare:name] == NSOrderedSame
        || [@"SafeNSound-OTA" caseInsensitiveCompare:name] == NSOrderedSame
        || [@"Safe&Sound" caseInsensitiveCompare:name] == NSOrderedSame) {
        return ASDeviceConnectionModeOverTheAirUpdate;
    }
    
    return ASDeviceConnectionModeUnknown;
}

- (void)as_dumpAdvertisingData {
    // Read advertisement data
    NSString *AdvertisementDataLocalNameKey = [self objectForKey:CBAdvertisementDataLocalNameKey];
    NSData *AdvertisementDataManufacturerDataKey = [self objectForKey:CBAdvertisementDataManufacturerDataKey];
    NSDictionary *AdvertisementDataServiceDataKey = [self objectForKey:CBAdvertisementDataServiceDataKey];
    NSArray *AdvertisementDataServiceUUIDsKey = [self objectForKey:CBAdvertisementDataServiceUUIDsKey];
    NSArray *AdvertisementDataOverflowServiceUUIDsKey = [self objectForKey:CBAdvertisementDataOverflowServiceUUIDsKey];
    NSNumber *AdvertisementDataTxPowerLevelKey = [self objectForKey:CBAdvertisementDataTxPowerLevelKey];
    NSNumber *AdvertisementDataIsConnectable = [self objectForKey:CBAdvertisementDataIsConnectable];
    NSArray *AdvertisementDataSolicitedServiceUUIDsKey = [self objectForKey:CBAdvertisementDataSolicitedServiceUUIDsKey];
    
    ASLog(@"AdvertisementDataLocalNameKey: %@", AdvertisementDataLocalNameKey);
    
    ASLog(@"AdvertisementDataManufacturerDataKey: %@", AdvertisementDataManufacturerDataKey);
    unsigned char *p = (unsigned char *)AdvertisementDataManufacturerDataKey.bytes;
    if (p) {
        ASLog(@"Manufacturing ID: %02x%02x", p[1], p[0]);
        ASLog(@"Serial No: %02x%02x%02x%02x", p[5], p[4], p[3], p[2]);
        ASLog(@"Humidity: %02x %02x", p[6], p[7]);
        ASLog(@"Temperature: %02x %02x", p[8], p[9]);
        ASLog(@"Battery: %02x", p[10]);
        ASLog(@"Error: %02x", p[11]);
    }
    
    ASLog(@"AdvertisementDataServiceDataKey: %@", AdvertisementDataServiceDataKey);
    ASLog(@"AdvertisementDataServiceUUIDsKey: %@", AdvertisementDataServiceUUIDsKey);
    // LSB: 72 10 00 00
    // MSB: 00 00 10 72
    // Taylor: 10
    // D'Addario: 01
    for (int i = 0; i < [AdvertisementDataServiceUUIDsKey count]; i++) {
        CBUUID *uuid = [AdvertisementDataServiceUUIDsKey objectAtIndex:i];
        NSData *dat = [AdvertisementDataServiceDataKey objectForKey:uuid];
        ASLog(@"\tCBUUID: %@", uuid);
        ASLog(@"\tData: %@", [[NSString alloc]initWithData:dat encoding:NSUTF8StringEncoding]);
    }
    
    ASLog(@"AdvertisementDataOverflowServiceUUIDsKey: %@", AdvertisementDataOverflowServiceUUIDsKey);
    for (int i = 0; i < [AdvertisementDataOverflowServiceUUIDsKey count]; i++) {
        CBUUID *uuid = [AdvertisementDataOverflowServiceUUIDsKey objectAtIndex:i];
        ASLog(@"\tCBUUID: %@", uuid);
    }
    
    ASLog(@"AdvertisementDataTxPowerLevelKey: %@", AdvertisementDataTxPowerLevelKey);
    
    ASLog(@"AdvertisementDataIsConnectable: %@", AdvertisementDataIsConnectable);
    
    ASLog(@"AdvertisementDataSolicitedServiceUUIDsKey: %@", AdvertisementDataSolicitedServiceUUIDsKey);
    for (int i = 0; i < [AdvertisementDataSolicitedServiceUUIDsKey count]; i++) {
        CBUUID *uuid = [AdvertisementDataSolicitedServiceUUIDsKey objectAtIndex:i];
        ASLog(@"\tCBUUID: %@", uuid);
    }
}

@end
