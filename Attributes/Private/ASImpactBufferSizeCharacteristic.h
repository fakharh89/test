//
//  ASImpactBufferSizeCharacteristic.h
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

@interface ASImpactBufferSizeCharacteristic : ASCharacteristic <ASReadableCharacteristic, ASWriteableCharacteristic>

- (ASBLEResult<NSNumber *> *)process;
- (void)write:(NSNumber *)sizeToDelete withCompletion:(void (^)(NSError *error))completion;

@end
