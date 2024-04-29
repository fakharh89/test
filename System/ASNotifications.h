//
//  ASNotifications.h
//  Blustream
//
//  Created by Michael Gordon on 12/11/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

/**-----------------------------------------------------------------------------
 * @name `ASDeviceManager` Related Notifications
 * -----------------------------------------------------------------------------
 */

/**
 *  Posted on the main thread whenever the device manager state changes.
 */
extern NSString * const ASDeviceManagerStateChangedNotification;


/**-----------------------------------------------------------------------------
 * @name `ASDevice` Related Notifications
 * -----------------------------------------------------------------------------
 */

/**
 *  @deprecated This constant is deprecated in version 1.0.2.  Please use `ASDeviceAdvertisedNotification`.
 *  The functionality has not changed.
 */
extern NSString * const ASDeviceFoundNotification __attribute__((deprecated));

/**
 *  Posted on the main thread whenever a device advertises nearby the user's iOS device.  If this is the first
 *  time this device has advertised, it is added to the ASDeviceManager device list.  This advertisement is 
 *  limited to once every 5 seconds.
 *
 *  Object: Device (ASDevice *)
 *  User Info: nil
 */
extern NSString * const ASDeviceAdvertisedNotification;

/**
 *  Posted on the main thread whenever a device connects to the iOS device.
 *
 *  Object: Device (ASDevice *)
 *  User Info: nil
 */
extern NSString * const ASDeviceConnectedNotification;

/**
 *  Posted on the main thread whenever a device disconnects from the iOS device.
 *
 *  Object: Device (ASDevice *)
 *  User Info: @{ @"error" : (NSError *) } - error is from ASDeviceErrorDomain
 */
extern NSString * const ASDeviceDisconnectedNotification;

/**
 *  Posted on the main thread whenever a device fails connects to the hardware.  The framework will
 *  automatically try to reconnect.
 *
 *  Object: Device (ASDevice *)
 *  User Info: @{ @"error" : (NSError *) } - error is from ASDeviceErrorDomain
 */
extern NSString * const ASDeviceConnectFailedNotification;

extern NSString * const ASDeviceOTAUAcceptedNotification;
extern NSString * const ASURLRejectedNotification;

extern NSString * const ASDeviceRegionStateDeterminedNotification;

/**
 *  Posted on the main thread whenever a device's RSSI updates.  If RSSI is nil, it means the RSSI
 *  couldn't be read.
 *
 *  Object: Device (ASDevice *)
 *  User Info: nil
 */
extern NSString * const ASDeviceRSSIUpdatedNotification;

/**
 *  Posted on the main thread whenever the device is updated by the server.  For example, this could be
 *  posted when the devices's metadata changes on another phone.
 *
 *  Object: Device (ASDevice *)
 *  User Info: nil
 */
extern NSString * const ASDeviceSyncedNotification;

/**
 *  Posted on the main thread whenever devices are synced but not changes are made.
 *
 *  Object: nil
 *  User Info: nil
 */
extern NSString * const ASDeviceSyncedNoChangesNotification;

/**-----------------------------------------------------------------------------
 * @name `ASContainer` Related Notifications
 * -----------------------------------------------------------------------------
 */

/**
 *  Posted on the main thread whenever data is read from the hardware.  For example, this could be posted
 *  when the hardware reads the humidity and temperature or when the battery level changes. See
 *  ASBLEDefinitions.h for a list characteristic strings that are sent.
 *
 *  Object: Container (ASContainer *)
 *  User Info: @{ @"characteristic" : (NSString *) } - string is characteristic string
 */
extern NSString * const ASContainerCharacteristicReadNotification;

/**
 *  Posted on the main thread whenever a device fails to read data from the hardware.  See ASBLEDefinitions.h
 *  for a list of characteristic strings that are sent.
 *
 *  Object: Container (ASContainer *)
 *  User Info: { @"error" : (NSError *), - error is from ASDeviceErrorDomain
 *               @"characteristic" : (NSString *) } - string is characteristic string
 */
extern NSString * const ASContainerCharacteristicReadFailedNotification;

/**
 *  Posted on the main thread whenever the container is updated by the server.  For example, this could be
 *  posted when the container's name changes on another phone.  If the object is nil, it means that
 *  several containers were updated at once.
 *
 *  Object: Container (ASContainer *)
 *  User Info: nil
 */
extern NSString * const ASContainerSyncedNotification;

/**
 *  Posted on the main thread whenever the container's image is updated by the server.
 *
 *  Object: Container (ASContainer *)
 *  User Info: nil
 */
extern NSString * const ASContainerImageSyncedNotification;

/**
 *  Posted on the main thread whenever containers are synced but not changes are made.
 *  Use the new ASContainerSyncedNoChangesNotification instead.
 *
 *  Object: nil
 *  User Info: nil
 */
extern NSString * const ASContainerNoChangesNotification __attribute__((deprecated));
extern NSString * const ASContainerSyncedNoChangesNotification;

extern NSString * const ASContainerDataDownloadedFromDeviceNotification;

/**-----------------------------------------------------------------------------
 * @name `ASCloud` Related Notifications
 * -----------------------------------------------------------------------------
 */

/**
 *  Posted on the main thread whenever a user needs to re-enter their login credentials.  The object
 *  contains an error message as to why the user was logged out.  The user info includes a stack trace
 *  to report back which method caused an unintentional logout.  If an unintentional logout occurs,
 *  please report it to Acoustic Stream.
 *
 *  Object: Error (NSError *)
 *  User Info: { @"callStackSymbols" : (NSArray<NSString *> *)} - Array is call stack
 */
extern NSString * const ASUserLoggedOutNotification;

/**
 *  Posted on the main thread whenever a user's information has been synced with the server and
 *  a change has occurred.
 *
 *  Object: nil
 *  User Info: nil
 */
extern NSString * const ASUserSyncedNotification;

/**
 *  Posted on the main thread whenever a user's information has been synced with the server and
 *  no change has occurred.
 *
 *  Object: nil
 *  User Info: nil
 */
extern NSString * const ASUserSyncedNoChangeNotification;

/**
 *  Posted on the main thread whenever a user's image has been synced with the server.
 *
 *  Object: nil
 *  User Info: nil
 */
extern NSString * const ASUserImageSyncedNotification;
