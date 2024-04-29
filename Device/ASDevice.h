//
//  ASDevice.h
//  Blustream
//
//  Created by Michael Gordon on 6/17/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

/**
 *  These constants indicate the type of hardware that the `ASDevice` class represents.
 */
typedef NS_ENUM(NSInteger, ASDeviceType) {
    /**
     *  Indicates unknown hardware (this should never happen).
     */
    ASDeviceTypeUnknown,
    /**
     *  Indicates that the hardware is simulated in software and does not physically exist.
     */
    ASDeviceTypeSoftware,
    /**
     *  Indicates that the hardware is a Taylor battery-box device.
     */
    ASDeviceTypeTaylor,
    /**
     *  Indicates that the hardware is a D'Addario stand-alone device.
     */
    ASDeviceTypeDAddario,
    /**
     *  Indicates that the hardware is a TKL embedded device.
     */
    ASDeviceTypeTKL,
    /**
     *  Indicates that the hardware is a Blustream device.
     */
    ASDeviceTypeBlustream,
    /**
     *  Indicates that the hardware is a Boveda device.
     */
    ASDeviceTypeBoveda
};

/**
 *  These constants indicate the state of the Bluetooth Low Energy connection between the Acoustic Stream and the framework.
 */
typedef NS_ENUM(NSInteger, ASDeviceBLEState) {
    /**
     *  Indicates that the BLE connection is not present or pending.
     */
    ASDeviceBLEStateDisconnected,
    /**
     *  Indicates that the BLE connection will automatically reinitiate when the user's device is near the framework
     *  or that the framework is currently connecting.
     */
    ASDeviceBLEStateConnecting,
    /**
     *  Indicates that the framework is connected to the Acoustic Stream.
     */
    ASDeviceBLEStateConnected
};

/**
 *  These constants indicate the mode in which the hardware accelerometer is functioning.
 */
typedef NS_ENUM(NSInteger, ASAccelerometerMode) {
    /**
     *  Indicates that the accelerometer is off.
     */
    ASAccelerometerModeOff = 0,
    /**
     *  Indicates that the accelerometer will report activity and g-force data.
     */
    ASAccelerometerModeActivityAndGForce = 1,
    /**
     *  Indicates that the accelerometer will only report activity data.
     */
    ASAccelerometerModeActivityOnly = 2
};

/**
 *  These constants indicate the proximity state of the device to the phone
 */
typedef NS_ENUM(NSInteger, ASRegionState) {
    /**
     *  Indicates that the proximity state is unknown
     */
    ASRegionStateUnknown = 0,
    /**
     *  Indicates that the phone is near the device
     */
    ASRegionStateInside = 1,
    /**
     *  Indicates that the phone is not near the devie
     */
    ASRegionStateOutside = 2
};

@class ASContainer, ASEnvironmentalMeasurement, ASBatteryLevel, ASErrorState;

/**
 *  The `ASDevice` class represents a physical Acoustic Stream unit connected over Bluetooth Low Energy or owned by the user.
 *  It is automatically initialized by the `ASSystemManager` whenever a new device is discovered.
 */
@interface ASDevice : NSObject

/**-----------------------------------------------------------------------------
 * @name Hardware Metadata
 * -----------------------------------------------------------------------------
 */

/**
 *  The container that is linked to the device. (read-only)
 *
 *  The value of this property is an ASContainer that is updated whenever the container becomes linked
 *  or unlinked with this device.
 */
@property (weak, readonly, nonatomic) ASContainer *container;

/**
 *  The time of last contact between the device and the user's smartphone. (read-only)
 *
 *  The value of this property is a date and time that is updated whenever the framework  communicates
 *  with the hardware.
 */
@property (strong, readonly, nonatomic) NSDate *lastUpdate;

/**
 *  The user-set toggle that informs the framework to automatically connect to the hardware.  This used
 *  to be called 'remember'. (read-only)
 *
 *  The value of this property represents whether the framework automatically connects to a given device.  Use
 *  setAutoConnect:completion to change the value.
 */
@property (assign, readonly, nonatomic) BOOL autoconnect;

/**
 *  The hardware type of the device. (read-only)
 *
 *  The value of this property represents the type of Acoustic Stream hardware.
 *  @see ASDeviceType
 */
@property (assign, readonly, nonatomic) ASDeviceType type;

/**
 *  The Bluetooth Low Energy state of the Acoustic Stream. (read-only)
 *
 *  The value of this property represents the current connection status of the device.
 *  @see ASDeviceBLEState
 */
@property (assign, readonly, nonatomic) ASDeviceBLEState state;

/**
 *  The signal level of the connection between the framework and the device. (read-only)
 *
 *  The value of this property represents the signal quality of the device's connection to the
 *  user's iOS device.  It ranges from 0 to approximately -120 dBm (milli-decibels).  If this property
 *  is null, it means that the RSSI could not be read.  To manually check the RSSI, see `updateRSSI`.
 */
@property (strong, readonly, nonatomic) NSNumber *RSSI;

