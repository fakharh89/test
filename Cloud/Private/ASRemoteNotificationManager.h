//
//  ASRemoteNotificationManager.h
//  Pods
//
//  Created by Michael Gordon on 10/3/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@class ASHub;
@class ASSystemManager;

@interface ASRemoteNotificationManager : NSObject

@property (nonatomic, assign, readonly) BOOL syncingHubs;
@property (nonatomic, strong, readonly) ASHub *currentHub;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager NS_DESIGNATED_INITIALIZER;

- (void)setupRemoteNotifications:(void (^)(BOOL *granted))completion;

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token;

- (void)resetHubs;

- (void)sendRemoteNotificationToAllDevicesWithTitle:(NSString *)title message:(NSString *)message playSound:(BOOL)sound bundleIdentifier:(NSString *)bundleIdentifier completion:(void (^)(NSError *error))completion;

- (void)sendSilentNotificationToAllDevicesWithPayload:(NSDictionary *)payload
                                              success:(void (^)(void))success
                                              failure:(void (^)(NSError *))failure;

@end
