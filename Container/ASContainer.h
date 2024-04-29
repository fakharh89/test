//
//  ASContainer.h
//  Blustream
//
//  Created by Michael Gordon on 6/25/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ASDevice;
@class ASBatteryLevel;
@class ASEnvironmentalMeasurement;
@class ASImpact;
@class ASActivityState;
@class ASPIOState;
@class ASAIOMeasurement;
@class ASErrorState;
@class ASConnectionEvent;

/**
 *  The `ASContainer` class represents a physical object that the Acoustic Stream hardware can monitor.  A container
 *  can represent a musical instrument, a refrigerator, or any other object.  Each ASContainer must be manually
 *  initialized and added to the array stored in ASContainerManager to sync the user's list of ASContainers
 *  in the server.  The ASContainer init method will return nil if a user is not logged in.  Containers are persisted
 *  between sessions.
 */
@interface ASContainer : NSObject

/**-----------------------------------------------------------------------------
 * @name Container Metadata
 * -----------------------------------------------------------------------------
 */

/**
 *  The name of the container.
 *
 *  The value of this property is a human readable string containing the name of the container.
 *  It does not have a default value.  Setting this value will update the server accordingly.
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 *  The image of the container.
 *
 *  The value of this property is an image that the user can set to represent this container.
 *  It does not have a default.  This value is synced with the server currently.  It is
 *  serialized and deserialized between sessions.
 */
@property (nonatomic, strong, nullable) UIImage *image;

/**
 *  The second image of the container.
 */
@property (nonatomic, strong, nullable) UIImage *secondImage;

/**
 *  The type of the container.
 *
 *  The value of this property is a string that represents the physical type of container this is.
 *  For example: the type could be "refrigerator", or "guitar".  It does not have a default value.
 *  Setting this value will update the server accordingly.
 */
@property (nonatomic, copy, nullable) NSString *type;

/**
 *  A customizable dictionary representing developer-defined properties of the container.
 *
 *  The value of this property is a dictionary that represents whatever data the developer
 *  wishes to sync with our server.  For example, if the developer wishes to sync the color of the
 *  container, they could add @{@"color":@"red"} to the dictionary.  Tested key types are NSString,
 *  NSNumber, NSArray, and NSDictionary.  This property does not have a default value.  Setting
 *  this value will update the server accordingly.
 */
@property (nonatomic, copy, nullable) NSDictionary *metadata;

/**
 *  The unique identifier for the container. (read-only)
 *
 *  The value of this property is a string that represents the unique identifier that this container
 *  uses.  It is automatically generated upon initialization of the container.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *identifier;

/**
 *  The username of the container's owner. (read-only)
 *
 *  The value of this property is a string that represents the username of the owner.  It is automatically
 *  set to the logged in user.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *ownerUsername;

/**
 *  The date the container was last synced with the server. (read-only)
 *
 *  The value of this property is a date that represents the last time the server and the app synced
 *  this container.  The server keeps track of this date so it is the same on all iOS devices.
 */
@property (nonatomic, strong, readonly, nonnull) NSDate *lastSynced;

/**-----------------------------------------------------------------------------
 * @name Device Link Properties
 * -----------------------------------------------------------------------------
 */

/**
 *  The device linked to the container. (read-only)
 *
 *  The value of this property is a weak reference to the ASDevice that is linked to the container.
 *  To change the link between the ASDevice and the ASContainer, see `linkDevice:completion:` and
 *  `unlinkDeviceWithCompletion:`.
 */
@property (nonatomic, weak, readonly, nullable) ASDevice *device;

/**
 *  The serial number of the device linked to the container. (read-only)
 *
 *  The value of this property is a string representing the serial number of the device that is linked
 *  to the container.  This is synced with the server.
 */
@property (nonatomic, copy, readonly, nullable) NSString *linkedDeviceSerialNumber;

/**-----------------------------------------------------------------------------
 * @name BLE Data
 * -----------------------------------------------------------------------------
 */

/**
 *  The data array representing the battery voltage in percent.
 *
 *  This property is an array of NSNumbers.  Each element of this array corresponds to the
 *  time data in batteryDates.  Only stores the last 1024 data samples read over BLE.  Rounded to
 *  the nearest whole number.
 */
@property (nonatomic, strong, readonly, nonnull) NSArray<ASBatteryLevel *> *batteryLevels;

/**
 *  The data array representing the humidity in %RH of each data sample.
 *
 *  This property is an array of NSNumbers.  Each element of this array corresponds to the
 *  time data in humidDates.  Only stores the last 1024 data samples read over BLE.  Rounded to
 *  two decimal places.  Humidity data is accurate to +/- 3 %RH.
 */
@property (nonatomic, strong, readonly, nonnull) NSArray<ASEnvironmentalMeasurement *> *environmentalMeasurements;

/**
 *  The data array representing the acceleration in g's of each data sample.
 *
 *  This property is an array of NSNumbers.  Each element of this array corresponds to the
 *  time data in accelDates.  Only stores the last 1024 data samples read over BLE.  Rounded to
 *  two decimal places.
 */
@property (nonatomic, strong, readonly, nonnull) NSArray<ASImpact *> *impacts;

/**
 *  The data array representing the state (1 is in motion, 0 is not in motion) of each data sample.
 *
 *  This property is an array of NSNumbers.  Each element of this array corresponds to the
 *  time data in activityDates.  Only stores the last 1024 data samples read over BLE.
 */
@property (nonatomic, strong, readonly, nonnull) NSArray<ASActivityState *> *activityStates;

/**
 *  The data array representing the PIO state of each data sample.
 *
 *  This property is an array of NSNumbers.  Each element of this array corresponds to the
 *  time data in PIODates.  Only stores the last 1024 data samples read over BLE.
 */
@property (nonatomic, strong, readonly, nonnull) NSArray<ASPIOState *> *PIOStates;

/**
 *  The data array representing the AIO state of each data sample.
 *
 *  This property is an array of NSArrays (sized 3).  Each subarray contains NSNumbers representing
 *  the voltage in millivolts.  Each element of this greater array corresponds to the time data in AIODates.
 *  Only stores the last 1024 data samples read over BLE.
 */
@property (nonatomic, strong, readonly, nonnull) NSArray<ASAIOMeasurement *> *AIOStates;

/**
 *  The data array representing the error state of each data sample.
 *
 *  This property is an array of NSNumbers.  Each element of this greater array corresponds to the
 *  time data in errorStateDates.  Only stores the last 1024 data samples read over BLE.
 *  See ASDevice.advertisementErrorState for what each bit in the state represents.
 */

@property (nonatomic, strong, readonly, nonnull) NSArray<ASErrorState *> *errors;

@property (nonatomic, strong, readonly, nonnull) NSArray<ASConnectionEvent *> *connectionEvents;

/**-----------------------------------------------------------------------------
 * @name Other Properties
 * -----------------------------------------------------------------------------
 */

/**
 *  The custom tag object.
 *
 *  This property can be used to store data about the container that is not synced with the server.  If the
 *  synced object conforms to `NSCoding`, the tag will be serialized and deserialized automatically.  If
 *  the tag conforms to `ASTag`, when the tag is deserialized, a reference to the parent can automatically
 *  be set.  Setting and reading this object is thread safe.
 *
 *  @see ASTag
 */
@property (nonatomic, strong, readwrite, nullable) id tag;

/**
 * the get image  path function can be used to get the image saved image on disk from the ASPrivateDocument folder
 * this function will return the complete image path with current image extension of .png
 * refer to this function to verify current image extension in case in changed, class ASContainer.m line 1267
 */
- (NSString *)getImagePath;
@end
