//
//  ASTimeSyncCharacteristic.h
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASAttribute.h"
#import "ASCharacteristic.h"

@interface ASTimeSyncCharacteristic : ASCharacteristic <ASWriteableCharacteristic>

- (void)write:(NSDate *)date withCompletion:(void (^)(NSError *error))completion;

@end
