//
//  ASDeviceSyncManager.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 1/24/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASSystemManager;
@class ASDevice;
@class ASDeviceAPIService;

typedef void (^ASSuccessBlock)(void);
typedef void (^ASFailureBlock)(NSError *error);

@interface ASDeviceSyncManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDevice:(ASDevice *)device
               systemManager:(ASSystemManager *)systemManager
                  apiService:(ASDeviceAPIService *)apiService;

- (void)synchronizeWithSuccess:(ASSuccessBlock)success
                       failure:(ASFailureBlock)failure;

@end
