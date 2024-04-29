//
//  ASPIOCharacteristic.h
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

@class ASPIOState;

@interface ASPIOCharacteristic : ASCharacteristic <ASReadableCharacteristic, ASWriteableCharacteristic, ASNotifiableCharacteristic>

- (ASBLEResult<ASPIOState *> *)process;
- (BOOL)updateDeviceWithData:(ASPIOState *)data error:(NSError *__autoreleasing *)error;
- (void)write:(NSNumber *)byte withCompletion:(void (^)(NSError *error))completion;

@end
