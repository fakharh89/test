//
//  ASMeasurement.h
//  Blustream
//
//  Created by Michael Gordon on 5/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.

#import <Foundation/Foundation.h>

@interface ASMeasurement : NSObject <NSCoding>

@property (strong, readonly, nonatomic) NSDate *date;
@property (strong, readonly, nonatomic) NSDate *ingestionDate;

- (id)initWithDate:(NSDate *)date;
- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate;

@end
