//
//  ASErrorDefinitions.h
//  Blustream
//
//  Created by Michael Gordon on 3/3/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

extern NSString * const ASReadableErrorDescription;

/**
 *  The error domain string for general container errors.
 *  String value is @"com.acousticstream.container".
 */
extern NSString * const ASContainerErrorDomain;

/**
 *  These constants identify the errors in the domain named ASContainerErrorDomain.
 */
typedef NS_ENUM(NSInteger, ASContainerError) {
    /**
     *  Indicates an unknown error occurred.
     */
    ASContainerErrorUnknown,
    /**
     *  Indicates that the container is already linked to a device.
     */
    ASContainerErrorAlreadyLinked,
    /**
     *  @deprecated This enumerated value is deprecated starting in version 1.1.1.  Please use
     *  `ASContainerErrorAlreadyLinked` instead.
     */
    ASContainerAlreadyLinked DEPRECATED_MSG_ATTRIBUTE("Use ASContainerErrorAlreadyLinked instead") = ASContainerErrorAlreadyLinked,
    /**
     *  Indicates that the device is already linked to another container.
     */
    ASContainerErrorDeviceAlreadyLinked,
    /**
     *  @deprecated This enumerated value is deprecated starting in version 1.1.1.  Please use
     *  `ASContainerErrorDeviceAlreadyLinked` instead.
     */
    ASContainerDeviceAlreadyLinked DEPRECATED_MSG_ATTRIBUTE("Use ASContainerErrorDeviceAlreadyLinked instead") = ASContainerErrorDeviceAlreadyLinked,
    /**
     *  @deprecated This enumerated value is deprecated starting in version 1.1.1.  Please use
     *  `ASContainerManagerErrorContainerAlreadyAdded` instead.
     */
    ASContainerAlreadyExists DEPRECATED_MSG_ATTRIBUTE("Use ASContainerManagerErrorContainerAlreadyAdded instead"),
    /**
     *  Indicates that the container is not in the container array.
     */
    ASContainerErrorNotAdded,
    /**
     *  @deprecated This enumerated value is deprecated starting in version 1.1.1.  Please use
     *  `ASContainerErrorNotAdded` instead.
     */
    ASContainerNotAdded DEPRECATED_MSG_ATTRIBUTE("Use ASContainerErrorNotAdded instead") = ASContainerErrorNotAdded,
    /**
     *  Indicates that the container is already in the process of linking.
     */
    ASContainerErrorIsLinking,
    /**
     *  @deprecated This enumerated value is deprecated starting in version 1.1.1.  Please use
     *  `ASContainerErrorIsLinking` instead.
     */
    ASContainerIsLinking DEPRECATED_MSG_ATTRIBUTE("Use ASContainerErrorIsLinking instead") = ASContainerErrorIsLinking,
    /**
     *  Indicates that the link process between the container and device timed out.
     */
    ASContainerErrorLinkTimedOut,
    /**
     *  @deprecated This enumerated value is deprecated starting in version 1.1.1.  Please use
     *  `ASContainerErrorLinkTimedOut` instead.
     */
    ASContainerLinkTimedOut DEPRECATED_MSG_ATTRIBUTE("Use ASContainerErrorLinkTimedOut instead") = ASContainerErrorLinkTimedOut,
    /**
     *  Indicates that linking failed because the hardware services were not found.
     */
    ASContainerErrorDeviceServicesMissing DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceErrorServicesMissing instead"),
    /**
     *  Indicates that there was an internal error discovering the device services while linking.
     */
    ASContainerErrorDeviceServiceError DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceErrorServiceError instead"),
    /**
     *  Indicates that linking failed because the hardware characteristics were not found.
     */
    ASContainerErrorDeviceCharacteristicMissing DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceErrorCharacteristicsMissing instead"),
    /**
     *  Indicates that there was an internal error discovering the device characteristics while linking.
     */
    ASContainerErrorDeviceCharacteristicError DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceErrorCharacteristicError instead"),
    /**
     *  Indicates that the registration data is not available from the server.
     */
    ASContainerErrorRegistrationDataUnavailable,
    /**
     *  Indicates that the registration data is not available from the server.
     */
    ASContainerErrorRegistrationDataUnavailble DEPRECATED_MSG_ATTRIBUTE("Use ASContainerErrorRegistrationDataUnavailable instead") = ASContainerErrorRegistrationDataUnavailable,
    /**
     *  Indicates that the device connection failed while linking.
     */
    ASContainerErrorDeviceConnectionFailed,
    /**
     *  Indicates that the device sent invalid data while linking.
     */
    ASContainerErrorDeviceInvalidBLEData,
    /**
     *  Indicates that while linking, the notification state couldn't be set on the device
     */
    ASContainerErrorDeviceNotifyError,
    /**
     *  Indicates that while linking, a device write command failed
     */
    ASContainerErrorDeviceWriteError,
    /**
     *  Indicates that while linking, there was a server issue.
     */
    ASContainerErrorNetworkFailed
};

