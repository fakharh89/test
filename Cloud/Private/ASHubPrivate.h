//
//  ASHubPrivate.h
//  Pods
//
//  Created by Michael Gordon on 11/21/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASHub.h"

@interface ASHub ()

@property (strong, readwrite, nonatomic) NSString *identifier;
@property (strong, readwrite, nonatomic) NSString *appName;
@property (assign, readwrite, nonatomic) BOOL subscribedToSilentNotifications;
@property (strong, readwrite, nonatomic) NSString *notificationTokenID;
@property (strong, readwrite, nonatomic) NSDate *lastNotified;
@property (strong, readwrite, nonatomic) NSDate *created;

@end
