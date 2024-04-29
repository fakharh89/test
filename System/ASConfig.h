//
//  ASConfig.h
//  Blustream
//
//  Created by Michael Gordon on 11/17/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS (NSInteger, ASDeviceAvailability) {
    ASDeviceAvailabilityTaylor = 1 << 0,
    ASDeviceAvailabilityDAddario = 1 << 1,
    ASDeviceAvailabilityTKL = 1 << 2,
    ASDeviceAvailabilityBlustream = 1 << 3,
    ASDeviceAvailabilityBoveda = 1 << 4
};

/**
 *  Custom logging block.
 *
 *  @param message A string which contains the logged message.
 */
typedef void (^ASCustomLoggingBlock)(NSString *message);

/**
 *  These constants indicate to which server the framework should connect.
 */
typedef NS_ENUM(NSInteger, ASServer) {
    /**
     *  Indicates that the framework should connect to the private development server. (NOT IN SERVICE)
     */
    ASServerDevelopment = 1,
    /**
     *  Indicates that the framework should connect to the public development server. AWS Server: https://dev.acousticstream.com
     */
    ASServerTest DEPRECATED_MSG_ATTRIBUTE("Server no longer exists.") = 2,
    /**
     *  Indicates that the framework should connect to the public production server. AWS Server: https://api.acousticstream.com
     */
    ASServerProduction = 3,
    /**
     *  Indicates that the framework should connect to the staging server.  AWS Server: https://staging.acousticstream.com
     */
    ASServerStaging = 4,
    /**
     *  Indicates that the framework should connect to the H2 development server.  AWS Server: http://dev.api.blustream.io
     */
    ASServerDevelopmentH2 = 5
};

typedef NS_ENUM(NSInteger, ASLogLevel) {
    ASLogLevelDisabled = 1,
    ASLogLevelBLEOnly = 2,
    ASLogLevelAllLogs = 3
};

/**
 *  The `ASConfig` class is designed to configure all of the settings for the `ASSystemManager`.  It is passed into
 *  shared instance upon creation and cannot be changed afterwards.
 */
@interface ASConfig : NSObject

/**
 *  A flag to automatically increase the sampling rate when the app is in the foreground.
 *
 *  When this property is set to true, the framework will continuously set the realtime characteristic
 *  to true for each connected device.  The hardware device updates humidity and temperature at a 10
 *  second interval when this hardware byte is set to true.  The hardware only stays in realtime mode
 *  for 60 seconds to save power in the event the framework closing for any reason.
 */
@property (nonatomic, assign) BOOL realtimeMode;

/**
 *  An enum to specify logging level.
 *
 *  Specifies logging level from framework (possible choices are disabled, BLE only, or all logs. Defaults to disabled.
 */
@property (nonatomic, assign) ASLogLevel loggingLevel;

@property (nonatomic, assign) BOOL logToFile;

/**
 *  A block to route all logging messages.
 *
 *  This block takes an input of an NSString *.  It allows the developer to use something besides the default
 *  NSLog.  This is useful when using remote logging tools (Crashlytics, HockeyApp) or an alternative to
 *  NSLog (CocoaLumberjack).  If this property is nil, NSLog will be used.  Note: CocoaLumberjack doesn't
 *  work if you just put the new call inside the block.  Call a method outside the block that has the logging call.
 */
@property (nonatomic, copy) ASCustomLoggingBlock customLogger;

/**
 *  The designated server to which the framework connects.
 *
 *  Allows the developer to select to which server the framework shall connect.  This is a required setting.
 *
 *  @see ASServer
 */
@property (nonatomic, assign) ASServer server;

/**
 *  The dispatch queue for the network and BLE communication callbacks in ASCloud, ASDevice, and the ASDevice
 *  categories. If `nil` (default), the main queue is used.
 */
@property (nonatomic, strong) dispatch_queue_t completionQueue;

/**
 *  Enables or disables remote notifications.  Defaults to YES.
 */
@property (nonatomic, assign) BOOL enableRemoteNotifications;

/**
 *  Enables or disables silent notifications.  Defaults to NO.
 */
@property (nonatomic, assign) BOOL enableSilentNotifications;

/**
 *  Enables or disables proximity features via iBeacon.  Defaults to NO.
 */
@property (nonatomic, assign) BOOL enableLocation;

/**
 *  On connecting to sensors, disable v4 iBeacon settings to improve sensor advertising rate.
 *  Intended for use with v4 sensors in apps that don't support MTA yet.  Defaults to NO.
 */
@property (nonatomic, assign) BOOL disableiBeaconForV4;

/**
 *  Indicates which devices are available for the app.
 */
@property (nonatomic, assign) ASDeviceAvailability deviceAvailability;

/**
 *  Indicates clientID for the app.
 */
@property (nonatomic, copy) NSString *clientID;

/**
 *  Indicates clientSecret for the app.
 */
@property (nonatomic, copy) NSString *clientSecret;

/**
 *  Indicates accountTag for the app.
 */
@property (nonatomic, copy) NSString *accountTag;

/**
 *  Indicates authParameter for the app.
 */
@property (nonatomic, copy) NSString *authParameter;

/**
 *  Override the bundle identifier for sending notifications to another app.  Useful for Humiditrak 1 accounts
 *  sending notifications to the Humiditrak 2 app.
 */
@property (nonatomic, copy) NSString *bundleIdentifierOverride;

@end
