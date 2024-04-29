//
//  ASBLEDefinitions.h
//  Blustream
//
//  Created by Michael Gordon on 7/30/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

/**-----------------------------------------------------------------------------
 * @name Acoustic Stream Custom Services and Characteristics
 * -----------------------------------------------------------------------------
 */

/**
 *  The service UUID string for Acoustic Stream's custom data.
 *
 *  This service contains characteristics `ASEnvDataCharactUUID`, `ASEnvMeasIntervalCharactUUID`, 
 *  `ASEnvAlertIntervalCharactUUID`, `ASEnvAlarmLimitsCharactUUID`, `ASEnvRealtimeCharactUUID`, 
 *  `ASAccDataCharactUUID`, `ASAccActivityCharactUUID`, `ASAccEnableCharactUUID`, `ASAccSelfTestCharactUUID`, 
 *  `ASAccCalParamsCharactUUID`, `ASAccThresholdCharactUUID`, `ASErrorCharactUUID`,
 *  `ASAIOCharactUUID`, `ASBlinkCharactUUID`, and `ASRegistrationCharactUUID`.
 */
extern NSString * const ASServiceUUID;

/**
 *  The characteristic UUID string for the environmental data.
 *
 *  This characteristic contains humidity, temperature, and timestamp data.
 *
 *  Read: Y, Write: N, Indicate: Y, Notify: Y
 *  @see `ASDevice` properties `humidData`, `humidDates`, `tempData`, and `tempDates`
 *
 *  BLE Packet Structure:
 *  Software Revision: Earlier than (and not including) 0.4.0
 *  Data Length: 8 bytes
 *  Data Format [0:5]: Time since sampled (microseconds) - uint48, Big-endian
 *                [6]: Humidity (% RH) - uint8
 *                [7]: Temperature (deg C) - int8
 *
 *  Software Revision 0.4.0 or higher
 *  Data Length: 10 bytes
 *  Data Format [0:5]: Time since sampled (microseconds) - uint48, Big-endian
 *              [6:7]: Humidity (% RH) * 100 - uint16, Big-endian
 *              [8:9]: Temperature (deg C) * 100 - int16, Big-endian
 */
extern NSString * const ASEnvDataCharactUUID;

/**
 *  The characteristic UUID string for the default measurement interval for environmental data.
 *
 *  This characteristic contains the default measurement interval that the hardware samples at for
 *  all environmental data.  Must be a positive integer less than 2^32.  The hardware samples at this
 *  rate when it measure the environment within the hardware-set humidity and temperature bounds.
 *
 *  Read: Y, Write: Y, Indicate: N, Notify: N
 *  @see `ASDevice` property `measurementInterval` and the `writeEnvMeasInterval` method in the 
 *  `ASDevice(Write)` category
 *
 *  BLE Packet Structure:
 *  Data Length: 4 bytes
 *  Data Format [0:3]: Measurement interval (seconds) - uint32, Big-endian
 */
extern NSString * const ASEnvMeasIntervalCharactUUID;

/**
 *  The characteristic UUID string for the alert measurement interval for environmental data.
 *
 *  This characteristic contains the alert interval that the hardware samples at for
 *  all environmental data.  Must be a positive integer less than 2^32.  The hardware samples at this
 *  rate when it measure the environment outside the hardware-set humidity and temperature bounds.
 *  The hardware also samples at this rate when it detects accelerometer activity.
 *
 *  Read: Y, Write: Y, Indicate: N, Notify: N
 *  @see `ASDevice` property `alertInterval` and the `writeEnvAlertInterval` method in the
 *  `ASDevice(Write)` category
 *
 *  BLE Packet Structure:
 *  Data Length: 4 bytes
 *  Data Format [0:3]: Alert interval (seconds) - uint32, Big-endian
 */
extern NSString * const ASEnvAlertIntervalCharactUUID;