/**
 *  The error domain string for container manager errors.
 *  String value is @"com.acousticstream.containermanager".
 */
extern NSString * const ASContainerManagerErrorDomain;

/**
 *  These constants identify errors in the domain named ASContainerManagerErrorDomain
 */
typedef NS_ENUM(NSInteger, ASContainerManagerError){
    /**
     *  Indicates an unknown error ocurred.
     */
    ASContainerManagerErrorUnknown,
    /**
     *  Indicates that the container could not be added to the array because
     *  it already exists.
     */
    ASContainerManagerErrorContainerAlreadyAdded,
    /**
     *  Indicates that the container could not be removed because it is not in the
     *  container array.
     */
    ASContainerManagerErrorContainerNotAdded
};

/**
 *  The error domain string for general device errors.
 *  String value is @"com.acousticstream.device".
 */
extern NSString * const ASDeviceErrorDomain;

/**
 *  These constants identify the errors in the domain named ASDeviceErrorDomain.
 */
typedef NS_ENUM(NSInteger, ASDeviceError) {
    /**
     *  Indicates an unknown error occurred.
     */
    ASDeviceErrorUnknown,
    /**
     *  Indicates that the hardware is not compatible with this framework.  For example:
     *  Taylor devices may not communicate with the D'Addario app and vice versa.
     */
    ASDeviceErrorIncompatible,
    /**
     *  Indicates that the `ASDevice` is unlinked to an `ASContainer`.
     */
    ASDeviceErrorUnlinked,
    /**
     *  @deprecated This enumerated value is deprecated starting in version 1.3.4.  There is no longer
     *  a priority system for apps.
     */
    ASDeviceErrorConflictingAppInstalled DEPRECATED_MSG_ATTRIBUTE("Priority system removed between apps to allow for easier debugging."),
    /**
     *  @deprecated This enumerated value is deprecated starting in version 1.0.2.  Please use
     *  `ASDeviceErrorConflictingAppInstalled` instead.
     */
    ASDeviceConflictingAppInstalled DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceErrorConflictingAppInstalled instead") = ASDeviceErrorConflictingAppInstalled,
    /**
     *  Indicates that the device's services were missing.
     */
    ASDeviceErrorServicesMissing,
    /**
     *  Indicates that there was an internal error discovering the device services.
     */
    ASDeviceErrorServiceError,
    /**
     *  Indicates that the device's characteristics were missing.
     */
    ASDeviceErrorCharacteristicsMissing,
    /**
     *  Indicates that there was an internal error discovering the device characteristics.
     */
    ASDeviceErrorCharacteristicError,
    /**
     *  @deprecated This enumerated value is deprecated starting in version 1.0.2.  Please use
     *  `ASDeviceBLEDataErrorasdfasdf` instead.
     */
    ASDeviceErrorInvalidBLEData DEPRECATED_MSG_ATTRIBUTE("Use individual errors in ASDeviceBLEDataErrorasdfasdf instead"),
    /**
     *  Indicates that the characteristic's data was missing.
     */
    ASDeviceErrorCharacteristicDataMissing,
    /**
     *  Indicates that the characteristic's data was missing.
     */
    ASDeviceErrorMissingCharacteristic DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceErrorCharacteristicDataMissing instead") = ASDeviceErrorCharacteristicDataMissing,
    /**
     *  Indicates that the hardware initiated a disconnect event.  For example: this error type is used
     *  in Taylor hardware when the 1/4" jack is plugged in.  Only availabile in firmware version 2.0.1
     *  and higher.
     */
    ASDeviceErrorDeviceInitiatedDisconnect,
    /**
     *  Indicates that the user likely initiated the disconnect.
     */
    ASDeviceErrorUserInitiatedDisconnected,
    /**
     *  Indicates that the device has not yet finished setting up or is disconnected.
     */
    ASDeviceErrorCharacteristicNotYetDiscovered,
    /**
     *  Indicates that an OTAU update is already in progress for this device.
     */
    ASDeviceErrorUpdateAlreadyInProgress,
    /**
     *  Indicates that the user's sensor is already on the latest version.
     */
    ASDeviceErrorNoUpdateAvailable,
    /**
     *  Indicates that an internal error occurred and the sensor could not be updated.  Try again
     *  and if that fails, contact Blustream and report this error.
     */
    ASDeviceErrorBootloaderVersionIncompatible,
    /**
     *  Indicates that an internal error occurred and the sensor could not be updated.  Try again
     *  and if that fails, contact Blustream and report this error.
     */
    ASDeviceErrorBootloaderNotReady,
    /**
     *  Indicates that the device's user keys could not be read and were not cached.  Inform the user
     *  that they contact Blustream support for a custom URL that will add the keys back to the cache.
     *  In order to recover the user key, the user must also tell Blustream the device's MAC address
     *  or serial number.  This is included in the NSError userInfo dictionary with the key @"MAC".
     *  The type is NSData *.  We need this information as a hex string, not any UTF formatted string.
     *  i.e. it the string passed to us should match the NSLog output of this NSData object.
     */
    ASDeviceErrorMissingUserKey,
    /**
     *  Indicates that the application image is invalid.  This is likely because the custom user keys
     *  are invalid.  Please contact Blustream and report this error.
     */
    ASDeviceErrorApplicationImageInvalid,
    /**
     *  Indicates that the device type could not be identified.  Contact the developer.
     */
    ASDeviceErrorInvalidDeviceType
};

