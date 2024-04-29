//
//  ASDevice+OTAU.h
//  Pods
//
//  Created by Michael Gordon on 11/3/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice.h"

/**
 *  These constants indicate the OTAU state.
 */
typedef NS_ENUM(NSInteger, ASOTAUProgressState) {
    /**
     *  Indicates that the state is unknown.  If you encounter this, contact Blustream.
     */
    ASOTAUProgressStateUnknown,
    /**
     *  Indicates that the phone/tablet is reading properties from the sensor that later need
     *  to be written to the device in boot mode.
     */
    ASOTAUProgressStatePreparingBootMode,
    /**
     *  Indicates that the sensor is booting from application mode (the mode where humidity/
     *  temperature/motion is tracked) to boot mode (the mode where we can update the sensor's
     *  code).
     */
    ASOTAUProgressStateBootingIntoOTAUMode,
    /**
     *  Indicates that the phone/tablet is reading properties from the sensor to confirm that
     *  we launched into boot mode correctly.  Any properties that were missing required to
     *  customize the image are read again if the sensor was stuck in boot loader mode.
     */
    ASOTAUProgressStatePreparingImageWrite,
    /**
     *  Indicates that the phone/tablet is writing the updated image to the sensor.  The progress
     *  state here is likely what should drive any loading bar as this is the slowest portion.
     */
    ASOTAUProgressStateWritingImage,
    /**
     *  Indicates that the image write has completed successfully and the sensor is booting back
     *  into the updated application mode.
     */
    ASOTAUProgressStateBootingIntoApplicationMode,
    /**
     *  Indicates that the phone/tablet is now checking that the OTAU was successfully completed.
     *  NOT YET IMPLEMENTED
     */
    ASOTAUProgressStateCheckingOTAU
};

/**
 *  A dictionary key for setting a custom user key for the device.  This should *only* be used when the
 *  update failed and the device is stuck in boot mode.  Their are several properties that can only be read
 *  in application mode.  The framework preserves these to the disk in case the OTAU fails, but the if the
 *  OTAU fails and the user deletes the app, these keys will disappear.  The framework also intercepts
 *  custom URL schemes where a user key can be inserted into the local cache automatically.  This is the
 *  preferred way to update this key.  See the user guide for more details on this URL scheme.
 */
extern NSString * const ASOTAUOptionUserKeyKey;

/**
 * A boolean key for setting a default user key for the device.
 */
extern NSString * const ASOTAUOptionDefaultKey;

/**
 *  This category adds methods to `ASDevice` for over-the-air updates (OTAU).  These methods update the
 *  device's firmware via BLE.  Remember, by BLE standards, this affects the `softwareRevision` property.
 */
@interface ASDevice (OTAU)

/**
 *  Returns whether or not an update is available.
 *
 *  @return A boolean value indicating if the device can be updated.
 */
- (BOOL)isUpdateAvailable;

/**
 *  Returns whether or not the device is stuck in boot mode and an update is required.  If an OTAU is
 *  in progress, this property should be ignored.
 *
 *  @return A boolean value indicating if the device should be updated immediately.
 */
- (BOOL)isInBootloaderMode;

/**
 *  Returns the newest available software version available to update.
 *
 *  @return An NSString indicating the software revision for an available update.
 */
- (NSString *)latestAvailableUpdate;

/**
 *  Starts an over the air update for the `ASDevice` to the latest available version.  If an update
 *  is not available (i.e. the sensor is already on the latest version), this call will fail.  Note
 *  that this will also fail on iOS 9 due to a known Apple bug related to Bluetooth pairing.
 *
 *  This method returns errors in the ASDeviceErrorDomain.
 *
 *  @param options    The dictionary customizing the update.  See `ASOTAUOptionUserKeyKey` and `ASOTAUOptionDefaultKey`.
 *  @param progress   The block called whenever the status of the update changes.  See `ASOTAUProgressState`
 *                    for details on `state. The `progress` variable is always between 0 and 1.
 *  @param completion The block called upon completion of the update.  If `error` is nil, the operation completed successfully.
 */
- (void)startUpdateWithOptions:(NSDictionary *)options progress:(void (^)(ASOTAUProgressState state, float percentComplete))progress completion:(void (^)(NSError *error))completion;

@end
