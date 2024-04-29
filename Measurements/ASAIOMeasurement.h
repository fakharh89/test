//
//  ASAIOMeasurement.h
//  Blustream
//
//  Created by Michael Gordon on 7/15/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASMeasurement.h"

@interface ASAIOMeasurement : ASMeasurement

@property (copy, readonly, nonatomic) NSArray<NSNumber *> *voltages;

- (id)initWithDate:(NSDate *)date AIOVoltages:(NSArray<NSNumber *> *)voltages;

@end
