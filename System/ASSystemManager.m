//
//  ASSystemManager.m
//  Blustream
//
//  Created by Michael Gordon on 7/19/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASSystemManagerPrivate.h"

#import "AFHTTPSessionManager.h"
#import "AFOAuthCredential.h"
#import "ASAppDelegateProxy.h"
#import "ASBLEInterface.h"
#import "ASCloudPrivate.h"
#import "ASContainer.h"
#import "ASContainerManagerPrivate.h"
#import "ASDeviceManagerPrivate.h"
#import "ASDevicePrivate.h"
#import "ASLocationManager.h"
#import "ASLog.h"
#import "ASPUTQueue.h"
#import "ASRemoteNotificationManager.h"
#import "ASResourceManager.h"
#import "ASSyncManager.h"
#import "ASUser.h"
#import "NSArray+ASSearch.h"

#include "ASConfig.h"

static ASSystemManager *_sharedManager;
static dispatch_once_t onceToken;

@implementation ASSystemManager

#pragma mark - Initialization Methods

- (void)dealloc {
    // Remove observers when deallocating so messages don't get sent into the void
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.ready = NO;
    }
    return self;
}

+ (NSString *)version {
    return [[[NSBundle bundleForClass:self] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (void)mapMangledClasses {
    [NSKeyedUnarchiver setClass:[AFOAuthCredential class] forClassName:@"PodAS_iOS_Framework_AFOAuthCredential"];
}

+ (ASSystemManager *)shared {
    return _sharedManager;
}

+ (void)startWithConfig:(ASConfig *)config {
    [self startWithConfig:config completion:nil];
}

+ (void)startWithConfig:(ASConfig *)config completion:(void (^)(void))completion {
    if (![[NSThread currentThread] isMainThread]) {
        NSException *mainThreadException = [NSException exceptionWithName:@"ASSystemManagerStartBackgroundThreadException" reason:@"ASSystemManager startWithConfig: must be called on the main thread." userInfo:nil];
        [mainThreadException raise];
    }
    
    dispatch_once(&onceToken, ^{
        [ASSystemManager startUnsafeWithConfig:config];
        if (completion) {
            completion();
        }
    });
}

+ (void)startUnsafeWithConfig:(ASConfig *)config {
    if (_sharedManager) {
        return;
    }
    
    if (!config) {
        NSAssert(NO, @"ASConfig object missing.");
        return;
    }
    
    if ([self class] != [ASSystemManager class]) {
        NSAssert(NO, @"ASSystemManager cannot be inherited.");
        return;
    }
    
    // Second half of this check is probably unnecessary
    if (([config class] != [ASConfig class]) || ([[config class] superclass] != [NSObject class])) {
        NSAssert(NO, @"ASConfig cannot be inherited.");
        return;
    }
    
    _sharedManager = [[ASSystemManager alloc] init];
    _sharedManager.config = [config copy];
    
    // Throw warning if plist has anything missing
    [self checkPList:config];
    
    _sharedManager.cloud = [[ASCloud alloc] initWithSystemManager:_sharedManager];
    _sharedManager.deviceManager = [[ASDeviceManager alloc] initWithSystemManager:_sharedManager];
    _sharedManager.containerManager = [[ASContainerManager alloc] initWithSystemManager:_sharedManager];
    _sharedManager.resourceManager = [[ASResourceManager alloc] initWithResourceName:@"ASFramework"];
    
    if (_sharedManager.config.enableLocation) {
        _sharedManager.locationManager = [[ASLocationManager alloc] initWithSystemManager:_sharedManager];
    }
    
    if (_sharedManager.cloud.user) {
        [_sharedManager.deviceManager loadDevices];
        [_sharedManager.containerManager loadContainers];
    }
    
    _sharedManager.BLEInterface = [[ASBLEInterface alloc] initWithSystemManager:_sharedManager];
    
    [ASAppDelegateProxy swizzleAppDelegate];
    
    _sharedManager.ready = YES;
    
    if (_sharedManager.cloud.user) {
        [_sharedManager.cloud.syncManager start];
        [_sharedManager.cloud.PUTQueue start];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}

+ (void)checkPList:(ASConfig *)config {
    NSArray *backgroundModes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
    
    // Check background modes:
    BOOL bleBackground = NO;
    BOOL location = NO;
    for (NSString *mode in backgroundModes) {
        if ([mode compare:@"bluetooth-central"] == NSOrderedSame) {
            bleBackground = YES;
        }
        else if ([mode compare:@"location"] == NSOrderedSame) {
            location = YES;
        }
    }
    
    if (!bleBackground) {
        ASLog(@"WARNING: \"Uses Bluetooth LE accessories\" option not enabled in Project/Capabilities/Background Mode!");
    }
    if (!location) {
        ASLog(@"WARNING: \"Location updates\" option not enabled in Project/Capabilities/Background Mode!");
    }
}

#pragma mark - Public Methods

- (NSString *)logFile {
    NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
    return [docsPath stringByAppendingPathComponent:@"Log.txt"];
}

- (void)clearLogFile {
    deleteLog();
}

- (void)save {
    [self.deviceManager saveDevices];
    [self.containerManager saveContainers];
    [self.cloud saveUser];
}

- (void)updateLocationAccess:(BOOL)authorized {
    _sharedManager.config.enableLocation = authorized;
    
    if (authorized && !_sharedManager.locationManager) {
        _sharedManager.locationManager = [[ASLocationManager alloc] initWithSystemManager:_sharedManager];
        for (ASContainer *container in _containerManager.containers) {
            if (container.device) {
                [_locationManager startMonitoringDevice:container.device];
            }
        }
    } else {
        _sharedManager.locationManager = nil;
    }
}

- (void)setupRemoteNotifications:(void (^)(BOOL *granted))completion {
    [_sharedManager.cloud.remoteNotificationManager setupRemoteNotifications:completion];
}

- (void)updateNotificationAccess:(BOOL)authorized {
    _sharedManager.config.enableRemoteNotifications = authorized;
}

#pragma mark - Notification Handlers

+ (void)willEnterBackground:(NSNotification *)notification {
    [_sharedManager save];
}

+ (void)willTerminate:(NSNotification *)notification {
    [_sharedManager save];
    for (ASDevice *device in _sharedManager.deviceManager.stuckDevices) {
        [device setAutoConnect:NO error:nil];
    }
}

#pragma mark - Private Methods

+ (NSString *)applicationHiddenDocumentsDirectory {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [libraryPath stringByAppendingPathComponent:@"ASPrivateDocuments"];
    
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (isDirectory) {
            return path;
        }
        else {
            // Handle error. ".data" is a file which should not be there...
            [NSException raise:@"ASPrivateDocuments exists, and is a file" format:@"Path: %@", path];
            // NSError *error = nil;
            // if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
            //     [NSException raise:@"could not remove file" format:@"Path: %@", path];
            // }
        }
    }
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
        // Handle error.
        [NSException raise:@"Failed creating directory" format:@"[%@], %@", path, error];
    }
    return path;
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path {
    NSURL *URL = [NSURL fileURLWithPath:path];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[URL path]]) {
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    
    if (!success) {
        ASLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    
    NSNumber *value = nil;
    error = nil;
    if ([URL getResourceValue:&value forKey:NSURLIsExcludedFromBackupKey error:&error]) {
        if (!value.boolValue) {
            ASLog(@"Key not set correctly");
            success = NO;
        }
    }
    else {
        ASLog(@"Error getting resource after setting NSURLIsExcludedFromBackupKey");
        success = NO;
    }
    
    return success;
}

@end