/**
 *  The characteristic UUID string for the internal alarm limits for humidity and temperature.
 *
 *  This characteristic contains the values for the internal alarm limits for humidity and temperature
 *  that trigger the alert interval sampling rate.
 *
 *  Read: Y, Write: Y, Indicate: N, Notify: N
 *  @see `ASDevice` properties `hardwareHumidAlarmMax`, `hardwareHumidAlarmMin`, `hardwareTempAlarmMax`,
 *  and `hardwareTempAlarmMin`, and the `writeEnvAlarmLimitsHumidityHigh:humidLow:temperatureHigh:temperatureLow:completion:`
 *  method in the `ASDevice(Write)` category
 *
 *  BLE Packet Structure:
 *  Software Revision: Earlier than (and not including) 0.4.0
 *  Data Length: 4 bytes
 *  Data Format [0]: Humidity Maximum (% RH) - uint8
 *              [1]: Humidity Minimum (% RH) - uint8
 *              [2]: Temperature Maximum (deg C) - int8
 *              [3]: Temperature Minimum (deg C) - int8
 *
 *  Software Revision 0.4.0 or higher
 *  Data Length: 8 bytes
 *  Data Format [0:1]: Humidity Maximum (% RH) * 100 - uint16, Big-endian
 *              [2:3]: Humidity Minimum (% RH) * 100 - uint16, Big-endian
 *              [4:5]: Temperature Maximum (deg C) * 100 - int16, Big-endian
 *              [6:7]: Temperature Minimum (deg C) * 100 - int16, Big-endian
 */
extern NSString * const ASEnvAlarmLimitsCharactUUID;

/**
 *  The characteristic UUID string for setting realtime mode.
 *
 *  This characteristic contains the setting for realtime mode.  When it is set to 1, for 60 seconds,
 *  the hardware will sample environmental data every 10 seconds.  At the end of the 60 seconds, this
 *  setting will be set back to 0.
 *
 *  Read: Y, Write: Y, Indicate: N, Notify: N
 *  @see `ASConfig` property `realtimeMode`
 *
 *  BLE Packet Structure:
 *  Data Length: 1 bytes
 *  Data Format [0]: Realtime Setting (0x00 or 0x01) - uint8
 */
extern NSString * const ASEnvRealtimeCharactUUID;

/**
 *  The characteristic UUID string for the accelerometer data.
 *
 *  This characteristic contains the accelerometer data (x, y, and z) as well as the timestamp
 *  whenever the device detects a g-force spike.
 *
 *  Read: Y, Write: N, Indicate: Y, Notify: Y
 *  @see `ASDevice` properties `accelData` and `accelDates`
 *
 *  BLE Packet Structure:
 *  Data Length: 12 bytes
 *  Data Format [0:5]: Time since sampled (microseconds) - uint48, Big-endian
 *              [6:7]: X Acceleration (g's) * 32 - int16, Big-endian
 *              [8:9]: Y Acceleration (g's) * 32 - int16, Big-endian
 *            [10:11]: Z Acceleration (g's) * 32 - int16, Big-endian
 */
extern NSString * const ASAccDataCharactUUID;

/**
 *  The characteristic UUID string for the activity data.
 *
 *  This characteristic contains the activity data and timestamp that the hardware sends
 *  whenever the hardware detects movement.
 *
 *  Read: Y, Write: N, Indicate: Y, Notify: Y
 *  @see `ASDevice` properties `activityData` and `activityDates`
 *
 *  BLE Packet Structure:
 *  Data Length: 7 bytes
 *  Data Format [0:5]: Time since sampled (microseconds) - uint48, Big-endian
 *                [6]: Activity data (0x00 or 0x01) - uint8
 */
extern NSString * const ASAccActivityCharactUUID;

/**
 *  The characteristic UUID string for setting the accelerometer functional mode.
 *
 *  This characteristic can be set to 0x00 to turn the accelerometer off, 0x01 to enable all accelerometer
 *  functions, or to 0x02 to set the accelerometer to only measure activity.  In versions less than
 *  0.4.1, the accelerometer can only be toggled between all functions (0x01) or none (0x00).
 *
 *  Read: Y, Write: Y, Indicate: N, Notify: N
 *  @see `ASDevice` property `accelSetting` and the `writeAccelerometerSetting:completion:` method in the
 *  `ASDevice(Write)` category
 *
 *  BLE Packet Structure:
 *  Software Revision: Earlier than (and not including) 0.4.1
 *  Data Length: 1 byte
 *  Data Format [0]: Accelerometer enable (0x00, 0x01) - uint8
 *
 *  Software Revision 0.4.1 or higher
 *  Data Length: 1 bytes
 *  Data Format [0]: Accelerometer enable (0x00, 0x01, or 0x02) - uint8
 */
extern NSString * const ASAccEnableCharactUUID;

/**
 *  The characteristic UUID string to read the result of the accelerometer self-test.
 *  No longer available in firmware version 0.4.1.
 */
extern NSString * const ASAccSelfTestCharactUUID __attribute__((deprecated));

/**
 *  Accelerometer calibration parameters characteristic
 *  No longer available in firmware version 0.4.1.
 */
extern NSString * const ASAccCalParamsCharactUUID __attribute__((deprecated));

/**
 *  Accelerometer threshold characteristic
 */
extern NSString * const ASAccThresholdCharactUUID;

