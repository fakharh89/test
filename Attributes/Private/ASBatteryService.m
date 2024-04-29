//
//  ASBatteryService.m
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASBatteryService.h"

#import "ASBatteryCharacteristic.h"
#import "ASBLEDefinitions.h"

@implementation ASBatteryService

+ (NSString *)identifier {
    return ASBatteryServiceUUID;
}

- (ASBatteryCharacteristic *)batteryCharacteristic {
    return (ASBatteryCharacteristic *)self.characteristics[[ASBatteryCharacteristic identifier].lowercaseString];
}

@end
