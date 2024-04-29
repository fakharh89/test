//
//  ASDevice+Paging.m
//  Blustream
//
//  Created by Michael Gordon on 1/21/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASContainer+Paging.h"

#import "AFHTTPSessionManager.h"
#import "ASBLEInterface.h"
#import "ASConfig.h"
#import "ASContainerPrivate.h"
#import "ASCloudPrivate.h"
#import "ASErrorDefinitions.h"
#import "ASSystemManager.h"
#import "ASDateFormatter.h"
#import "NSError+ASError.h"

#import "ASEnvironmentalMeasurement.h"
#import "ASAIOMeasurement.h"
#import "ASPIOState.h"
#import "ASBatteryLevel.h"
#import "ASErrorState.h"
#import "ASActivityState.h"
#import "ASImpact.h"
#import "ASConnectionEventPrivate.h"

@implementation ASContainer (Paging)

#pragma mark - Public Methods

- (void)getEnvDataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *temperatures, NSArray *humidities))success failure:(void (^)(NSError *error))failure {
    
    if ((type == ASPagingTypeTakeLastIngestion) || (type == ASPagingTypeTakeFirstIngestion)) {
        NSAssert(NO, @"ASPagingTypeTakeLastIngestion and ASPagingTypeTakeFirstIngestion not available in deprecated methods.");
        return;
    }
    
    [self getEnvironmentalMeasurementsFromDate:start toDate:end limit:limit pagingType:type success:^(NSArray<ASEnvironmentalMeasurement *> *measurements) {
        if (!success) {
            return;
        }
        // TODO There is a little bit of overhead by letting the old code run on the completion queue before success is called
        // Probably not worth adjusting
        dispatch_async(self.processingQueue, ^{
            NSArray *times = [measurements valueForKeyPath:@"date"];
            NSArray *humidities = [measurements valueForKeyPath:@"humidity"];
            NSArray *temperatures = [measurements valueForKeyPath:@"temperature"];
            
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                success(times, temperatures, humidities);
            });
        });
    } failure:failure];
}

- (void)getEnvironmentalMeasurementsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASEnvironmentalMeasurement *> *measurements))success failure:(void (^)(NSError *error))failure {
    dispatch_async(self.processingQueue, ^{
        
        NSString *url = [NSString stringWithFormat:@"containers/%@/data/ambient/", self.identifier];
        
        NSDictionary *parameters = [self formatPagingParametersFromDate:start toDate:end limit:limit pagingType:type];
        
        [ASSystemManager.shared.cloud.HTTPManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableArray<ASEnvironmentalMeasurement *> *measurements = [[NSMutableArray alloc] init];
            
            NSArray<NSString *> *timeStrings = [responseObject[@"ambientSamples"] valueForKeyPath:@"timestamp"];
            NSArray<NSNumber *> *humidity = [responseObject[@"ambientSamples"] valueForKeyPath:@"humidityRH"];
            NSArray<NSNumber *> *temp = [responseObject[@"ambientSamples"] valueForKeyPath:@"temperatureC"];
            NSArray<NSString *> *ingestionTimeStrings = [responseObject[@"ambientSamples"] valueForKeyPath:@"ingestionTimestamp"];
            
            ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
            
            for (int i = 0; i < timeStrings.count; i++) {
                NSDate *date = [formatter dateFromString:timeStrings[i]];
                NSDate *ingestionDate = [formatter dateFromString:ingestionTimeStrings[i]];
                ASEnvironmentalMeasurement *measurement = [[ASEnvironmentalMeasurement alloc] initWithDate:date ingestionDate:ingestionDate humidity:humidity[i] temperature:temp[i]];
                [measurements addObject:measurement];
            }
            
            if (success) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    success([NSArray arrayWithArray:measurements]);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSInteger errorCode = response.statusCode;
            
            switch (errorCode) {
                case 401:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorInvalidCredentials underlyingError:error];
                    break;
                case 404:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorNoDataAvailable underlyingError:error];
                    break;
                default:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
                    break;
            }
            
            [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
            
            if (failure) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }];
    });
}

