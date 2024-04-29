//
//  ASHub.m
//  Pods
//
//  Created by Michael Gordon on 10/3/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASHubPrivate.h"

#import "ASDateFormatter.h"
#import "ASLog.h"
#import "NSBundle+ASMobileProvisioning.h"
#import "NSString+ASHexString.h"

@implementation ASHub

#define kHubID @"hubId"
#define kAppName @"appName"
#define kSubscribedToSilentNotifications @"subscribedToSilentNotifications"
#define kNotificationTokenID @"notificationTokenId"
#define kLastNotified @"lastNotified"
#define kCreated @"created"

- (instancetype)initWithToken:(NSData *)token subscribedToSilentNotifications:(BOOL)subscribedToSilentNotifications {
    NSParameterAssert(token);
    
    self = [super init];
    if (self) {
        _notificationTokenID = [NSString as_hexStringWithData:token];
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *APSEnvironmentTag;
        
        switch ([[NSBundle mainBundle] as_APSEnvironment]) {
            case ASAPSEnvironmentProduction: {
                APSEnvironmentTag = @"prod";
                break;
            }
            case ASAPSEnvironmentDevelopment: {
                APSEnvironmentTag = @"dev";
                break;
            }
            default: {
                ASLog(@"Failed to determine APS environment.  Couldn't create hub!");
                return nil;
                break;
            }
        };
        
        _appName = [NSString stringWithFormat:@"%@-ios-%@", bundleIdentifier, APSEnvironmentTag];
        
        _subscribedToSilentNotifications = subscribedToSilentNotifications;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    
    self = [super init];
    if (self) {
        if (dictionary[kHubID]) {
            _identifier = dictionary[kHubID];
        }
        if (dictionary[kAppName]) {
            _appName = dictionary[kAppName];
        }
        if (dictionary[kSubscribedToSilentNotifications]) {
            _subscribedToSilentNotifications = ((NSNumber *) dictionary[kSubscribedToSilentNotifications]).boolValue;
        }
        if (dictionary[kNotificationTokenID]) {
            _notificationTokenID = dictionary[kNotificationTokenID];
        }
        if (dictionary[kLastNotified]) {
            ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
            _lastNotified = [formatter dateFromString:dictionary[kLastNotified]];
        }
        if (dictionary[kCreated]) {
            ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
            _lastNotified = [formatter dateFromString:dictionary[kCreated]];
        }
    }
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (self.identifier) {
        [dictionary setObject:self.identifier forKey:kHubID];
    }
    
    if (self.appName) {
        [dictionary setObject:self.appName forKey:kAppName];
    }
    
    [dictionary setObject:@(self.subscribedToSilentNotifications) forKey:kSubscribedToSilentNotifications];
    
    if (self.notificationTokenID) {
        [dictionary setObject:self.notificationTokenID forKey:kNotificationTokenID];
    }
    if (self.lastNotified) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        [dictionary setObject:[formatter stringFromDate:self.lastNotified] forKey:kLastNotified];
    }
    if (self.created) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        [dictionary setObject:[formatter stringFromDate:self.created] forKey:kCreated];
    }
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end
