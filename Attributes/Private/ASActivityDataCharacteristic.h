//
//  ASActivityDataCharacteristic.h
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

@class ASActivityState;

@interface ASActivityDataCharacteristic : ASCharacteristic <ASReadableCharacteristic, ASNotifiableCharacteristic>

- (ASBLEResult<ASActivityState *> *)process;
- (BOOL)updateDeviceWithData:(ASActivityState *)data error:(NSError *__autoreleasing *)error;

@end
