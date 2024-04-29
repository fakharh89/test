//
//  ASDevice+ASAttributeFromCBAttribute.h
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevicePrivate.h"

@protocol ASService, ASCharacteristic;

@class CBService, CBCharacteristic;

@interface ASDevice (ASAttributeFromCBAttribute)

- (id<ASService>)as_serviceFromService:(CBService *)service;
- (id<ASCharacteristic>)as_characteristicFromCharacteristic:(CBCharacteristic *)characteristic;

@end