- (void)getAccelDataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *magnitudes))success failure:(void (^)(NSError *error))failure {
    
    if ((type == ASPagingTypeTakeLastIngestion) || (type == ASPagingTypeTakeFirstIngestion)) {
        NSAssert(NO, @"ASPagingTypeTakeLastIngestion and ASPagingTypeTakeFirstIngestion not available in deprecated methods.");
        return;
    }
    
    [self getImpactsFromDate:start toDate:end limit:limit pagingType:type success:^(NSArray<ASImpact *> *impacts) {
        if (!success) {
            return;
        }
        dispatch_async(self.processingQueue, ^{
            NSArray *times = [impacts valueForKeyPath:@"date"];
            NSArray *magnitudes = [impacts valueForKeyPath:@"magnitude"];
            
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                success(times, magnitudes);
            });
        });
    } failure:failure];
}

- (void)getImpactsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASImpact *> *impacts))success failure:(void (^)(NSError *error))failure {
    dispatch_async(self.processingQueue, ^{
        
        NSString *url = [NSString stringWithFormat:@"containers/%@/data/accelerometer", self.identifier];
        
        NSDictionary *parameters = [self formatPagingParametersFromDate:start toDate:end limit:limit pagingType:type];
        [ASSystemManager.shared.cloud.HTTPManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableArray<ASImpact *> *impacts = [[NSMutableArray alloc] init];
            
            NSArray<NSString *> *timeStrings = [responseObject[@"accelerometerSamples"] valueForKeyPath:@"timestamp"];
            NSArray<NSNumber *> *magnitude = [responseObject[@"accelerometerSamples"] valueForKeyPath:@"magnitudeG"];
            NSArray<NSString *> *ingestionTimeStrings = [responseObject[@"accelerometerSamples"] valueForKeyPath:@"ingestionTimestamp"];
            
            ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
            
            for (int i = 0; i < timeStrings.count; i++) {
                NSDate *date = [formatter dateFromString:timeStrings[i]];
                NSDate *ingestionDate = [formatter dateFromString:ingestionTimeStrings[i]];
                ASImpact *impact = [[ASImpact alloc] initWithDate:date ingestionDate:ingestionDate magnitude:magnitude[i]];
                [impacts addObject:impact];
            }
            
            if (success) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    success([NSArray arrayWithArray:impacts]);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSInteger errorCode = response.statusCode;
            
            switch (errorCode) {
                case 401:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorInvalidCredentials underlyingError:error];
                    break;
                case 404:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorNoDataAvailable underlyingError:error];
                    break;
                default:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
                    break;
            }
            
            [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
            
            if (failure) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }];
    });
}

- (void)getActivityDataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *activityStates))success failure:(void (^)(NSError *error))failure {
    
    if ((type == ASPagingTypeTakeLastIngestion) || (type == ASPagingTypeTakeFirstIngestion)) {
        NSAssert(NO, @"ASPagingTypeTakeLastIngestion and ASPagingTypeTakeFirstIngestion not available in deprecated methods.");
        return;
    }
    
    [self getActivityStatesFromDate:start toDate:end limit:limit pagingType:type success:^(NSArray<ASActivityState *> *states) {
        if (!success) {
            return;
        }
        dispatch_async(self.processingQueue, ^{
            NSArray *times = [states valueForKeyPath:@"date"];
            NSArray *stateValues = [states valueForKeyPath:@"state"];
            
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                success(times, stateValues);
            });
        });
    } failure:failure];
}

