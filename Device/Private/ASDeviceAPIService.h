//
//  ASDeviceAPIService.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 1/22/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASDevice;
@class ASSystemManager;

typedef void (^ASSuccessBlock)(void);
typedef void (^ASFailureBlock)(NSError *error);

@interface ASDeviceAPIService : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDevice:(ASDevice *)device
                 systemManager:(ASSystemManager *)systemManager NS_DESIGNATED_INITIALIZER;

- (void)postWithSuccess:(ASSuccessBlock)success
                failure:(ASFailureBlock)failure;

- (void)putWithSuccess:(ASSuccessBlock)success
               failire:(ASFailureBlock)failure;

- (void)deleteWithSuccess:(ASSuccessBlock)success
                  failure:(ASFailureBlock)failure;

- (void)getWithSuccess:(ASSuccessBlock)success
               failure:(ASFailureBlock)failure;

- (void)getRegistrationFromServerWithSuccess:(void (^)(NSString *registrationCode))success
                                     failure:(ASFailureBlock)failure;

@end
