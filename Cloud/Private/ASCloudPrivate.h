//
//  ASCloudPrivate.h
//  Blustream
//
//  Created by Michael Gordon on 12/7/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASCloud.h"

@class ASSystemManager, ASUser, AFHTTPSessionManager, ASPUTQueue, ASDevice, ASSyncManager, ASRemoteNotificationManager;

dispatch_queue_t cloud_processing_queue(void);

@interface ASCloud ()

@property (nonatomic, weak, readonly) ASSystemManager *systemManager;
@property (nonatomic, assign) ASUserState userStatus;
@property (nonatomic, strong) ASUser *user;
@property (nonatomic, strong) AFHTTPSessionManager *HTTPManager;
@property (nonatomic, strong) ASPUTQueue *PUTQueue;
@property (nonatomic, strong) ASSyncManager *syncManager;
@property (nonatomic, strong) ASRemoteNotificationManager *remoteNotificationManager;
@property (nonatomic, strong) ASPurchasingManager *purchasingManager;

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager NS_DESIGNATED_INITIALIZER;

- (void)handleUserLogoutWithError:(NSError *)error;
- (void)saveUser;

@end
