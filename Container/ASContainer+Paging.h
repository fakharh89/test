//
//  ASContainer+Paging.h
//  Blustream
//
//  Created by Michael Gordon on 1/21/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASContainer.h"

/**
 *  These constants indicate the type of paging is requested from the server.  It can be used to prune queried data server-side.
 */
typedef NS_ENUM(NSUInteger, ASPagingType) {
    /**
     *  Indicates that the server should return the oldest data samples in the given range.
     */
    ASPagingTypeFirst,
    /**
     *  Indicates that the server should return the newest data samples in the given range.
     */
    ASPagingTypeLast,
    /**
     *  Indicates that the server should return equally spaced (by array index) data samples in a given range.
     */
    ASPagingTypeDistributed,
    /**
     *  Indicates that the server should return the oldest measurements within the ingestion date range.
     */
    ASPagingTypeTakeFirstIngestion,
    /**
     *  Indicates that the server should return the newest measurements within the ingestion date range.
     */
    ASPagingTypeTakeLastIngestion
};

@class ASEnvironmentalMeasurement;
@class ASImpact;
@class ASActivityState;
@class ASBatteryLevel;
@class ASPIOState;
@class ASAIOMeasurement;
@class ASErrorState;
@class ASConnectionEvent;

/**
 *  This category adds methods to `ASContainer` to query the server for data from certain date ranges and variable sorting techniques.
 */
@interface ASContainer (Paging)

/**
 *  Queries the server for environmental data given several search parameters.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param start   The start date (results are inclusive).  If nil, the server will use the date of the oldest data point.
 *  @param end     The end date (results are inclusive).  If nil, the server will use the date of the newest data point.
 *  @param limit   The maximum number of points to return.
 *  @param type    The paging type (see ASPagingType).
 *  @param success The block called upon the operation's success.  Its parameters include the time array, temperature array, and humidity array (correlated by index).
 *  @param failure The block called upon the operation's failure.  Its parameter contains the error information.
 */
- (void)getEnvDataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *temperatures, NSArray *humidities))success failure:(void (^)(NSError *error))failure __attribute__((deprecated));

- (void)getEnvironmentalMeasurementsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASEnvironmentalMeasurement *> *measurements))success failure:(void (^)(NSError *error))failure;

/**
 *  Queries the server for acceleration data given several search parameters.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param start   The start date (results are inclusive).  If nil, the server will use the date of the oldest data point.
 *  @param end     The end date (results are inclusive).  If nil, the server will use the date of the newest data point.
 *  @param limit   The maximum number of points to return.
 *  @param type    The paging type (see ASPagingType).
 *  @param success The block called upon the operation's success.  Its parameters include the time array and acceleration array (correlated by index).
 *  @param failure The block called upon the operation's failure.  Its parameter contains the error information.
 */
- (void)getAccelDataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *magnitudes))success failure:(void (^)(NSError *error))failure __attribute__((deprecated));

- (void)getImpactsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASImpact *> *impacts))success failure:(void (^)(NSError *error))failure;

/**
 *  Queries the server for activity data given several search parameters.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param start   The start date (results are inclusive).  If nil, the server will use the date of the oldest data point.
 *  @param end     The end date (results are inclusive).  If nil, the server will use the date of the newest data point.
 *  @param limit   The maximum number of points to return.
 *  @param type    The paging type (see ASPagingType).
 *  @param success The block called upon the operation's success.  Its parameters include the array of location objects.
 *  @param failure The block called upon the operation's failure.  Its parameter contains the error information.
 */
- (void)getActivityDataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *activityStates))success failure:(void (^)(NSError *error))failure __attribute__((deprecated));

- (void)getActivityStatesFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASActivityState *> *states))success failure:(void (^)(NSError *error))failure;

/**
 *  Queries the server for battery data given several search parameters.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param start   The start date (results are inclusive).  If nil, the server will use the date of the oldest data point.
 *  @param end     The end date (results are inclusive).  If nil, the server will use the date of the newest data point.
 *  @param limit   The maximum number of points to return.
 *  @param type    The paging type (see ASPagingType).
 *  @param success The block called upon the operation's success.  Its parameters include the array of location objects.
 *  @param failure The block called upon the operation's failure.  Its parameter contains the error information.
 */
- (void)getBatteryDataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *batteryValues))success failure:(void (^)(NSError *error))failure __attribute__((deprecated));

- (void)getBatteryLevelsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASBatteryLevel *> *levels))success failure:(void (^)(NSError *error))failure;

/**
 *  Queries the server for PIO data given several search parameters.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param start   The start date (results are inclusive).  If nil, the server will use the date of the oldest data point.
 *  @param end     The end date (results are inclusive).  If nil, the server will use the date of the newest data point.
 *  @param limit   The maximum number of points to return.
 *  @param type    The paging type (see ASPagingType).
 *  @param success The block called upon the operation's success.  Its parameters include the array of location objects.
 *  @param failure The block called upon the operation's failure.  Its parameter contains the error information.
 */
- (void)getPIODataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *PIOData))success failure:(void (^)(NSError *error))failure __attribute__((deprecated));

- (void)getPIOStatesFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASPIOState *> *states))success failure:(void (^)(NSError *error))failure;

/**
 *  Queries the server for AIO data given several search parameters.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param start   The start date (results are inclusive).  If nil, the server will use the date of the oldest data point.
 *  @param end     The end date (results are inclusive).  If nil, the server will use the date of the newest data point.
 *  @param limit   The maximum number of points to return.
 *  @param type    The paging type (see ASPagingType).
 *  @param success The block called upon the operation's success.  Its parameters include the array of location objects.
 *  @param failure The block called upon the operation's failure.  Its parameter contains the error information.
 */
- (void)getAIODataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *AIOData))success failure:(void (^)(NSError *error))failure __attribute__((deprecated));

- (void)getAIOMeasurementsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASAIOMeasurement *> *measurements))success failure:(void (^)(NSError *error))failure;

/**
 *  Queries the server for error state data given several search parameters.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param start   The start date (results are inclusive).  If nil, the server will use the date of the oldest data point.
 *  @param end     The end date (results are inclusive).  If nil, the server will use the date of the newest data point.
 *  @param limit   The maximum number of points to return.
 *  @param type    The paging type (see ASPagingType).
 *  @param success The block called upon the operation's success.  Its parameters include the array of location objects.
 *  @param failure The block called upon the operation's failure.  Its parameter contains the error information.
 */
- (void)getErrorStatesFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *errorStates))success failure:(void (^)(NSError *error))failure __attribute__((deprecated));

- (void)getErrorsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASErrorState *> *errors))success failure:(void (^)(NSError *error))failure;

/**
 *  Queries the server for error state data given several search parameters.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param start   The start date (results are inclusive).  If nil, the server will use the date of the oldest data point.
 *  @param end     The end date (results are inclusive).  If nil, the server will use the date of the newest data point.
 *  @param limit   The maximum number of points to return.
 *  @param type    The paging type (see ASPagingType).
 *  @param success The block called upon the operation's success.  Its parameters include the array of location objects.
 *  @param failure The block called upon the operation's failure.  Its parameter contains the error information.
 */
- (void)getConnectionEventsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASConnectionEvent *> *connectionEvents))success failure:(void (^)(NSError *error))failure;

@end
