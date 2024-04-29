//
//  ASAveragingResponse.m
//  Blustream
//
//  Created by Michael Gordon on 7/24/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASAveragingResponsePrivate.h"

#import "ASDateFormatter.h"

@implementation ASAveragingResponse

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        
        NSDictionary *accelDict = dict[@"accelerometerWeightedAverage"];
        NSDictionary *ambientDict = dict[@"ambientWeightedAverage"];
        
        if (![accelDict isKindOfClass:[NSNull class]]) {
            _accelerometerAverage = [self fixNSNull:accelDict[@"averageMagnitudeG"]];
            
            NSDictionary *sample = [self fixNSNull:accelDict[@"highMagnitudeGSample"]];
            if (sample) {
                [self setSample:sample value:&_accelerometerHigh date:&_accelerometerHighDate formatter:formatter];
            }
            
            sample = [self fixNSNull:accelDict[@"lowMagnitudeGSample"]];
            if (sample) {
                [self setSample:sample value:&_accelerometerLow date:&_accelerometerLowDate formatter:formatter];
            }
        }
        
        if (![ambientDict isKindOfClass:[NSNull class]]) {
            _humidityAverage = [self fixNSNull:ambientDict[@"averageHumidityRH"]];
            _temperatureAverage = [self fixNSNull:ambientDict[@"averageTemperatureC"]];
            
            NSDictionary *sample = [self fixNSNull:ambientDict[@"highHumidityRHSample"]];
            if (sample) {
                [self setSample:sample value:&_humidityHigh date:&_humidityHighDate formatter:formatter];
            }
            
            sample = [self fixNSNull:ambientDict[@"lowHumidityRHSample"]];
            if (sample) {
                [self setSample:sample value:&_humidityLow date:&_humidityLowDate formatter:formatter];
            }
            
            sample = [self fixNSNull:ambientDict[@"highTemperatureCSample"]];
            if (sample) {
                [self setSample:sample value:&_temperatureHigh date:&_temperatureHighDate formatter:formatter];
            }
            
            sample = [self fixNSNull:ambientDict[@"lowTemperatureCSample"]];
            if (sample) {
                [self setSample:sample value:&_temperatureLow date:&_temperatureLowDate formatter:formatter];
            }
        }
    }
    return self;
}

- (id)fixNSNull:(id)object {
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return object;
}

- (void)setSample:(NSDictionary *)sample value:(NSNumber * __strong *)value date:(NSDate * __strong *)date formatter:(ASDateFormatter *)formatter {
    NSParameterAssert(sample);
    
    if (value) {
        *value = [self fixNSNull:sample[@"sample"]];
    }
    
    if (date) {
        NSString *dateString = [self fixNSNull:sample[@"timestamp"]];
        if (dateString) {
            *date = [formatter dateFromString:dateString];
        }
    }
}

@end
