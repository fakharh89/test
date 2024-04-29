//
//  ASAIOMeasurement.m
//  Blustream
//
//  Created by Michael Gordon on 7/15/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASAIOMeasurement.h"

@implementation ASAIOMeasurement

- (id)initWithDate:(NSDate *)date AIOVoltages:(NSArray<NSNumber *> *)voltages {
    self = [super initWithDate:date];
    
    if (self) {
        _voltages = voltages;
    }
    
    return self;
}

#define kVoltages @"Voltages"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if (self) {
        _voltages = [decoder decodeObjectForKey:kVoltages];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_voltages forKey:kVoltages];
}

- (NSString *)description {
    NSString *voltagesString = nil;
    if (self.voltages && (self.voltages.count > 0)) {
        voltagesString = @"(";
        for (int i = 0; i < self.voltages.count; i++) {
            voltagesString = [NSString stringWithFormat:@"%@%@V", voltagesString, self.voltages[i]];
            if ((i + 1) < self.voltages.count) {
                voltagesString = [NSString stringWithFormat:@"%@, ", voltagesString];
            }
        }
        voltagesString = [NSString stringWithFormat:@"%@)", voltagesString];
    }
    
    return [NSString stringWithFormat:@"%@, AIO: %@", [super description], voltagesString];
}

@end
