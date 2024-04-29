//
//  ASSerialNumberCharacteristic.h
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

@interface ASSerialNumberCharacteristic : ASCharacteristic <ASReadableCharacteristic>

- (ASBLEResult<NSString *> *)process;
- (BOOL)updateDeviceWithData:(NSString *)data error:(NSError *__autoreleasing *)error;

@end