/**
 *  The error domain string for BLE data errors for devices.
 *  String value is @"com.acousticstream.device.bledata".
 */
extern NSString * const ASDeviceBLEDataErrorDomain;

/**
 *  These constants identify the errors in the domain named ASDeviceBLEDataErrorDomain.
 */
typedef NS_ENUM(NSInteger, ASDeviceBLEDataError) {
    /**
     *  Indicates an unknown error occurred.
     */
    ASDeviceBLEDataErrorUnknown,
    /**
     *  Indicates that the data is the incorrect size.
     */
    ASDeviceBLEDataErrorBufferSizeInvalid,
    /**
     *  Indicates that invalid data was read.
     */
    ASDeviceBLEDataErrorDataOutOfRange,
    /**
     *  Indicates that the datestamp for the data is invalid.
     */
    ASDeviceBLEDataErrorDateInvalid,
    /**
     *  Indicates that the datestamp for the data went back in time.
     */
    ASDeviceBLEDataErrorDateWentBackInTime,
    /**
     *  Indicates that the datestamp for the data went too far into the future
     */
    ASDeviceBLEDataErrorDateWentForwardInTime,
    /**
     *  Indicates that the datestamp for the data is the same as the previous datestamp.
     */
    ASDeviceBLEDataErrorDateNotUnique,
    /**
     *  Indicates that the data failed the erroneous data test for Taylor sensors using the jack
     */
    ASDeviceBLEDataErrorDataIsCorrupt,
    /**
     *  Indicates that the environmental data is the incorrect size.
     */
    ASDeviceBLEDataErrorEnvironmentalBufferSizeInvalid DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorBufferSizeInvalid instead") = ASDeviceBLEDataErrorBufferSizeInvalid,
    /**
     *  Indicates that invalid humidity data was read.
     */
    ASDeviceBLEDataErrorEnvironmentalHumidityOutOfRange DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDataOutOfRange instead") = ASDeviceBLEDataErrorDataOutOfRange,
    /**
     *  Indicates that invalid temperature data was read.
     */
    ASDeviceBLEDataErrorEnvironmentalTemperatureOutOfRange DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDataOutOfRange instead") = ASDeviceBLEDataErrorDataOutOfRange,
    /**
     *  Indicates that the datestamp for the environmental data is invalid.
     */
    ASDeviceBLEDataErrorEnvironmentalDateInvalid DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateInvalid instead") = ASDeviceBLEDataErrorDateInvalid,
    /**
     *  Indicates that the datestamp for the environmental data went back in time.
     */
    ASDeviceBLEDataErrorEnvironmentalDateWentBackInTime DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateWentBackInTime instead") = ASDeviceBLEDataErrorDateWentBackInTime,
    /**
     *  Indicates that the datestamp for the environmental data is the same as the previous datestamp.
     */
    ASDeviceBLEDataErrorEnvironmentalDateNotUnique DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateNotUnique instead") = ASDeviceBLEDataErrorDateNotUnique,
    /**
     *  Indicates that the alarm limits data is the incorrect size.
     */
    ASDeviceBLEDataErrorAlarmLimitsBufferSizeInvalid DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorBufferSizeInvalid instead") = ASDeviceBLEDataErrorBufferSizeInvalid,
    /**
     *  Indicates that the datestamp for the accelerometer data is invalid.
     */
    ASDeviceBLEDataErrorAccelerometerDateInvalid DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateInvalid instead") = ASDeviceBLEDataErrorDateInvalid,
    /**
     *  Indicates that the datestamp for the accelerometer data went back in time.
     */
    ASDeviceBLEDataErrorAccelerometerDateWentBackInTime DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateWentBackInTime instead") = ASDeviceBLEDataErrorDateWentBackInTime,
    /**
     *  Indicates that the datestamp for the accelerometer data is the same as the previous datestamp.
     */
    ASDeviceBLEDataErrorAccelerometerDateNotUnique DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateNotUnique instead") = ASDeviceBLEDataErrorDateNotUnique,
    /**
     *  Indicates that the datestamp for the activity data is invalid.
     */
    ASDeviceBLEDataErrorActivityDateInvalid DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateInvalid instead") = ASDeviceBLEDataErrorDateInvalid,
    /**
     *  Indicates that the datestamp for the activity data went back in time.
     */
    ASDeviceBLEDataErrorActivityDateWentBackInTime DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateWentBackInTime instead") = ASDeviceBLEDataErrorDateWentBackInTime,
    /**
     *  Indicates that the datestamp for the activity data is the same as the previous datestamp.
     */
    ASDeviceBLEDataErrorActivityDateNotUnique DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateNotUnique instead") = ASDeviceBLEDataErrorDateNotUnique,
    /**
     *  Indicates that the datestamp for the PIO data is invalid.
     */
    ASDeviceBLEDataErrorPIODateInvalid DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateInvalid instead") = ASDeviceBLEDataErrorDateInvalid,
    /**
     *  Indicates that the datestamp for the PIO data went back in time.
     */
    ASDeviceBLEDataErrorPIODateWentBackInTime DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateWentBackInTime instead") = ASDeviceBLEDataErrorDateWentBackInTime,
    /**
     *  Indicates that the datestamp for the PIO data is the same as the previous datestamp.
     */
    ASDeviceBLEDataErrorPIODateNotUnique DEPRECATED_MSG_ATTRIBUTE("Use ASDeviceBLEDataErrorDateNotUnique instead") = ASDeviceBLEDataErrorDateNotUnique
};