- (void)getActivityStatesFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASActivityState *> *states))success failure:(void (^)(NSError *error))failure {
    dispatch_async(self.processingQueue, ^{
        
        NSString *url = [NSString stringWithFormat:@"containers/%@/data/activity/", self.identifier];
        
        NSDictionary *parameters = [self formatPagingParametersFromDate:start toDate:end limit:limit pagingType:type];
        
        [ASSystemManager.shared.cloud.HTTPManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableArray<ASActivityState *> *states = [[NSMutableArray alloc] init];
            
            NSArray<NSString *> *timeStrings = [responseObject[@"activitySamples"] valueForKeyPath:@"timestamp"];
            NSArray<NSNumber *> *stateValues = [responseObject[@"activitySamples"] valueForKeyPath:@"state"];
            NSArray<NSString *> *ingestionTimeStrings = [responseObject[@"activitySamples"] valueForKeyPath:@"ingestionTimestamp"];
            
            ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
            
            for (int i = 0; i < timeStrings.count; i++) {
                NSDate *date = [formatter dateFromString:timeStrings[i]];
                NSDate *ingestionDate = [formatter dateFromString:ingestionTimeStrings[i]];
                ASActivityState *state = [[ASActivityState alloc] initWithDate:date ingestionDate:ingestionDate activityState:stateValues[i]];
                [states addObject:state];
            }
            
            if (success) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    success([NSArray arrayWithArray:states]);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSInteger errorCode = response.statusCode;
            
            switch (errorCode) {
                case 401:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorInvalidCredentials underlyingError:error];
                    break;
                case 404:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorNoDataAvailable underlyingError:error];
                    break;
                default:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
                    break;
            }
            
            [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
            
            if (failure) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }];
    });
}

- (void)getBatteryDataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *batteryValues))success failure:(void (^)(NSError *error))failure {
    
    if ((type == ASPagingTypeTakeLastIngestion) || (type == ASPagingTypeTakeFirstIngestion)) {
        NSAssert(NO, @"ASPagingTypeTakeLastIngestion and ASPagingTypeTakeFirstIngestion not available in deprecated methods.");
        return;
    }
    
    [self getBatteryLevelsFromDate:start toDate:end limit:limit pagingType:type success:^(NSArray<ASBatteryLevel *> *levels) {
        if (!success) {
            return;
        }
        dispatch_async(self.processingQueue, ^{
            NSArray *times = [levels valueForKeyPath:@"date"];
            NSArray *levelValues = [levels valueForKeyPath:@"level"];
            
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                success(times, levelValues);
            });
        });
    } failure:failure];
}

- (void)getBatteryLevelsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASBatteryLevel *> *levels))success failure:(void (^)(NSError *error))failure {
    dispatch_async(self.processingQueue, ^{
        NSString *url = [NSString stringWithFormat:@"containers/%@/data/battery/", self.identifier];
        
        NSDictionary *parameters = [self formatPagingParametersFromDate:start toDate:end limit:limit pagingType:type];
        
        [ASSystemManager.shared.cloud.HTTPManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableArray<ASBatteryLevel *> *levels = [[NSMutableArray alloc] init];
            
            NSArray<NSString *> *timeStrings = [responseObject[@"batterySamples"] valueForKeyPath:@"timestamp"];
            NSArray<NSNumber *> *levelValues = [responseObject[@"batterySamples"] valueForKeyPath:@"level"];
            NSArray<NSString *> *ingestionTimeStrings = [responseObject[@"batterySamples"] valueForKeyPath:@"ingestionTimestamp"];
            
            ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
            
            for (int i = 0; i < timeStrings.count; i++) {
                NSDate *date = [formatter dateFromString:timeStrings[i]];
                NSDate *ingestionDate = [formatter dateFromString:ingestionTimeStrings[i]];
                ASBatteryLevel *level = [[ASBatteryLevel alloc] initWithDate:date ingestionDate:ingestionDate batteryLevel:levelValues[i]];
                [levels addObject:level];
            }
            
            if (success) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    success([NSArray arrayWithArray:levels]);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSInteger errorCode = response.statusCode;
            
            switch (errorCode) {
                case 401:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorInvalidCredentials underlyingError:error];
                    break;
                case 404:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorNoDataAvailable underlyingError:error];
                    break;
                default:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
                    break;
            }
            
            [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
            
            if (failure) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }];
    });
}

