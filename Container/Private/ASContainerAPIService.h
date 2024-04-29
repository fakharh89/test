//
//  ASContainerAPIService.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 1/26/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASContainer;
@class ASSystemManager;
@class ASDevice;

typedef void (^ASSuccessBlock)(void);
typedef void (^ASFailureBlock)(NSError *error);

@interface ASContainerAPIService : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContainer:(ASContainer *)container
                    systemManager:(ASSystemManager *)systemManager NS_DESIGNATED_INITIALIZER;

- (void)putWithSuccess:(ASSuccessBlock)success
               failure:(ASFailureBlock)failure;

- (void)deleteWithSuccess:(ASSuccessBlock)success
                  failure:(ASFailureBlock)failure;

- (void)postWithSuccess:(ASSuccessBlock)success
                failure:(ASFailureBlock)failure;

- (void)postImageWithSuccess:(ASSuccessBlock)success
                     failure:(ASFailureBlock)failure;
- (void)getImageWithSuccess:(ASSuccessBlock)success
                    failure:(ASFailureBlock)failure;

- (void)putDeviceLink:(ASDevice *)device
    authenticationKey:(NSData *)key
              success:(ASSuccessBlock)success
              failure:(ASFailureBlock)failure;
- (void)deleteDeviceLinkWithSuccess:(ASSuccessBlock)success
                            failure:(ASFailureBlock)failure;

@end