/**
 *  The error domain string for BLE notification related errors.
 *  String value is @"com.acousticstream.device.notify".
 */
extern NSString * const ASDeviceNotifyErrorDomain;

/**
 *  These constants identify the errors in the domain named ASDeviceNotifyErrorDomain.
 */
typedef NS_ENUM(NSInteger, ASDeviceNotifyError) {
    /**
     *  Indicates an unknown error occurred.
     */
    ASDeviceNotifyErrorUnknown,
    /**
     *  Indicates that the hardware does not support custom PIO usage.
     */
    ASDeviceNotifyErrorPIONotSupported,
    /**
     *  Indicates that the hardware does not support custom AIO usage.
     */
    ASDeviceNotifyErrorAIONotSupported,
    /**
     *  Indicates that the user cannot set BLE notify for simulated software devices.
     */
    ASDeviceNotifyErrorSoftwareNotSupported,
    /**
     *  Indicates that the hardware is not connected.
     */
    ASDeviceNotifyErrorNotConnected,
    /**
     *  Indicates that a pending command of the same type already exists.
     */
    ASDeviceNotifyErrorAlreadyPending,
    /**
     *  Indicates that the characteristic doesn't exist or hasn't been discovered yet.
     */
    ASDeviceNotifyErrorCharacteristicUndiscovered,
    /**
     *  Indicates that the software revision number is unknown.
     */
    ASDeviceNotifyErrorVersionUnknown,
    /**
     *  Indicates that the software revision is too low.
     */
    ASDeviceNotifyErrorVersionUnsupported
};

