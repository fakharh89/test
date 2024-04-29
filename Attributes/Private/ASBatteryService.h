//
//  ASBatteryService.h
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

#import "ASAttribute.h"
#import "ASService.h"

@class ASBatteryCharacteristic;

@interface ASBatteryService : ASService <ASService>

@property (strong, readonly, nonatomic) ASBatteryCharacteristic *batteryCharacteristic;

@end
