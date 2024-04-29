//
//  ASEnvironmentalAlarmLimitsCharacteristic.h
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
#import "ASCharacteristic.h"

@class ASAlarmLimits;

@interface ASEnvironmentalAlarmLimitsCharacteristic : ASCharacteristic <ASReadableCharacteristic, ASWriteableCharacteristic>

- (ASBLEResult<ASAlarmLimits *> *)process;
- (BOOL)updateDeviceWithData:(ASAlarmLimits *)data error:(NSError *__autoreleasing *)error;

- (void)write:(ASAlarmLimits *)alarmLimits withCompletion:(void (^)(NSError *error))completion;

@end
