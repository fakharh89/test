//
//  ASEnvironmentalMeasurement.m
//  Blustream
//
//  Created by Michael Gordon on 5/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASEnvironmentalMeasurement.h"

@implementation ASEnvironmentalMeasurement

- (id)initWithDate:(NSDate *)date humidity:(NSNumber *)humidity temperature:(NSNumber *)temperature {
    return [self initWithDate:date ingestionDate:nil humidity:humidity temperature:temperature];
}

- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate humidity:(NSNumber *)humidity temperature:(NSNumber *)temperature {
    self = [super initWithDate:date ingestionDate:ingestionDate];
    
    if (self) {
        _humidity = humidity;
        _temperature = temperature;
    }
    
    return self;
}

#define kHumidity @"humidity"
#define kTemperature @"temperature"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if (self) {
        _humidity = [decoder decodeObjectForKey:kHumidity];
        _temperature = [decoder decodeObjectForKey:kTemperature];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_humidity forKey:kHumidity];
    [encoder encodeObject:_temperature forKey:kTemperature];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, Humidity: %@%%RH, Temperature: %@°C", [super description], self.humidity, self.temperature];
}

@end
