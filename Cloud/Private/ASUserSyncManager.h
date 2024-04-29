//
//  ASSyncUserManager.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 12/28/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASSystemManager;
@class ASUser;
@class ASUserAPIService;

typedef void (^ASSuccessBlock)(void);
typedef void (^ASFailureBlock)(NSError *error);

@interface ASUserSyncManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithUser:(ASUser *)user
               systemManager:(ASSystemManager *)systemManager
                  apiService:(ASUserAPIService *)apiService;

- (void)synchronizeWithSuccess:(ASSuccessBlock)success
                       failure:(ASFailureBlock)failure;

@end
