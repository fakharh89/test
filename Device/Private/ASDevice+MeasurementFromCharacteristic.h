//
//  ASDevice+MeasurementFromCharacteristic.h
//  Blustream
//
//  Created by Michael Gordon on 7/19/16.
//
//

#import "ASDevice.h"

#import "ASBLEResult.h"

@class ASEnvironmentalMeasurement, ASAlarmLimits, ASImpact, ASActivityState, ASErrorState, ASPIOState, ASAIOMeasurement, ASBatteryLevel;

@interface ASDevice (MeasurementFromCharacteristic)

- (ASBLEResult<ASEnvironmentalMeasurement *> *)as_processEnvironmentalMeasurementFromCharacteristic;
- (ASBLEResult<NSNumber *> *)as_processMeasurementIntervalFromCharacteristic;
- (ASBLEResult<NSNumber *> *)as_processAlertIntervalFromCharacteristic;
- (ASBLEResult<ASAlarmLimits *> *)as_processAlarmLimitsFromCharacteristic;
- (ASBLEResult<ASImpact *> *)as_processImpactFromCharacteristic;
- (ASBLEResult<ASActivityState *> *)as_processActivityStateFromCharacteristic;
- (ASBLEResult<NSNumber *> *)as_processAccelerometerModeFromCharacteristic;
- (ASBLEResult<NSNumber *> *)as_processAccelerometerThresholdFromCharacteristic;
- (ASBLEResult<ASErrorState *> *)as_processErrorStateFromCharacteristic;
- (ASBLEResult<ASPIOState *> *)as_processPIOStateFromCharacteristic;
- (ASBLEResult<ASAIOMeasurement *> *)as_processAIOMeasurementFromCharacteristic;
- (ASBLEResult<ASBatteryLevel *> *)as_processBatteryLevelFromCharacteristic;
- (ASBLEResult<NSString *> *)as_processSerialNumberFromCharacteristic;
- (ASBLEResult<NSString *> *)as_processHardwareRevisionFromCharacteristic;
- (ASBLEResult<NSString *> *)as_processSoftwareRevisionFromCharacteristic;
- (ASBLEResult<NSData *> *)as_processRegistrationDataFromCharacteristic;
- (ASBLEResult<NSArray<ASBLEResult<ASEnvironmentalMeasurement *> *> *> *)as_processEnvironmentalMeasurementBufferFromCharacteristic;
- (ASBLEResult<NSNumber *> *)as_processEnvironmentalBufferSizeFromCharacteristic;
- (ASBLEResult<NSArray<ASImpact *> *> *)as_processImpactBufferFromCharacteristic;
- (ASBLEResult<NSNumber *> *)as_processImpactBufferSizeFromCharacteristic;
- (ASBLEResult<NSArray<ASBLEResult<ASActivityState *> *> *> *)as_processActivityBufferFromCharacteristic;
- (ASBLEResult<NSNumber *> *)as_processActivityBufferSizeFromCharacteristic;
- (ASBLEResult<NSArray<ASBLEResult<ASPIOState *> *> *> *)as_processPIOBufferFromCharacteristic;
- (ASBLEResult<NSNumber *> *)as_processPIOBufferSizeFromCharacteristic;

- (ASBLEResult<NSNumber *> *)as_processOTAUVersionFromCharacteristic;
- (ASBLEResult<NSData *> *)as_processOTAUDataTransferFromCharacteristic;
- (ASBLEResult<NSNumber *> *)as_processOTAUTransferControlFromCharacteristic;

@end