/**
 *  The error domain string for BLE read related errors.
 *  String value is @"com.acousticstream.device.read".
 */
extern NSString * const ASDeviceReadErrorDomain;

/**
 *  These constants identify the errors in the domain named ASDeviceReadErrorDomain.
 */
typedef NS_ENUM(NSInteger, ASDeviceReadError) {
    /**
     *  Indicates an unknown error occurred.
     */
    ASDeviceReadErrorUnknown,
    /**
     *  Indicates that the user cannot set BLE read for simulated software devices.
     */
    ASDeviceReadErrorSoftwareNotSupported,
    /**
     *  Indicates that the hardware is not connected.
     */
    ASDeviceReadErrorNotConnected,
    /**
     *  Indicates that a pending command of the same type already exists.
     */
    ASDeviceReadErrorAlreadyPending,
    /**
     *  Indicates that the characteristic doesn't exist or hasn't been discovered yet.
     */
    ASDeviceReadErrorCharacteristicUndiscovered,
    /**
     *  Indicates that the software revision number is unknown.
     */
    ASDeviceReadErrorVersionUnknown,
    /**
     *  Indicates that the software revision is too low.
     */
    ASDeviceReadErrorVersionUnsupported
};

/**
 *  The error domain string for BLE write command related errors.
 *  String value is @"com.acousticstream.device.write".
 */
extern NSString * const ASDeviceWriteErrorDomain;

/**
 *  These constants identify the errors in the domain named ASDeviceWriteErrorDomain.
 */
typedef NS_ENUM(NSInteger, ASDeviceWriteError) {
    /**
     *  Indicates an unknown error occurred.
     */
    ASDeviceWriteErrorUnknown,
    /**
     *  Indicates that the hardware does not support custom PIO usage.
     */
    ASDeviceWriteErrorPIONotSupported,
    /**
     *  Indicates that the length of the AIO array is invalid.
     */
    ASDeviceWriteErrorAIOLengthInvalid,
    /**
     *  Indicates that a value in the AIO array is invalid.
     */
    ASDeviceWriteErrorAIOValueInvalid,
    /**
     *  Indicates that the hardware does not support custom AIO usage.
     */
    ASDeviceWriteErrorAIONotSupported,
    /**
     *  Indicates that the hardware does not have LED capabilities.
     */
    ASDeviceWriteErrorBlinkNotSupported,
    /**
     *  Indicates that the user cannot write over BLE for simulated software devices.
     */
    ASDeviceWriteErrorSoftwareNotSupported,
    /**
     *  Indicates that the hardware is not connected.
     */
    ASDeviceWriteErrorNotConnected,
    /**
     *  Indicates that a pending command of the same type already exists.
     */
    ASDeviceWriteErrorAlreadyPending,
    /**
     *  Indicates that the characteristic doesn't exist or hasn't been discovered yet.
     */
    ASDeviceWriteErrorCharacteristicUndiscovered,
    /**
     *  Indicates that the software revision number is unknown.
     */
    ASDeviceWriteErrorVersionUnknown,
    /**
     *  Indicates that the software revision does not support this feature
     */
    ASDeviceWriteErrorVersionUnsupported,
    /**
     *  Indicates that the data is out of bounds.
     */
    ASDeviceWriteErrorDataOutOfRange
};

