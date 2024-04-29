//
//  ASAttributeBuilder.h
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@protocol ASService, ASCharacteristic;

@class ASDevice, CBService, CBCharacteristic, CBPeripheral;

@interface ASAttributeBuilder : NSObject

+ (NSArray<id<ASService>> *)servicesForDevice:(ASDevice *)device;
+ (NSArray<id<ASCharacteristic>> *)characteristicsForService:(id<ASService>)service device:(ASDevice *)device;

@end
