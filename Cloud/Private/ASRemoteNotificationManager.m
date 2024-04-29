//
//  ASRemoteNotificationManager.m
//  Pods
//
//  Created by Michael Gordon on 10/3/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASRemoteNotificationManager.h"

#import <UserNotifications/UserNotifications.h>
#import "ASCloudPrivate.h"
#import "ASConfig.h"
#import "ASHub.h"
#import "ASHub+RESTAPI.h"
#import "ASLog.h"
#import "ASSystemManager.h"
#import "ASUser.h"
#import "NSString+ASHexString.h"
#import "ASUserAPIService.h"

@interface ASRemoteNotificationManager ()

@property (nonatomic, weak) ASSystemManager *systemManager;
@property (nonatomic, assign) BOOL syncingHubs;
@property (nonatomic, strong) ASHub *currentHub;

@end

@implementation ASRemoteNotificationManager

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _systemManager = systemManager;
    }
    
    return self;
}

- (void)setupRemoteNotifications:(void (^)(BOOL *granted))completion {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                ASLog(@"User registered for notifications");
            });
        }
        else {
            ASLog(@"Error: No User notification type selected");
        }
        
        if (completion) {
            completion(granted);
        }
    }];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token {
    dispatch_async(cloud_processing_queue(), ^{
        if (self.systemManager.cloud.userStatus == ASUserLoggedOut) {
            return;
        }
        
        if (self.syncingHubs) {
            return;
        }
        
        self.syncingHubs = YES;
        
        ASUserAPIService *userService = [[ASUserAPIService alloc] initWithUser:self.systemManager.cloud.user systemManager:self.systemManager];
        
        [userService getHubsWithSuccess:^(NSArray<ASHub *> *hubs) {
            NSString *stringToken = [NSString as_hexStringWithData:token];
            // If token isn't in hub list, put it in list
            ASHub *currentHub = nil;
            for (ASHub *hub in hubs) {
                if ([stringToken caseInsensitiveCompare:hub.notificationTokenID] == NSOrderedSame) {
                    currentHub = hub;
                    break;
                }
            }
            
            BOOL enableSilentNotifications = ASSystemManager.shared.config.enableSilentNotifications;
            
            if (currentHub) {
                self.currentHub = currentHub;
                self.syncingHubs = NO;
                
                if (!currentHub.subscribedToSilentNotifications && enableSilentNotifications) {
                    [self subscribeHubToSilentNotifications:currentHub];
                }
                
                return;
            }
            
            ASLog(@"Hub is missing - adding it");
            ASHub *hub = [[ASHub alloc] initWithToken:token subscribedToSilentNotifications:enableSilentNotifications];
            [hub putWithCompletion:^(NSError *error) {
                if (error) {
                    ASLog(@"Couldn't put hub: %@", error);
                }
                else {
                    self.currentHub = hub;
                    ASLog(@"Put hub!");
                }
                self.syncingHubs = NO;
            }];
        } failure:^(NSError *error) {
            ASLog(@"Failed to get user's hubs: %@", error);
            [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
            self.syncingHubs = NO;
        }];
    });
}

- (void)subscribeHubToSilentNotifications:(ASHub *)hub {
    ASUserAPIService *userService = [[ASUserAPIService alloc] initWithUser:self.systemManager.cloud.user systemManager:self.systemManager];
    
    [userService subscribeHubToSilentNotifications:hub withSuccess:^(ASHub *hub) {
        self.currentHub = hub;
    } failure:nil];
}

- (void)resetHubs {
    self.currentHub = nil;
}

- (void)sendRemoteNotificationToAllDevicesWithTitle:(NSString *)title message:(NSString *)message playSound:(BOOL)sound bundleIdentifier:(NSString *)bundleIdentifier completion:(void (^)(NSError *error))completion {
    ASUserAPIService *userService = [[ASUserAPIService alloc] initWithUser:self.systemManager.cloud.user systemManager:self.systemManager];
    [userService updateAllHubsWithTitle:title message:message playSound:sound bundleIdentifier:bundleIdentifier success:^{
        if (completion) {
            completion(nil);
        }
    } failure:^(NSError *error) {
        if (error) {
            [self.systemManager.cloud handleUserLogoutWithError:error];
        }
        
        if (completion) {
            completion(error);
        }
    }];
}

- (void)sendSilentNotificationToAllDevicesWithPayload:(NSDictionary *)payload success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    ASUserAPIService *userService = [[ASUserAPIService alloc] initWithUser:self.systemManager.cloud.user systemManager:self.systemManager];
    [userService sendSilentNotificationToAllHubsWithPayload:payload success:success failure:failure];
}

@end
