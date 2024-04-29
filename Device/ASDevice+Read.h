//
//  ASDevice+Read.h
//  Blustream
//
//  Created by Michael Gordon on 2/10/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice.h"

@class ASAIOMeasurement, ASPIOState;

/**
 *  This category extends the `ASDevice` class with methods to manually read the AIO and PIO data on the hardware.
 */
@interface ASDevice (Read)

/**
 *  Sends a read request to the hardware to return the current analog data on the extra input pins.  Subscribe
 *  to the `ASContainerCharacteristicReadNotification` and `ASContainerCharacteristicReadFailedNotification` to process
 *  the data.
 */
- (void)readAIOData __attribute__((deprecated));

/**
 *  Sends a read request to the hardware to return the current digital data on the extra input pins.  Subscribe
 *  to the `ASContainerCharacteristicReadNotification` and `ASContainerCharacteristicReadFailedNotification` to process
 *  the data.
 */
- (void)readPIOData __attribute__((deprecated));

- (void)readAIODataWithSuccess:(void (^)(ASAIOMeasurement *measurement))success failure:(void (^)(NSError *error))failure;

- (void)readPIODataWithSuccess:(void (^)(ASPIOState *state))success failure:(void (^)(NSError *error))failure;

@end
