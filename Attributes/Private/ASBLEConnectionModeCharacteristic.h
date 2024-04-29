//
//  ASBLEConnectionModeCharacteristic.h
//  Pods
//
//  Created by Michael Gordon on 3/19/18.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

#import "ASAttribute.h"
#import "ASCharacteristic.h"

@interface ASBLEConnectionModeCharacteristic : ASCharacteristic <ASReadableCharacteristic, ASWriteableCharacteristic>

- (ASBLEResult<NSNumber *> *)process;
- (BOOL)updateDeviceWithData:(NSNumber *)data error:(NSError *__autoreleasing *)error;
- (void)write:(NSNumber *)threshold withCompletion:(void (^)(NSError *error))completion;

@end
