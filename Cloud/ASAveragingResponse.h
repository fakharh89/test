//
//  ASAveragingResponse.h
//  Blustream
//
//  Created by Michael Gordon on 7/24/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

/**
 *  This class contains the data that is returned from the server after requesting
 *  the average data for a container.  See ASContainer+Averaging to request for the
 *  methods that request this data.
 */
@interface ASAveragingResponse : NSObject

/**
 *  The average accelerometer spikes in g's for the given date range. (read-only)
 *
 *  This mean is not weighted based on date.  It is the sum of all of the g force
 *  spikes divided by the number of g force spikes in the given date range.  If nil,
 *  the date range contains no accelerometer spikes in the given date range.
 */
@property (strong, readonly, nonatomic) NSNumber *accelerometerAverage;

/**
 *  The maximum accelerometer spike in g's for the given date range. (read-only)
 *
 *  If nil, the date range contains no accelerometer spikes in the given date range.
 */
@property (strong, readonly, nonatomic) NSNumber *accelerometerHigh;

/**
 *  The date of the maximum accelerometer spike in the given date range. (read-only)
 *
 *  If nil, the date range contains no accelerometer spikes in the given date range.
 */
@property (strong, readonly, nonatomic) NSDate *accelerometerHighDate;

/**
 *  The minimum accelerometer spike in g's for the given date range. (read-only)
 *
 *  If nil, the date range contains no accelerometer spikes in the given date range.
 */
@property (strong, readonly, nonatomic) NSNumber *accelerometerLow;

/**
 *  The date of the minimum accelerometer spike in the given date range. (read-only)
 *
 *  If nil, the date range contains no accelerometer spikes in the given date range.
 */
@property (strong, readonly, nonatomic) NSDate *accelerometerLowDate;

/**
 *  The average humidity in %RH for the given date range. (read-only)
 *
 *  This mean is weighted to account for the variable time difference between each
 *  data point.  It is calculated by integrating the data over the range and dividing
 *  by the time difference between the first and last points.  Specifically, it uses
 *  the trapezoidal rule to perform the numerical integration.  If nil, the date range
 *  contains no environmental data.
 */
@property (strong, readonly, nonatomic) NSNumber *humidityAverage;

/**
 *  The maximum humidity in %RH for the given date range. (read-only)
 *
 *  If nil, the date range contains no environmental data.
 */
@property (strong, readonly, nonatomic) NSNumber *humidityHigh;

/**
 *  The date of the maximum humidity in the given date range. (read-only)
 *
 *  If nil, the date range contains no environmental data.
 */
@property (strong, readonly, nonatomic) NSDate *humidityHighDate;

/**
 *  The minimum humidity in %RH for the given date range. (read-only)
 *
 *  If nil, the date range contains no environmental data.
 */
@property (strong, readonly, nonatomic) NSNumber *humidityLow;

/**
 *  The date of the minimum humidity in the given date range. (read-only)
 *
 *  If nil, the date range contains no environmental data.
 */
@property (strong, readonly, nonatomic) NSDate *humidityLowDate;

/**
 *  The average temperature in °C for the given date range. (read-only)
 *
 *  This mean is weighted to account for the variable time difference between each
 *  data point.  It is calculated by integrating the data over the range and dividing
 *  by the time difference between the first and last points.  Specifically, it uses
 *  the trapezoidal rule to perform the numerical integration.  If nil, the date range
 *  contains no environmental data.
 */
@property (strong, readonly, nonatomic) NSNumber *temperatureAverage;

/**
 *  The maximum temperature in °C for the given date range. (read-only)
 *
 *  If nil, the date range contains no environmental data.
 */
@property (strong, readonly, nonatomic) NSNumber *temperatureHigh;

/**
 *  The date of the maximum humidity in the given date range. (read-only)
 *
 *  If nil, the date range contains no environmental data.
 */
@property (strong, readonly, nonatomic) NSDate *temperatureHighDate;

/**
 *  The minimum temperature in °C for the given date range. (read-only)
 *
 *  If nil, the date range contains no environmental data.
 */
@property (strong, readonly, nonatomic) NSNumber *temperatureLow;

/**
 *  The date of the minimum temperature in the given date range. (read-only)
 *
 *  If nil, the date range contains no environmental data.
 */
@property (strong, readonly, nonatomic) NSDate *temperatureLowDate;

@end