- (void)getPIODataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *PIOData))success failure:(void (^)(NSError *error))failure {
    
    if ((type == ASPagingTypeTakeLastIngestion) || (type == ASPagingTypeTakeFirstIngestion)) {
        NSAssert(NO, @"ASPagingTypeTakeLastIngestion and ASPagingTypeTakeFirstIngestion not available in deprecated methods.");
        return;
    }
    
    [self getPIOStatesFromDate:start toDate:end limit:limit pagingType:type success:^(NSArray<ASPIOState *> *states) {
        if (!success) {
            return;
        }
        dispatch_async(self.processingQueue, ^{
            NSArray *times = [states valueForKeyPath:@"date"];
            NSArray *stateValues = [states valueForKeyPath:@"state"];
            
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                success(times, stateValues);
            });
        });
    } failure:failure];
}

- (void)getPIOStatesFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASPIOState *> *))success failure:(void (^)(NSError *error))failure {
    NSAssert(NO, @"Function doesn't exist yet");
}

- (void)getAIODataFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *AIOData))success failure:(void (^)(NSError *error))failure {
    
    if ((type == ASPagingTypeTakeLastIngestion) || (type == ASPagingTypeTakeFirstIngestion)) {
        NSAssert(NO, @"ASPagingTypeTakeLastIngestion and ASPagingTypeTakeFirstIngestion not available in deprecated methods.");
        return;
    }
    
    [self getAIOMeasurementsFromDate:start toDate:end limit:limit pagingType:type success:^(NSArray<ASAIOMeasurement *> *measurements) {
        if (!success) {
            return;
        }
        dispatch_async(self.processingQueue, ^{
            NSArray *times = [measurements valueForKeyPath:@"date"];
            NSArray *measurementValues = [measurements valueForKeyPath:@"voltages"];
            
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                success(times, measurementValues);
            });
        });
    } failure:failure];
}

- (void)getAIOMeasurementsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASAIOMeasurement *> *))success failure:(void (^)(NSError *error))failure {
    NSAssert(NO, @"Function doesn't exist yet");
}

- (void)getErrorStatesFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray *times, NSArray *errorStates))success failure:(void (^)(NSError *error))failure {
    
    if ((type == ASPagingTypeTakeLastIngestion) || (type == ASPagingTypeTakeFirstIngestion)) {
        NSAssert(NO, @"ASPagingTypeTakeLastIngestion and ASPagingTypeTakeFirstIngestion not available in deprecated methods.");
        return;
    }
    
    [self getErrorsFromDate:start toDate:end limit:limit pagingType:type success:^(NSArray<ASErrorState *> *errors) {
        if (!success) {
            return;
        }
        dispatch_async(self.processingQueue, ^{
            NSArray *times = [errors valueForKeyPath:@"date"];
            NSArray *stateValues = [errors valueForKeyPath:@"state"];
            
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                success(times, stateValues);
            });
        });
    } failure:failure];
}

- (void)getErrorsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASErrorState *> *))success failure:(void (^)(NSError *error))failure {
    dispatch_async(self.processingQueue, ^{
        
        NSString *url = [NSString stringWithFormat:@"containers/%@/data/errorState/", self.identifier];
        
        NSDictionary *parameters = [self formatPagingParametersFromDate:start toDate:end limit:limit pagingType:type];
        
        [ASSystemManager.shared.cloud.HTTPManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableArray<ASErrorState *> *states = [[NSMutableArray alloc] init];
            
            NSArray<NSString *> *timeStrings = [responseObject[@"errorStateSamples"] valueForKeyPath:@"timestamp"];
            NSArray<NSNumber *> *stateValues = [responseObject[@"errorStateSamples"] valueForKeyPath:@"errorState"];
            NSArray<NSString *> *ingestionTimeStrings = [responseObject[@"errorStateSamples"] valueForKeyPath:@"ingestionTimestamp"];
            
            ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
            
            for (int i = 0; i < timeStrings.count; i++) {
                NSDate *date = [formatter dateFromString:timeStrings[i]];
                NSDate *ingestionDate = [formatter dateFromString:ingestionTimeStrings[i]];
                ASErrorState *state = [[ASErrorState alloc] initWithDate:date ingestionDate:ingestionDate errorState:stateValues[i]];
                [states addObject:state];
            }
            
            if (success) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    success([NSArray arrayWithArray:states]);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSInteger errorCode = response.statusCode;
            
            switch (errorCode) {
                case 401:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorInvalidCredentials underlyingError:error];
                    break;
                    
                default:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
                    break;
            }
            
            [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
            
            if (failure) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }];
    });
}

