//
//  ASEnvironmentalMeasurementIntervalCharacteristic.h
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

@interface ASEnvironmentalMeasurementIntervalCharacteristic : ASCharacteristic <ASReadableCharacteristic, ASWriteableCharacteristic>

- (ASBLEResult<NSNumber *> *)process;
- (BOOL)updateDeviceWithData:(NSNumber *)data error:(NSError *__autoreleasing *)error;
- (void)write:(NSNumber *)measurementInterval withCompletion:(void (^)(NSError *error))completion;

@end
