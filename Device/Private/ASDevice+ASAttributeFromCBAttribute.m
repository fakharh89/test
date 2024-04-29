//
//  ASDevice+ASAttributeFromCBAttribute.m
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice+ASAttributeFromCBAttribute.h"

#import "ASAttribute.h"

#import <CoreBluetooth/CoreBluetooth.h>

@implementation ASDevice (ASAttributeFromCBAttribute)

- (id<ASService>)as_serviceFromService:(CBService *)service {
    id<ASService> thisService = nil;
    for (id<ASService> deviceService in self.services.allValues) {
        if ([deviceService.internalService.UUID.UUIDString caseInsensitiveCompare:service.UUID.UUIDString] == NSOrderedSame) {
            thisService = deviceService;
            break;
        }
    }
    return thisService;
}

- (id<ASCharacteristic>)as_characteristicFromCharacteristic:(CBCharacteristic *)characteristic {
    id<ASCharacteristic> thisCharacteristic = nil;
    id<ASService> thisService = [self as_serviceFromService:characteristic.service];
    if (thisService) {
        for (id<ASCharacteristic> deviceCharacteristic in thisService.characteristics.allValues) {
            if ([deviceCharacteristic.internalCharacteristic.UUID.UUIDString caseInsensitiveCompare:characteristic.UUID.UUIDString] == NSOrderedSame) {
                thisCharacteristic = deviceCharacteristic;
                break;
            }
        }
    }
    return thisCharacteristic;
}

@end
