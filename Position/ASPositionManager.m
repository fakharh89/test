//
//  ASPositionAPIService.m
//  AS-iOS-Framework
//
//  Created by Michael Gordon on 5/2/21.
//  Copyright © 2021 Blustream Corporation. All rights reserved.
//

#import "ASPositionManager.h"

#import "ASSystemManager.h"
#import "ASCloudPrivate.h"
#import "ASUserPrivate.h"
#import "AFHTTPSessionManager.h"
#import "ASDateFormatter.h"
#import "ASPosition.h"
#import "ASConfig.h"

static NSString * const ASGetLatestPositionURLFormat = @"things/%@/sensors/%@/position-latest";
static NSString * const ASUpdatePositionURLFormat = @"things/%@/sensors/%@/positions/%@";

@interface ASPositionManager()

@property (nonatomic, weak) ASSystemManager *systemManager;

@end

@implementation ASPositionManager

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _systemManager = systemManager;
    }
    
    return self;
}

- (void)getLatestPositionForThingExtId:(NSString *)thingExtId
                    sensorSerialNumber:(NSString *)serialNumber
                               success:(ASSuccessBlock)success
                               failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:ASGetLatestPositionURLFormat, thingExtId, serialNumber];
    
    [self.systemManager.cloud.HTTPManager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            ASPosition *position = [[ASPosition alloc] initWithDictionary:responseObject];
            dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                success(position);
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}

- (void)updatePositionForThingExtId:(NSString *)thingExtId
                 sensorSerialNumber:(NSString *)serialNumber
                      positionExtId:(NSString *)positionExtId
                            success:(ASSuccessBlock)success
                            failure:(ASFailureBlock)failure {
    [self updatePositionForThingExtId:thingExtId sensorSerialNumber:serialNumber positionExtId:positionExtId start:nil end:nil success:success failure:failure];
}

- (void)updatePositionForThingExtId:(NSString *)thingExtId
                 sensorSerialNumber:(NSString *)serialNumber
                      positionExtId:(NSString *)positionExtId
                              start:(NSDate *)start
                                end:(NSDate *)end
                            success:(ASSuccessBlock)success
                            failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:ASUpdatePositionURLFormat, thingExtId, serialNumber, positionExtId];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (start) {
        [parameters addEntriesFromDictionary:@{@"start": [[ASDateFormatter new] stringFromDate:start]}];
    }
    if (end) {
        [parameters addEntriesFromDictionary:@{@"end": [[ASDateFormatter new] stringFromDate:end]}];
    }
    
    [self.systemManager.cloud.HTTPManager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            ASPosition *position = [[ASPosition alloc] initWithDictionary:responseObject];
            dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                success(position);
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}

@end
