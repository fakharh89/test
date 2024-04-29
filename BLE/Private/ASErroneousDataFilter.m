//
//  ASErroneousDataFilter.m
//  AS-iOS-Framework
//
//  Created by Michael Gordon on 7/7/21.
//  Copyright © 2021 Blustream Corporation. All rights reserved.
//

#import "ASErroneousDataFilter.h"

#import "ASEnvironmentalMeasurement.h"

@implementation ASErroneousDataFilter

+ (BOOL)isEnvironmentalMeasurementValid:(ASEnvironmentalMeasurement *)measurement {
    if (!measurement) {
        return NO;
    }
    
    // We multiply all of these by 100 to get rid of floating point noise
    int tempX100 = (int)round(measurement.temperature.floatValue * 100.0);
    int humiX100 = (int)round(measurement.humidity.floatValue * 100.0);
    
    // Original comparisons: temp == 0, temp > 100, temp == -0.01, temp == 1.28, temp == 64
    if (tempX100 == 0 || tempX100 > 10000 || tempX100 == -1 || tempX100 == 128 || tempX100 == 6400) {
        return NO;
    }
    
    // Original comparisons: humi <= 1
    if (humiX100 <= 100) {
        return NO;
    }
    
    return ![self isCorruptPairTemperatureX100:tempX100 humidityX100:humiX100];
}

+ (BOOL)isCorruptPairTemperatureX100:(int)tempX100 humidityX100:(int)humiX100 {
    // Original comparisons:
    // (temp == -8.97, humi == 25.71)
    // (temp == -1.33, humi == 7.69)
    // (temp == -9.01, humi == 5.23)
    // (temp == 5.12, humi == 5.84)
    // (temp == 36, humi == 35.67)
    return (tempX100 == -897 && humiX100 == 2571) ||
            (tempX100 == -133 && humiX100 == 769) ||
            (tempX100 == -901 && humiX100 == 523) ||
            (tempX100 == 512 && humiX100 == 584) ||
            (tempX100 == 3600 && humiX100 == 3567);
}

@end
