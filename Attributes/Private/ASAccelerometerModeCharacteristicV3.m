//
//  ASAccelerometerModeCharacteristicV3.m
//  Pods
//
//  Created by Michael Gordon on 12/11/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASAccelerometerModeCharacteristicV3.h"

#import "ASBLEDefinitions.h"
#import "ASDevice.h"
#import "ASNotifications.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

@implementation ASAccelerometerModeCharacteristicV3

+ (NSString *)identifier {
    return ASAccelerometerModeCharacteristicUUIDv3;
}

- (void)sendNotificationWithError:(NSError *)error {
    NSDictionary *userInfo = nil;
    NSString *notificationName = nil;
    
    if (error) {
        notificationName = ASContainerCharacteristicReadFailedNotification;
        userInfo = @{@"characteristic":[[self superclass] identifier],
                     @"error":error};
    }
    else {
        notificationName = ASContainerCharacteristicReadNotification;
        userInfo = @{@"characteristic":[[self superclass] identifier]};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:notificationName object:self.device.container userObject:userInfo waitUntilDone:YES];
}

@end
