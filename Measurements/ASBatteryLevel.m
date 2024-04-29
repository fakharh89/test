//
//  ASBatteryLevel.m
//  Blustream
//
//  Created by Michael Gordon on 7/15/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASBatteryLevel.h"

@implementation ASBatteryLevel

- (id)initWithDate:(NSDate *)date batteryLevel:(NSNumber *)level {
    return [self initWithDate:date ingestionDate:nil batteryLevel:level];
}

- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate batteryLevel:(NSNumber *)level {
    self = [super initWithDate:date ingestionDate:ingestionDate];
    
    if (self) {
        _level = level;
    }
    
    return self;
}

#define kBattery @"BatteryLevel"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if (self) {
        _level = [decoder decodeObjectForKey:kBattery];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_level forKey:kBattery];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, Battery: %@%%", [super description], self.level];
}

@end
