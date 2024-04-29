//
//  ASBeaconModeCharacteristic.h
//  Pods
//
//  Created by Michael Gordon on 3/19/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

#import "ASAttribute.h"
#import "ASCharacteristic.h"

// NOTE - THIS IS LIKELY NOT ACCURATE!!
// 3 bits (uint8)
// (defaults 0b0000 0011)
// 0 - Blustream adv
// 1 - iBeacon
// 2 - Eddystone (NYI)

@interface ASBeaconModeCharacteristic : ASCharacteristic <ASReadableCharacteristic, ASWriteableCharacteristic>

- (ASBLEResult<NSNumber *> *)process;
- (BOOL)updateDeviceWithData:(NSNumber *)data error:(NSError *__autoreleasing *)error;
- (void)write:(NSNumber *)mode withCompletion:(void (^)(NSError *error))completion;

@end
