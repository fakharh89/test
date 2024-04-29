//
//  ASSystemManager.h
//  Blustream
//
//  Created by Michael Gordon on 7/19/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@class ASConfig, ASContainerManager, ASCloud, ASDeviceManager;

/**
 *  The `ASSystemManager` class manages the connection between the BLE hardware and the server.  It is uses
 *  a singleton design pattern to ensure all BLE connections are communicating through the same source.  To
 *  start the system, start the shared instance using `startWithConfig:`.  See ASConfig to configure the
 *  instance at startup.
 */
@interface ASSystemManager : NSObject

/**
 *  The configuration object containing runtime settings. (read-only)
 *
 *  The `config` object is a record of the settings chosen when starting the shared instance.  Set this
 *  object in `startWithConfig:`.
 *
 *  @see ASConfig
 */
@property (strong, readonly, nonatomic) ASConfig *config;

/**
 *  The object which manages all the user login methods.
 *
 *  This property is automatically instantiated once the shared instance is started.
 *
 *  @see ASCloud
 */
@property (strong, readonly, nonatomic) ASCloud *cloud;

/**
 *  The object which manages all of the containers.
 *
 *  This property is automatically instantiated once the shared instance is started.
 *
 *  @see ASContainerManager
 */
@property (strong, readonly, nonatomic) ASContainerManager *containerManager;

/**
 *  The object which manages all of the devices.
 *
 *  This property is automatically instantiated once the shared instance is started.
 *
 *  @see ASDeviceManager
 */
@property (strong, readonly, nonatomic) ASDeviceManager *deviceManager;

/**
 *  The boolean to determine if the shared instance has completed initialization.
 *
 *  This property is set to `YES` once the ASSystemManager has completed setting up internally.
 */
@property (assign, readonly, nonatomic) BOOL ready;

@property (strong, readonly, nonatomic) NSString *logFile;

- (void)clearLogFile;

/**
 *  Returns the framework version in string form.
 *
 *  @return An NSString of the framework version.
 */
+ (NSString *)version;

/**
 *  Maps mangled classes from Cocoapods Packager to the correct class.  This allows apps that were originally
 *  using the framework as a package to install the framework from source.  Call this before calling
 *  `startWithConfig:`.
 */
+ (void)mapMangledClasses;

/**
 *  Initializes ASSystemManager and creates the shared instance.  It loads the configuration, checks the license
 *  key, starts the internal managers, restores the saved user and devices, and queries the server for all devices
 *  that user owns.  It's recommended to call this method in the `application:didFinishLaunchingWithOptions:` method,
 *  and it may be called only once.  Must be called on the main thread.  Runs on a concurrent background thread.
 *
 *  @param config The config parameter containing startup settings.  Can only be set once and cannot be nil.
 */
+ (void)startWithConfig:(ASConfig *)config;

/**
 *  Initializes ASSystemManager and creates the shared instance.  It loads the configuration, checks the license
 *  key, starts the internal managers, restores the saved user and devices, and queries the server for all devices
 *  that user owns.  It's recommended to call this method in the `application:didFinishLaunchingWithOptions:` method,
 *  and it may be called only once.  Must be called on the main thread.  Runs on a concurrent background thread.
 *  Calls the completion block on the concurrent background thread at the end of the operation if it's successful.
 *
 *  @param config     The config parameter containing startup settings.  Can only be set once and cannot be nil.
 *  @param completion The block called upon completion of the operation.
 */
+ (void)startWithConfig:(ASConfig *)config completion:(void (^)(void))completion;

/**
 *  Returns the shared instance.  Must be called after `startWithConfig:`.
 *
 *  @return The shared ASSystemManager instance.
 */
+ (ASSystemManager *)shared;

/**
 *  Saves data for all owned devices and containers.  This is automatically done, but may need to be called when the `ASDevice`
 *  `alarm` property changes.
 */
- (void)save;

/**
 *  Update config with authorized value
 *  @param authorized Indicates whether user approve location access
 */
- (void)updateLocationAccess:(BOOL)authorized;

/**
 *  Request initial setup of remote notifications
 */
- (void)setupRemoteNotifications:(void (^)(BOOL *granted))completion;

/**
 *  Update config with authorized value
 *  @param authorized Indicates whether user approve notifications access
 */
- (void)updateNotificationAccess:(BOOL)authorized;

@end