/**
 *  A customizable dictionary representing developer-defined properties of the container.
 *
 *  The value of this property is a dictionary that represents whatever data the developer
 *  wishes to sync with our server.  For example, if the developer wishes to sync the color of the
 *  container, they could add @{@"color":@"red"} to the dictionary.  Tested key types are NSString,
 *  NSNumber, NSArray, and NSDictionary.  This property does not have a default value.  Setting
 *  this value will update the server accordingly.
 */
@property (copy, readwrite, nonatomic) NSDictionary *metadata;

/**-----------------------------------------------------------------------------
 * @name BLE Data
 * -----------------------------------------------------------------------------
 */

/**
 *  The error status representing the functional status of the hardware. (read-only)
 *
 *  No longer available in firmware version 0.4.1.  Use ASContainer.errorState or ASDevice.advertisementErrorState
 */
@property (strong, readonly, nonatomic) NSNumber *errorByte __attribute__((deprecated));

/**-----------------------------------------------------------------------------
 * @name Advertising Data
 * -----------------------------------------------------------------------------
 */

/**
 *  The humidity read from advertising data. (read-only)
 *
 *  The BLE system broadcasts data while not connected.  Included in this is the humidity data (in % RH).  The hardware
 *  does not update the humidity every time the advertisement packet is sent (making the timestamp unreliable).
 *  Subscribe to `ASDeviceAdvertisedNotification` to be notified whenever this property is updated.  Once the device is
 *  connected, this property is no longer updated.
 */
@property (strong, readonly, nonatomic) NSNumber *advertisementHumidity __attribute__((deprecated));

/**
 *  The temperature read from advertising data. (read-only)
 *
 *  The BLE system broadcasts data while not connected.  Included in this is the temperature data (in deg C).  The hardware
 *  does not update the temperature every time the advertisement packet is sent (making the timestamp unreliable).
 *  Subscribe to `ASDeviceAdvertisedNotification` to be notified whenever this property is updated.  Once the device is
 *  connected, this property is no longer updated.
 */
@property (strong, readonly, nonatomic) NSNumber *advertisementTemperature __attribute__((deprecated));

@property (strong, readonly, nonatomic) ASEnvironmentalMeasurement *advertisedEnvironmentalMeasurement;

/**
 *  The battery read from advertisement data. (read-only)
 *
 *  The BLE system broadcasts data while not connected.  Included in this is the battery data (in percent).  The hardware
 *  does not update the battery every time the advertisement packet is sent (making the timestamp unreliable).
 *  Subscribe to `ASDeviceAdvertisedNotification` to be notified whenever this property is updated.  Once the device is
 *  connected, this property is no longer updated.
 */
@property (strong, readonly, nonatomic) NSNumber *advertisementBattery __attribute__((deprecated));

@property (strong, readonly, nonatomic) ASBatteryLevel *advertisedBatteryLevel;

/**
 *  The error status read from advertising data. (read-only)
 *
 *  This property is an 8-bit number representing the functionality of each component.  It is determined
 *  by a BLE characteristic and updated in the advertisement data.  Subscribe to `ASDeviceAdvertisedNotification`
 *  to be notified whenever this property is updated when the device is not connected.  When the device is
 *  connected, use `ASContainerCharacteristicReadNotification` to determine when the error byte is updated.
 *
 *  The hardware sets this value upon starting.  If an error occurs, it is recommended that the user resets
 *  their battery to see if the error goes away.  If it does not, they need to contact customer support as
 *  their hardware is likely damaged.
 *
 *  | Bit | Error Status                                    |
 *  | --- | ----------------------------------------------- |
 *  | 0   | Humidity/temperature sensor failure             |
 *  | 2   | Accelerometer failure                           |
 *  | 3   | Registration characteristic unavailable         |
 *  | 4   | Chip reset (Defaults to 1, not yet implemented) |
 *  | 5   | FIFO overrun (Out of local storage)             |
 *  | 6   | Battery is <= 20%                               |
 *  | 7   | New data is available (v3 only)                 |
 */
@property (strong, readonly, nonatomic) NSNumber *advertisementErrorState __attribute__((deprecated));

// TODO Documentation
@property (strong, readonly, nonatomic) ASErrorState *advertisedErrorState;

/**
 *  The state of the device's proximity to the phone (read-only)
 *
 *  Indicates if the phone can detect the devices advertisement packets through iBeacon.
 */
@property (nonatomic, readonly, assign) ASRegionState regionState;

/**-----------------------------------------------------------------------------
 * @name Alarm Related Properties
 * -----------------------------------------------------------------------------
 */

/**
 *  The hardware's default sampling period (in seconds) for humidity and temperature. (read-only)
 *
 *  This property is the interval at which the hardware samples environmental data when the hardware
 *  does not detect accelerometer activity and the humidity and temperature are within the hardware
 *  alert limits.
 *
 *  @see ASDevice(Write)
 */
@property (strong, readonly, nonatomic) NSNumber *measurementInterval;

/**
 *  The hardware's alert sampling period (in seconds) for humidity and temperature. (read-only)
 *
 *  This property is the interval at which the hardware samples environmental data when the hardware
 *  does detect accelerometer activity or the humidity and temperature are outside the hardware
 *  alert limits.
 *
 *  @see ASDevice(Write)
 */
