//
//  ASImpactBufferCharacteristic.h
//  Pods
//
//  Created by Michael Gordon on 12/11/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASCharacteristic.h"

#import "ASAttribute.h"

@class ASImpact;

@interface ASImpactBufferCharacteristic : ASCharacteristic <ASBufferCharacteristic>

- (ASBLEResult<NSArray<ASBLEResult<ASImpact *> *> *> *)process;
- (void)write:(NSNumber *)sizeToPrepare withCompletion:(void (^)(NSError *error))completion;

- (BOOL)updateDeviceWithMeasurement:(ASImpact *)measurement error:(NSError * __autoreleasing *)error;

@end
