//
//  ASAlarmLimits.h
//  Blustream
//
//  Created by Michael Gordon on 7/17/16.
//
//

#import <Foundation/Foundation.h>

@interface ASAlarmLimits : NSObject

@property (strong, readwrite, nonatomic) NSNumber *maximumTemperature;
@property (strong, readwrite, nonatomic) NSNumber *minimumTemperature;
@property (strong, readwrite, nonatomic) NSNumber *maximumHumidity;
@property (strong, readwrite, nonatomic) NSNumber *minimumHumidity;

@end
