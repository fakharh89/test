//
//  ASEnvironmentalMeasurement.h
//  Blustream
//
//  Created by Michael Gordon on 5/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASMeasurement.h"

@interface ASEnvironmentalMeasurement : ASMeasurement <NSCoding>

@property (strong, readonly, nonatomic) NSNumber *humidity;
@property (strong, readonly, nonatomic) NSNumber *temperature;

- (id)initWithDate:(NSDate *)date humidity:(NSNumber *)humidity temperature:(NSNumber *)temperature;
- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate humidity:(NSNumber *)humidity temperature:(NSNumber *)temperature;

@end
