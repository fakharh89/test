//
//  ASPositionAPIService.h
//  AS-iOS-Framework
//
//  Created by Michael Gordon on 5/2/21.
//  Copyright © 2021 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASSystemManager;
@class ASPosition;

typedef void (^ASSuccessBlock)(ASPosition *position);
typedef void (^ASFailureBlock)(NSError *error);

@interface ASPositionManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager NS_DESIGNATED_INITIALIZER;

- (void)getLatestPositionForThingExtId:(NSString *)thingExtId
                    sensorSerialNumber:(NSString *)serialNumber
                               success:(ASSuccessBlock)success
                               failure:(ASFailureBlock)failure;

- (void)updatePositionForThingExtId:(NSString *)thingExtId
                 sensorSerialNumber:(NSString *)serialNumber
                      positionExtId:(NSString *)positionExtId
                            success:(ASSuccessBlock)success
                            failure:(ASFailureBlock)failure;

- (void)updatePositionForThingExtId:(NSString *)thingExtId
                 sensorSerialNumber:(NSString *)serialNumber
                      positionExtId:(NSString *)positionExtId
                              start:(NSDate *)start
                                end:(NSDate *)end
                            success:(ASSuccessBlock)success
                            failure:(ASFailureBlock)failure;

@end