/**
 *  Error characteristic
 */
extern NSString * const ASErrorCharactUUID;

/**
 *  The characteristic UUID string to read and write to the PIO hardware pins.
 *
 *  This characteristic contains a unsigned 8-bit integer where the three least significant bytes
 *  correspond to the PIO pins.  They can be toggled on (1) or off (0).  The 5 most significant
 *  byte are ignored.  The time is ignored when writing to this characteristic.  Bit 2 corresponds
 *  to pin 0, bit 1 corresponds to pin 1, and bit 0 corresponds to pin 2.
 *
 *  Read: Y, Write: Y, Indicate: Y, Notify: Y
 *
 *  BLE Packet Structure:
 *  Data Length: 7 bytes
 *  Data Format [0:5]: Time since sampled (microseconds) - uint48, Big-endian
 *                [6]: PIO data - uint8
 */
extern NSString * const ASPIOCharactUUID;

/**
 *  The characteristic UUID string to read and write to the AIO hardware pins.
 *
 *  This characteristic contains the analog data to read or write.  Values must be integers between
 *  or equal to 0 and 1350.  The units are millivolts.
 *
 *  Read: Y, Write: Y, Indicate: N, Notify: N
 *
 *  BLE Packet Structure:
 *  Data Length: 6 bytes
 *  Data Format [0:1]: 1st analog pin value - uint16, Big-endian
 *              [2:3]: 2nd analog pin value - uint16, Big-endian
 *              [4:5]: 3rd analog pin value - uint16, Big-endian
 */
extern NSString * const ASAIOCharactUUID;

/**
 *  The characteristic UUID string to blink the onboard LED any number times.
 *
 *  This characteristic contains an unsigned integer between 0 and 255 blinking the
 *  LED that many times.
 *
 *  Read: Y, Write: Y, Indicate: N, Notify: N
 *
 *  BLE Packet Structure:
 *  Data Length: 1 byte
 *  Data Format [0]: Number of times to blink - uint8
 */
extern NSString * const ASBlinkCharactUUID;

/**
 *  The characteristic UUID string to validate the registration process.
 *
 *  This characteristic contains the registration data to validate the authenticity of the 
 *  hardware and its link to the server.  When written to, it will respond using notify.
 *
 *  Read: N, Write: Y, Indicate: Y, Notify: Y
 *
 *  BLE Packet Structure:
 *  Data Length: 16 bytes
 *  Data Format [0:15]: Registration data - uint128, Little-endian
 */
extern NSString * const ASRegistrationCharactUUID;

/**
 *  Description
 */
extern NSString * const ASTimeSyncCharactUUID;

/**-----------------------------------------------------------------------------
 * @name Standard BLE Services and Characteristics
 * -----------------------------------------------------------------------------
 */

/**
 *  The service UUID string for the battery service.
 *
 *  This service contains the characteristics `ASBatteryCharactUUID`.
 */
extern NSString * const ASBatteryServiceUUID;

/**
 *  The characteristic UUID string to read the battery data.
 *
 *  This characteristic contains an unsigned integer between 0 and 100 estimating the remaining
 *  battery percentage.
 *
 *  Read: Y, Write: N, Indicate: N, Notify: N
 *
 *  BLE Packet Structure:
 *  Data Length: 1 byte
 *  Data Format [0]: Battery value - uint8
 */
extern NSString * const ASBatteryCharactUUID;

/**
 *  The service UUID string for the standard device information service.
 *
 *  This service contains the characteristics `ASManNameCharactUUID`, `ASModelNoCharactUUID`, 
 *  `ASSerialNoCharactUUID`, `ASHardwareRevCharactUUID`, `ASFirmwareRevCharactUUID`, 
 *  `ASSoftwareRevCharactUUID`, and `ASSystemIDCharactUUID`.
 */
extern NSString * const ASDevInfoServiceUUID;

/**
 *  The characteristic UUID string for the manufacturer's name.
 *
 *  This characteristic is a UTF-8 string representing the name of the hardware's manufacturer.
 *
 *  Read: Y, Write: N, Indicate: N, Notify: N
 *
 *  BLE Packet Structure:
 *  Data Length: Variable
 */
extern NSString * const ASManNameCharactUUID __attribute__((deprecated));

/**
 *  The characteristic UUID string for the model number.
 *
 *  This characteristic is a UTF-8 string representing the name of the hardware's model number.
 *
 *  Read: Y, Write: N, Indicate: N, Notify: N
 *
 *  BLE Packet Structure:
 *  Data Length: Variable
 */
extern NSString * const ASModelNoCharactUUID __attribute__((deprecated));

