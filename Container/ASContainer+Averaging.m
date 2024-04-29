//
//  ASContainer+Averaging.m
//  Blustream
//
//  Created by Michael Gordon on 7/24/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASContainer+Averaging.h"

#import "AFHTTPSessionManager.h"
#import "ASAveragingResponsePrivate.h"
#import "ASBLEInterface.h"
#import "ASConfig.h"
#import "ASContainerPrivate.h"
#import "ASCloudPrivate.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASSystemManager.h"
#import "ASDateFormatter.h"
#import "NSError+ASError.h"

@implementation ASContainer (Averaging)

#pragma mark - Public Methods

// TODO See if ASAveragingResponse can use ASMeasurementInterval or ASImpact

- (void)getAverageFromDate:(NSDate *)start toDate:(NSDate *)end success:(void (^)(ASAveragingResponse *response))success failure:(void (^)(NSError *error))failure {
    dispatch_async(self.processingQueue, ^{
        NSString *url = [NSString stringWithFormat:@"containers/%@/data/average/", self.identifier];
        
        NSDictionary *parameters = [self formatAveragingParametersFromDate:start toDate:end];
        
        [ASSystemManager.shared.cloud.HTTPManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    success([[ASAveragingResponse alloc] initWithDictionary:responseObject]);
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

- (NSDictionary *)formatAveragingParametersFromDate:(NSDate *)start toDate:(NSDate *)end {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
    
    if (start) {
        [parameters addEntriesFromDictionary:@{@"start":[formatter stringFromDate:start]}];
    }
    
    if (end) {
        [parameters addEntriesFromDictionary:@{@"end":[formatter stringFromDate:end]}];
    }
    
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end
