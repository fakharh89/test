//
//  ASOTAUVersionCharacteristic.h
//  Pods
//
//  Created by Michael Gordon on 1/12/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASCharacteristic.h"

#import "ASAttribute.h"

@interface ASOTAUVersionCharacteristic : ASCharacteristic <ASReadableCharacteristic>

- (ASBLEResult<NSNumber *> *)process;

@end
