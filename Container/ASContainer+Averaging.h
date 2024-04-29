//
//  ASContainer+Averaging.h
//  Blustream
//
//  Created by Michael Gordon on 7/24/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASContainer.h"

@class ASAveragingResponse;

/**
 *  This category adds methods to `ASContainer` to query the server for average, highs, and lows for environmental data and accelerometer data.
 */
@interface ASContainer (Averaging)

/**
 *  Queries the server for the average, high, and low accelerometer, humidity, and temperature data given a container and a date range.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param start   The start date (results are inclusive).  If nil, the server will use the date of the oldest data point.
 *  @param end     The end date (results are inclusive).  If nil, the server will use the date of the newest data point.
 *  @param success The block called upon the operation's success.  Its parameter contains the result of the operation.  @see ASAveragingResponse
 *  @param failure The block called upon the operation's failure.  Its parameter contains the error information.
 */
- (void)getAverageFromDate:(NSDate *)start toDate:(NSDate *)end success:(void (^)(ASAveragingResponse *response))success failure:(void (^)(NSError *error))failure;

@end
