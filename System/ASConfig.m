//
//  ASConfig.m
//  Blustream
//
//  Created by Michael Gordon on 11/17/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASConfig.h"

#import "ASLog.h"
#import "ASSystemManager.h"

@implementation ASConfig

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _enableRemoteNotifications = YES;
        _enableSilentNotifications = NO;
        _loggingLevel = ASLogLevelDisabled;
		_disableiBeaconForV4 = NO;
    }
    
    return self;
}

#pragma mark - NSCopying Methods

- (id)copyWithZone:(NSZone *)zone {
    ASConfig *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_realtimeMode = _realtimeMode;
        copy->_loggingLevel = _loggingLevel;
        copy->_logToFile = _logToFile;
        copy->_customLogger = [_customLogger copyWithZone:zone];
        copy->_server = _server;
        copy->_deviceAvailability = _deviceAvailability;
        copy->_completionQueue = _completionQueue;
        copy->_enableRemoteNotifications = _enableRemoteNotifications;
        copy->_enableLocation = _enableLocation;
        copy->_clientID = _clientID;
        copy->_clientSecret = _clientSecret;
        copy->_accountTag = _accountTag;
        copy->_authParameter = _authParameter;
        copy->_enableSilentNotifications = _enableSilentNotifications;
        copy->_disableiBeaconForV4 = _disableiBeaconForV4;
        copy->_bundleIdentifierOverride = _bundleIdentifierOverride;
    }
    
    return copy;
}

@end
