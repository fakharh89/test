//
//  ASHub.h
//  Pods
//
//  Created by Michael Gordon on 10/3/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@interface ASHub : NSObject

@property (strong, readonly, nonatomic) NSString *identifier;
@property (strong, readonly, nonatomic) NSString *appName;
@property (assign, readonly, nonatomic) BOOL subscribedToSilentNotifications;
@property (strong, readonly, nonatomic) NSString *notificationTokenID;
@property (strong, readonly, nonatomic) NSDate *lastNotified;
@property (strong, readonly, nonatomic) NSDate *created;

- (instancetype)initWithToken:(NSData *)token subscribedToSilentNotifications:(BOOL)subscribedToSilentNotifications;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionary;

@end
