//
//  ASDevice+Notify.h
//  Blustream
//
//  Created by Michael Gordon on 2/6/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice.h"

/**
 *  These constants indicate the notification state for any characteristic.
 */
typedef NS_ENUM(NSInteger, ASNotifyState) {
    /**
     *  Indicates that the PIO state is unknown.
     */
    ASNotifyStateUnknown = 0,
    /**
     *  Indicates that the PIO state is disabled.
     */
    ASNotifyStateDisabled = 1,
    /**
     *  Indicates that the PIO state is enabled.
     */
    ASNotifyStateEnabled = 2
};

/**
 *  This category adds methods to `ASDevice` to set the hardware notify updates on different BLE characteristics.
 *  If a command is issued, another command of the same type cannot be issued until the first completes or the hardware
 *  disconnects.
 */
@interface ASDevice (Notify)

@property (assign, readonly, nonatomic) ASNotifyState PIONotifyState;

/**
 *  Turns notification on or off for the digital input pins.
 *
 *  @param enabled    The boolean toggle enabling or disabling the notify setting.
 *  @param completion The completion block.  `error` is nil if the operation succeeded.
 */
- (void)setPIONotify:(BOOL)enabled completion:(void (^)(NSError *error))completion;

@end
