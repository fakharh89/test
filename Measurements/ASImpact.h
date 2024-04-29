//
//  ASImpact.h
//  Blustream
//
//  Created by Michael Gordon on 7/15/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASMeasurement.h"

@interface ASImpact : ASMeasurement <NSCoding>

@property (strong, readonly, nonatomic) NSNumber *x;
@property (strong, readonly, nonatomic) NSNumber *y;
@property (strong, readonly, nonatomic) NSNumber *z;
@property (strong, readonly, nonatomic) NSNumber *magnitude;

// Automatically calculates the magnitude
- (id)initWithDate:(NSDate *)date x:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z;
- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate x:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z;

- (id)initWithDate:(NSDate *)date magnitude:(NSNumber *)magnitude;
- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate magnitude:(NSNumber *)magnitude;

// Warning, this function will override the automatically calculate magnitude
- (id)initWithDate:(NSDate *)date x:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z magnitude:(NSNumber *)magnitude;
- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate x:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z magnitude:(NSNumber *)magnitude;

@end