/**
 *  The error domain string for server related errors.
 *  String value is @"com.acousticstream.cloud".
 */
extern NSString * const ASCloudErrorDomain;

/**
 *  These constants identify the errors in the domain named ASCloudErrorDomain.
 */
typedef NS_ENUM(NSInteger, ASCloudError) {
    /**
     *  Indicates an unknown error occurred.
     */
    ASCloudErrorUnknown,
    /**
     *  Indicates that the account already exists on the server.
     */
    ASCloudErrorAccountAlreadyExists,
    /**
     *  Indicates that the account already exists on the server and the user has tried too many attemps to registered.
     */
    ASCloudErrorAccountCreationTooManyAttemps,
    /**
     *  Indicates a critical server/framework miscommunication.  Should never occur.
     */
    ASCloudErrorServerError,
    /**
     *  Indicates that the user's server credentials have become invalidated.  This should only
     *  rarely occur (i.e. the user changes their password, or the server resets their OAuth token)
     *  if the logout method in ASCloud was not called.
     */
    ASCloudErrorInvalidCredentials,
    
    /**
     *  Indicates that the device or user already running an asynchronous tasks, and
     *  an object cannot have two syncing image or data happening at the same time.
     */
    ASCloudErrorSyncingAlreadyInProgress,
    /**
     *  Indicates that the device does not exist in the server database.  Link the device
     *  to a container to fix this.
     */
    ASCloudErrorDeviceNotFound,
    /**
     *  Indicates that the container does not exist in the server database.
     */
    ASCloudErrorContainerNotFound,
    /**
     *  Indicates that the user or container image URL is missing.
     */
    ASCloudErrorImageURLMissing,
    /**
     *  Indicates that the data query had no data available in that date range.  Aka a 404
     */
    ASCloudErrorNoDataAvailable
};

/**
 *  The error domain string for account creation related errors.
 *  String value is @"com.acousticstream.accountcreation".
 */
extern NSString * const ASAccountCreationErrorDomain;

/**
 *  These constants identify the errors in the domain named ASAccountCreationErrorDomain.  See
 *  `registerNewUser:completion:` in `ASCloud` for the account creation rules.
 */
typedef NS_ENUM(NSInteger, ASAccountCreationError) {
    /**
     *  Indicates that the user's first name is too long. 80 characters is the limit.
     */
    ASAccountCreationErrorInvalidFirstName,
    /**
     *  Indicates that the user's first name is missing.
     */
    ASAccountCreationErrorMissingFirstName,
    /**
     *  Indicates that the user's last name is too long. 80 characters is the limit.
     */
    ASAccountCreationErrorInvalidLastName,
    /**
     *  Indicates that the user's last name is missing.
     */
    ASAccountCreationErrorMissingLastName,
    /**
     *  Indicates that the user hasn't provided a valid email address.
     *  255 characters is the limit, including the account tag (i.e. '+taylor').
     */
    ASAccountCreationErrorInvalidEmail,
    /**
     *  Indicates that the user's email address is missing.
     */
    ASAccountCreationErrorMissingEmail,
    /**
     *  Indicates that the user's password is too short.
     */
    ASAccountCreationErrorPasswordTooShort,
    /**
     *  Indicates that the user's password is missing a capital letter.
     */
    ASAccountCreationErrorPasswordMissingCapitalLetter,
    /**
     *  Indicates that the user's password is missing a lowercase letter.
     */
    ASAccountCreationErrorPasswordMissingLowercaseLetter,
    /**
     *  Indicates that the user's password is missing a number.
     */
    ASAccountCreationErrorPasswordMissingNumber,
    /**
     *  Indicates that the user's password is missing.
     */
    ASAccountCreationErrorMissingPassword
};

extern NSString * const ASPurchasingManagerErrorDomain;

extern NSString * const ASWordpressErrorDomain;

typedef NS_ENUM(NSInteger, ASPurchasingManagerError) {
    ASPurchasingManagerErrorInvalidProperty
};