- (void)getConnectionEventsFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type success:(void (^)(NSArray<ASConnectionEvent *> *connectionEvents))success failure:(void (^)(NSError *error))failure {
    dispatch_async(self.processingQueue, ^{
        NSString *url = [NSString stringWithFormat:@"containers/%@/data/connection/", self.identifier];
        
        NSDictionary *parameters = [self formatPagingParametersFromDate:start toDate:end limit:limit pagingType:type];
        
        [ASSystemManager.shared.cloud.HTTPManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableArray<ASConnectionEvent *> *events = [[NSMutableArray alloc] init];
            
            NSArray<NSString *> *timeStrings = [responseObject[@"connectionSamples"] valueForKeyPath:@"timestamp"];
            NSArray<NSString *> *typeValues = [responseObject[@"connectionSamples"] valueForKeyPath:@"state"];
            NSArray<NSString *> *reasonValues = [responseObject[@"connectionSamples"] valueForKeyPath:@"reason"];
            NSArray<NSString *> *ingestionTimeStrings = [responseObject[@"connectionSamples"] valueForKeyPath:@"ingestionTimestamp"];
            NSArray<NSString *> *hubIdentifierStrings = [responseObject[@"connectionSamples"] valueForKeyPath:@"hubId"];
            
            ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
            
            for (int i = 0; i < timeStrings.count; i++) {
                NSDate *date = [formatter dateFromString:timeStrings[i]];
                NSDate *ingestionDate = [formatter dateFromString:ingestionTimeStrings[i]];
                ASConnectionEventReason reason = [ASConnectionEvent reasonForString:reasonValues[i]];
                ASConnectionEventType type = [ASConnectionEvent typeForString:typeValues[i]];
                NSString *hubIdentifier = hubIdentifierStrings[i];
                ASConnectionEvent *event = [[ASConnectionEvent alloc] initWithDate:date ingestionDate:ingestionDate hubIdentifier:hubIdentifier type:type reason:reason];
                [events addObject:event];
            }
            
            if (success) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    success([NSArray arrayWithArray:events]);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSInteger errorCode = response.statusCode;
            
            switch (errorCode) {
                case 401:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorInvalidCredentials underlyingError:error];
                    break;
                    
                default:
                    error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
                    break;
            }
            
            [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
            
            if (failure) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }];
    });
}

#pragma mark - Private Methods

- (NSDictionary *)formatPagingParametersFromDate:(NSDate *)start toDate:(NSDate *)end limit:(int)limit pagingType:(ASPagingType)type {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    switch (type) {
        case ASPagingTypeDistributed: {
            [parameters addEntriesFromDictionary:@{@"pageFormat":@"TakeEach"}];
            break;
        }
            
        case ASPagingTypeFirst: {
            [parameters addEntriesFromDictionary:@{@"pageFormat":@"TakeFirst"}];
            break;
        }
            
        case ASPagingTypeLast: {
            [parameters addEntriesFromDictionary:@{@"pageFormat":@"TakeLast"}];
            break;
        }
            
        case ASPagingTypeTakeFirstIngestion: {
            [parameters addEntriesFromDictionary:@{@"pageFormat":@"TakeFirstIngestion"}];
            break;
        }
            
        case ASPagingTypeTakeLastIngestion: {
            [parameters addEntriesFromDictionary:@{@"pageFormat":@"TakeLastIngestion"}];
            break;
        }
            
        default: {
            NSAssert(false, @"Invalid paging type");
            break;
        }
    }
    
    ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
    
    if (start) {
        [parameters addEntriesFromDictionary:@{@"start":[formatter stringFromDate:start]}];
    }
    
    if (end) {
        [parameters addEntriesFromDictionary:@{@"end":[formatter stringFromDate:end]}];
    }
    
    [parameters addEntriesFromDictionary:@{@"limit":@(limit)}];
    
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end