@property (strong, readonly, nonatomic) NSNumber *alertInterval;

/**
 *  The hardware's maximum humidity (in % RH) before sampling at the alert interval. (read-only)
 *
 *  The alert sampling interval will be triggered if the hardware measures humidity above this
 *  value.
 *
 *  @see ASDevice(Write)
 */
@property (strong, readonly, nonatomic) NSNumber *hardwareHumidAlarmMax;

/**
 *  The hardware's minimum humidity (in % RH) before sampling at the alert interval. (read-only)
 *
 *  The alert sampling interval will be triggered if the hardware measures humidity below this
 *  value.
 *
 *  @see ASDevice(Write)
 */
@property (strong, readonly, nonatomic) NSNumber *hardwareHumidAlarmMin;

/**
 *  The hardware's maximum temperature (in deg C) before sampling at the alert interval. (read-only)
 *
 *  The alert sampling interval will be triggered if the hardware measures temperature above this
 *  value.
 *
 *  @see ASDevice(Write)
 */
@property (strong, readonly, nonatomic) NSNumber *hardwareTempAlarmMax;

/**
 *  The hardware's minimum temperature (in deg C) before sampling at the alert interval. (read-only)
 *
 *  The alert sampling interval will be triggered if the hardware measures temperature below this
 *  value.
 *
 *  @see ASDevice(Write)
 */
@property (strong, readonly, nonatomic) NSNumber *hardwareTempAlarmMin;

/**
 *  The state indicating the mode in which the accelerometer is operating. (read-only)
 *
 *  The accelerometer draws significant current when it is attempting to detect g-force data.  If it is
 *  disabled, the hardware's battery life will increase.  Measuring only the activity data still consumes
 *  more power than when the accelerometer is off, but not nearly as much as measuring both activity and
 *  g-force data.
 *
 *  @see ASDevice(Write)
 */
@property (assign, readonly, nonatomic) ASAccelerometerMode accelSetting;

/**
 *  The minimum number of g's the hardware's accelerometer must detect to record and send the data. (read-only)
 *
 *  This property is a minimum for any of the individual axes to trigger, not the total magnitude
 *
 *  @see ASDevice(Write)
 */
@property (strong, readonly, nonatomic) NSNumber *accelThreshold;

/**-----------------------------------------------------------------------------
 * @name Standard BLE Metadata
 * -----------------------------------------------------------------------------
 */

/**
 *  The hardware's manufacturer name. (read-only)
 */
@property (nonatomic, copy, readonly) NSString *manufacturerName __attribute__((deprecated));

/**
 *  The hardware's model number. (read-only)
 */
@property (nonatomic, copy, readonly) NSString *modelNumber __attribute__((deprecated));

/**
 *  The hardware's serial number. (read-only)
 *
 *  This string is always an eight-digit hexadecimal number.  The last two digits correspond to the
 *  device's type.
 */
@property (nonatomic, copy, readonly) NSString *serialNumber;

/**
 *  The hardware's revision number. (read-only)
 */
@property (nonatomic, copy, readonly) NSString *hardwareRevision;

/**
 *  A version number in the form of a string describing the version of the compiler's bluetooth stack. (read-only)
 */
@property (nonatomic, copy, readonly) NSString *firmwareRevision __attribute__((deprecated));

/**
 *  A version number in the form of a string describing the version of the custom firmware created by
 *  Acoustic Stream. (read-only)
 */
@property (nonatomic, copy, readonly) NSString *softwareRevision;

/**
 *  The BLE system identifier. (read-only)
 */
@property (strong, readonly, nonatomic) NSNumber *BLESystemID __attribute__((deprecated));

/**-----------------------------------------------------------------------------
 * @name ASDevice Methods
 * -----------------------------------------------------------------------------
 */

/**
 *  Updates the `RSSI` property.  `ASDeviceRSSIUpdatedNotification` will be sent out when this is complete.
 */
- (void)updateRSSI;

/**
 *  Checks if the framework allows setting autoconnect.
 *
 *  This parameter can always be set to `NO`.  This method returns errors in the ASDeviceErrorDomain.
 *
 *  @param error If the method returns false, this error can be populated to describe why the operation failed.
 *
 *  @return A boolean representing if the autoconnect can be set to true.
 */
- (BOOL)canAutoConnectWithError:(NSError * __autoreleasing *)error;

/**
 *  Sets the autoconnect property of the device.
 *
 *  Use this to tell the framework to automatically connect in the foreground and background to this specific BLE
 *  hardware.  Autoconnect can only be set to `YES` for devices that are linked.  Can always be set to `NO`.
 *  This method returns errors in the ASDeviceErrorDomain.
 *
 *  @param newAutoConnect The new auto connect state.
 *  @param error          If the method returns false, this error can be populated to describe why the operation failed.
 *
 *  @return A boolean representing if the operation was successful.
 */
- (BOOL)setAutoConnect:(BOOL)newAutoConnect error:(NSError * __autoreleasing *)error;

@end
