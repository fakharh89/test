//
//  ASErroneousDataFilter.h
//  AS-iOS-Framework
//
//  Created by Michael Gordon on 7/7/21.
//  Copyright © 2021 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ASEnvironmentalMeasurement;

// Used to filter out corrupt Taylor data before new firmware version is rolled out.
// Should only be used on Taylor v3 sensors!

@interface ASErroneousDataFilter : NSObject

+ (BOOL)isEnvironmentalMeasurementValid:(ASEnvironmentalMeasurement *)measurement;

@end

NS_ASSUME_NONNULL_END
