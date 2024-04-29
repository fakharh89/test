//
//  ASSyncManager.m
//  Blustream
//
//  Created by Michael Gordon on 7/14/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASSyncManager.h"

#import "ASCloudPrivate.h"
#import "ASContainerManagerPrivate.h"
#import "ASDeviceManagerPrivate.h"
#import "ASDevicePrivate.h"
#import "ASDeviceAPIService.h"
#import "ASDeviceSyncManager.h"
#import "ASLog.h"
#import "ASSystemManager.h"
#import "MSWeakTimer.h"
#import "ASUserAPIService.h"
#import "ASNotifications.h"
#import "ASUserPrivate.h"
#import "ASUserSyncManager.h"
#import "ASErrorDefinitions.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

@interface ASSyncManager()

@property (nonatomic, weak) ASSystemManager *systemManager;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation ASSyncManager

- (void)dealloc {
    // Remove observers when deallocating so messages don't get sent into the void
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _systemManager = systemManager;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(didConnectDevice:)
                                                   name:ASDeviceConnectedNotification
                                                 object:nil];
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)start {
    dispatch_async(cloud_processing_queue(), ^{
        ASLog(@"Starting sync agent");
        self.syncTimer = [MSWeakTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(syncTimerCallback:) userInfo:nil repeats:YES dispatchQueue:cloud_processing_queue()];
        [self.syncTimer fire];
    });
}

- (void)stop {
    dispatch_async(cloud_processing_queue(), ^{
        ASLog(@"Stopping sync agent");
        [self.syncTimer invalidate];
    });
}

#pragma mark - Private Methods

- (void)syncTimerCallback:(MSWeakTimer *)timer {
    dispatch_async(cloud_processing_queue(), ^{
        if (![self isUserLoggedIn]) {
            return;
        }
        
        [self updateUserDataWithSuccess:nil failure:nil];
        [self updatedContainersDataWithSuccess:nil failure:nil];
        [self updateDevicesDataWithDispatchGroup:nil];
    });
}

- (BOOL)isUserLoggedIn {
    ASUserState state = ASUserLoggedOut;
 
    if (self.systemManager.cloud) {
        state = self.systemManager.cloud.userStatus;
    }
    
    return state != ASUserLoggedOut;
}

- (void)updateUserDataWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    ASUserAPIService *userService = [[ASUserAPIService alloc] initWithUser:self.systemManager.cloud.user
                                                             systemManager:self.systemManager];
    ASUserSyncManager *userSyncManager = [[ASUserSyncManager alloc] initWithUser:self.systemManager.cloud.user
                                                                   systemManager:self.systemManager
                                                                      apiService:userService];
    [userSyncManager synchronizeWithSuccess:success failure:failure];
}

- (void)updatedContainersDataWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    ASUserAPIService *userService = [[ASUserAPIService alloc] initWithUser:self.systemManager.cloud.user
                                                             systemManager:self.systemManager];
    
    [userService getUpdatedContainersForType:ASAccessTypeOwner success:^(NSArray *updatedContainer) {
        NSArray *updatedContainers = nil;
        BOOL changed = [self.systemManager.containerManager syncContainersFromDictionaryArray:updatedContainer updatedContainers:&updatedContainers];
        if (changed) {
            ASLog(@"Synced containers");
            
            // Broadcast notification
            ASContainer *object = nil;
            if (updatedContainers.count == 1) {
                object = [updatedContainers firstObject];
            }
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASContainerSyncedNotification
                                                                                object:object];
        }
        else {
            ASLog(@"Container info didn't change");
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASContainerSyncedNoChangesNotification
                                                                                object:nil];
        }
        
        [self.systemManager.containerManager saveContainers];
        [self.systemManager.deviceManager saveDevices];
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (error) {
            [self.systemManager.cloud handleUserLogoutWithError:error];
        }
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateDevicesDataWithDispatchGroup:(dispatch_group_t)dispatchGroup {
    
    for (ASDevice *device in self.systemManager.deviceManager.devices) {
        
        if (!device.container) {
            continue;
        }
        
        if (dispatchGroup) {
            dispatch_group_enter(dispatchGroup);
        }

        ASDeviceAPIService *apiService = [[ASDeviceAPIService alloc] initWithDevice:device
                                                                      systemManager:self.systemManager];
        ASDeviceSyncManager *syncManager = [[ASDeviceSyncManager alloc] initWithDevice:device
                                                                         systemManager:self.systemManager
                                                                            apiService:apiService];
        [syncManager synchronizeWithSuccess:^{
            if (dispatchGroup) {
                dispatch_group_leave(dispatchGroup);
            }
      
        } failure:^(NSError *error) {
            if (dispatchGroup) {
                dispatch_group_leave(dispatchGroup);
            }
        }];
    }
}

#pragma mark Notification Handlers

- (void)willEnterForeground:(NSNotification *)notification {
    [self start];
}

- (void)willEnterBackground:(NSNotification *)notification {
    [self stop];
}

- (void)didConnectDevice:(NSNotification *)notification {
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateBackground) {
        return;
    }
    
    if (![self isUserLoggedIn]) {
        return;
    }
    
    dispatch_async(cloud_processing_queue(), ^{
        [self beginBackgroundUpdateTask];
        
        dispatch_group_t updateDataGroup = dispatch_group_create();
        dispatch_group_enter(updateDataGroup);
        
        [self updateUserDataWithSuccess:^{
            dispatch_group_leave(updateDataGroup);
        } failure:^(NSError *error) {
            dispatch_group_leave(updateDataGroup);
        }];
        
        dispatch_group_enter(updateDataGroup);
        [self updatedContainersDataWithSuccess:^{
            dispatch_group_leave(updateDataGroup);
        } failure:^(NSError *error) {
            dispatch_group_leave(updateDataGroup);
        }];
        
        [self updateDevicesDataWithDispatchGroup:nil];
        
        dispatch_group_notify(updateDataGroup, cloud_processing_queue(), ^{
            ASLog(@"Finished background sync.");
            [self endBackgroundUpdateTask];
        });
    });
}

- (void)beginBackgroundUpdateTask {
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask {
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
}

@end
