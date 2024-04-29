//
//  ASDevice+Write.h
//  Blustream
//
//  Created by Michael Gordon on 2/4/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice.h"

/**
 *  This category adds methods to `ASDevice` to write values to the hardware over BLE.  If a command is issued, another command
 *  of the same type cannot be issued until the first completes or the hardware disconnects.
 */
@interface ASDevice (Write)

/**
 *  Sets the environmental measurement interval.  This is the default rate at which the hardware samples.
 *  The recommended setting for this is 3600 seconds (1 hour).
 *
 *  @param interval   The time interval in seconds.  Must be an non-zero unsigned integer between 0 and 2^48.
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)writeEnvironmentalMeasurementInterval:(NSNumber *)interval completion:(void (^)(NSError *error))completion;

/**
 *  Sets the alert measurement interval.  This is the rate at which the hardware samples when it detects movement,
 *  or the environment is outside the hardware alarm limits.  The recommended setting for this is 1800 seconds (30 minutes).
 *
 *  @param interval   The time interval in seconds.  Must be an non-zero unsigned integer between 0 and 2^48.
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)writeEnvironmentalAlertInterval:(NSNumber *)interval completion:(void (^)(NSError *error))completion;

/**
 *  Sets the internal alarm parameters that trigger sampling at the alert sampling interval.
 *
 *  @param hHigh      The upper bound for humidity in percent relative humidity.  Must be 100.0 or less and greater
 *                    than the lower bound.  Can have decimal resolution up to two places, but the humidity sensor 
 *                    is only accurate to +/- 3% RH.
 *  @param hLow       The lower bound for humidity in percent relative humidity.  Must be 0.0 or greater and less
 *                    than the upper bound.  Can have decimal resolution up to two places, but the humidity sensor
 *                    is only accurate to +/- 3% RH.
 *  @param tHigh      The upper bound for temperature in degrees Celsius.  Must be 125.0 or less and greater than
 *                    the lower bound.  Can have decimal resolution up to two places, but the temperature sensor is
 *                    only accurate to +/- 0.3°C.
 *  @param tLow       The lower bound for temperature in degrees Celsius.  Must be greater than -40.0 and less than
 *                    the upper bound.  Can have decimal resolution up to two places, but the humidity sensor is only
 *                    accurate to +/- 0.3°C.
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)writeEnvironmentalAlarmLimitsHumidityHigh:(NSNumber *)hHigh humidityLow:(NSNumber *)hLow temperatureHigh:(NSNumber *)tHigh temperatureLow:(NSNumber *)tLow completion:(void (^)(NSError *error))completion;

/**
 *  Sets the accelerometer mode for power saving.  The accelerometer can be disabled, set measure to activity-only, or set to
 *  measure activity and g-force detection.
 *
 *  @param setting    The accelerometer setting.  See ASAccelerometerMode for options.
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)writeAccelerometerSetting:(ASAccelerometerMode)setting completion:(void (^)(NSError *error))completion;

/**
 *  Sets the accelerometer mode for power saving.  The accelerometer can be disabled, set measure to activity-only, or set to
 *  measure activity and g-force detection.
 *
 *  @param setting                The accelerometer setting.  See ASAccelerometerMode for options.
 *  @param pendingWriteCompletion The block called upon adding a command into pending queue till next connect to the sensor (for v4 and higher sensors only).
 *  @param completion             The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)writeAccelerometerSetting:(ASAccelerometerMode)setting pendingWriteCompletion:(void(^)(void))pendingWriteCompletion completion:(void (^)(NSError *error))completion;

/**
 *  Sets the g-force detection trigger level.
 *
 *  @param threshold  The g-force minimum level in g.  Must be greater than 0 and less than 16.  Threshold
 *  is rounded to the nearest 62.5 mg interval (hardware resolution is 62.5 mg per LSB).  Maximum write-able
 *  value is technically 15.9375 g.
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)writeAccelerometerThreshold:(NSNumber *)threshold completion:(void (^)(NSError *error))completion;

/**
 *  Sets the g-force detection trigger level.
 *
 *  @param threshold The g-force minimum level in g.  Must be greater than 0 and less than 16.  Threshold
 *  is rounded to the nearest 62.5 mg interval (hardware resolution is 62.5 mg per LSB).  Maximum write-able
 *  value is technically 15.9375 g.
 *  @param pendingWriteCompletion The block called upon adding a command into pending queue till next connect to the sensor (for v4 and higher sensors only).
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)writeAccelerometerThreshold:(NSNumber *)threshold pendingWriteCompletion:(void(^)(void))pendingWriteCompletion completion:(void (^)(NSError *error))completion;

/**
 *  Sets the PIO state for the digital pins.  The three pins correspond to the three least significant bits
 *  in the method input.  (1 is voltage high, 0 is voltage low).
 *
 *  @param PIO        The pin state (unsigned char).
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)writePIO:(NSNumber *)PIO completion:(void (^)(NSError *error))completion;

/**
 *  Blinks the hardware a variable number of times.
 *
 *  @param nBlinks    The number of blinks the hardware shall perform.  Must be a positive and non-zero integer.
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)blinkNTimes:(NSNumber *)nBlinks completion:(void (^)(NSError *error))completion;

/**
 *  Blinks the hardware a variable number of times.
 *
 *  @param nBlinks                The number of blinks the hardware shall perform.  Must be a positive and non-zero integer.
 *  @param pendingWriteCompletion The block called upon adding a command into pending queue till next connect to the sensor (for v4 and higher sensors only).
 *  @param completion             The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)blinkNTimes:(NSNumber *)nBlinks pendingWriteCompletion:(void(^)(void))pendingWriteCompletion completion:(void (^)(NSError *error))completion;

/**
 *  Sets the hardware in realtime mode for one minute.  This temporarily adjusts the environmental sampling
 *  period to ten seconds.  If realtime mode is enabled in ASConfig, it is not recommended to call this
 *  method manually.  If realtime mode is disabled, calling this function sporadically can improve hardware
 *  battery life.  For example, you may only need to call it when the app first loads or when the user
 *  brings up the detail view for a container.
 *
 *  @param allowAllRevisions Bool flag to indicate wether it can be used for all software revisions
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)writeRealtimeModeForAllSoftwareRevision:(BOOL)allowAllRevisions
                                 withCompletion:(void (^)(NSError *error))completion;

@end
