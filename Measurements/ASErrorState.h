//
//  ASErrorState.h
//  Blustream
//
//  Created by Michael Gordon on 7/15/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASMeasurement.h"

@interface ASErrorState : ASMeasurement

@property (strong, readonly, nonatomic) NSNumber *state;

- (id)initWithDate:(NSDate *)date errorState:(NSNumber *)state;
- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate errorState:(NSNumber *)state;

@end