/**
 *  The characteristic UUID string for the serial number.
 *
 *  This characteristic is a UTF-8 string representing the name of the hardware's serial number.
 *
 *  Read: Y, Write: N, Indicate: N, Notify: N
 *
 *  BLE Packet Structure:
 *  Data Length: Variable
 */
extern NSString * const ASSerialNoCharactUUID;

/**
 *  The characteristic UUID string for the hardware revision number.
 *
 *  This characteristic is a UTF-8 string representing the name of the hardware's revision number.
 *
 *  Read: Y, Write: N, Indicate: N, Notify: N
 *
 *  BLE Packet Structure:
 *  Data Length: Variable
 */
extern NSString * const ASHardwareRevCharactUUID;

/**
 *  The characteristic UUID string for the firmware revision number.
 *
 *  This characteristic is a UTF-8 string representing the name of the hardware's firmware revision number.
 *
 *  Read: Y, Write: N, Indicate: N, Notify: N
 *
 *  BLE Packet Structure:
 *  Data Length: Variable
 */
extern NSString * const ASFirmwareRevCharactUUID __attribute__((deprecated));

/**
 *  The characteristic UUID string for the software revision number.
 *
 *  This characteristic is a UTF-8 string representing the name of the hardware's software revision number.
 *
 *  Read: Y, Write: N, Indicate: N, Notify: N
 *
 *  BLE Packet Structure:
 *  Data Length: Variable
 */
extern NSString * const ASSoftwareRevCharactUUID;

/**
 *  The characteristic UUID string for the standard BLE system identifier.
 *
 *  This characteristic is TBD.  Yes, this is in a ridiculous order.  Unfortunately it's part of the BLE
 *  stack and cannot be changed.  0th place is the most significant byte.
 *
 *  Read: Y, Write: N, Indicate: N, Notify: N
 *
 *  BLE Packet Structure:
 *  Data Length: 8 bytes
 *  Data Format [0]: 1st place byte - uint8
 *              [1]: 0th place byte - uint8
 *              [2]: 5th place byte - uint8
 *              [3]: 4th place byte - uint8
 *              [4]: 3rd place byte - uint8
 *              [5]: 2nd place byte - uint8
 *              [6]: 7th place byte - uint8
 *              [7]: 6th place byte - uint8
 */
extern NSString * const ASSystemIDCharactUUID __attribute__((deprecated));

extern NSString * const ASServiceUUIDv3;

extern NSString * const ASTimeSyncCharacteristicUUIDv3;
extern NSString * const ASRegistrationCharacteristicUUIDv3;
extern NSString * const ASErrorStateCharacteristicUUIDv3;
extern NSString * const ASBlinkCharacteristicUUIDv3;
extern NSString * const ASEnvironmentalMeasurementBufferCharacteristicUUIDv3;
extern NSString * const ASEnvironmentalMeasurementBufferSizeCharacteristicUUIDv3;
extern NSString * const ASEnvironmentalMeasurementIntervalCharacteristicUUIDv3;
extern NSString * const ASAccelerometerModeCharacteristicUUIDv3;
extern NSString * const ASImpactBufferCharacteristicUUIDv3;
extern NSString * const ASImpactBufferSizeCharacteristicUUIDv3;
extern NSString * const ASImpactThresholdCharacteristicUUIDv3;
extern NSString * const ASActivityBufferCharacteristicUUIDv3;
extern NSString * const ASActivityBufferSizeCharacteristicUUIDv3;
extern NSString * const ASPIOBufferCharacteristicUUIDv3;
extern NSString * const ASPIOBufferSizeCharacteristicUUIDv3;
extern NSString * const ASAIOCharacteristicUUIDv3;

extern NSString * const ASServiceUUIDv4;

extern NSString * const ASBeaconModeUUID;
extern NSString * const ASBLEParametersUUID;
extern NSString * const ASBLEConnectionModeUUID;

// OTAU
extern NSString * const ASOTAUBootServiceUUID;
extern NSString * const ASOTAUVersionCharacteristicUUID;
extern NSString * const ASOTAUCurrentAppCharacteristicUUID;
extern NSString * const ASOTAUDataTransferCharacteristicUUID;
extern NSString * const ASOTAUControlTransferCharacteristicUUID;

extern NSString * const ASOTAUApplicationServiceUUID;
extern NSString * const ASOTAUKeyCharacteristicUUID;
extern NSString * const ASOTAUKeyBlockCharacteristicUUID;


@interface ASBLECharacteristicHelper : NSObject

+ (NSString *)characteristicNameFromIdentifier:(NSString *)identifier;

@end
