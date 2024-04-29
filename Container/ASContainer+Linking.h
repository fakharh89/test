//
//  ASContainer+Linking.h
//  Blustream
//
//  Created by Michael Gordon on 7/6/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASContainer.h"

/**
 *  This category allows ASContainers to link to ASDevices.
 */
@interface ASContainer (Linking)

/**
 *  Links the container to a device.
 *
 *  Devices must be linked to a container before connecting to the hardware to read data.  This function
 *  syncs itself with the server.  This function returns errors in the ASContainerErrorDomain.
 *
 *  @param device     The ASDevice to be linked to this container.
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)linkDevice:(ASDevice *)device completion:(void (^)(NSError *error))completion;

/**
 *  Unlinks the currently linked device from the container.
 *
 *  This function syncs itself with the server.  This function returns errors in the ASContainerErrorDomain.
 *
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)unlinkDeviceWithCompletion:(void (^)(NSError *error))completion;

/**-----------------------------------------------------------------------------
 * @name Temporary Functions for Old Hardware
 * -----------------------------------------------------------------------------
 */

/**
 *  Links the device overriding the registration characteristics on the hardware.
 *
 *  Meant for development use only.  This function returns errors in the ASContainerErrorDomain.
 *
 *  @param device     The ASDevice to be linked to this container.
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)linkDeviceNetworkOnly:(ASDevice *)device completion:(void (^)(NSError *error))completion;

/**
 *  Links the device locally only.
 *
 *  This function will not sync with the server and maybe be overridden by the sync agent.  Meant for
 *  development use only.  This function returns errors in the ASContainerErrorDomain.
 *
 *  @param device     The ASDevice to be linked to this container.
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)linkDeviceLocalOnly:(ASDevice *)device completion:(void (^)(NSError *error))completion;

/**
 *  Unlinks the container and device locally only.
 *
 *  May be overridden by the sync agent.  Meant for development use only.  This function returns errors
 *  in the ASContainerErrorDomain.
 *
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)unlinkDeviceLocalOnlyWithCompletion:(void (^)(NSError *error))completion;

@end
