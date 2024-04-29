//
//  NSData+ASBLEResult.h
//  Blustream
//
//  Created by Michael Gordon on 7/7/16.
//
//

#import <Foundation/Foundation.h>

#import "ASDevice.h"
#import "ASBLEResult.h"

@class ASBatteryLevel, ASEnvironmentalMeasurement, ASImpact, ASActivityState, ASPIOState, ASAIOMeasurement, ASErrorState, ASAlarmLimits, ASManufacturerData;

@interface NSData (ASBLEResult)

// TODO Make firmware version nomenclature consistent

- (ASBLEResult<ASManufacturerData *> *)as_manufacturerData;
- (ASBLEResult<ASEnvironmentalMeasurement *> *)as_environmentalMeasurementWithFirmwareVersion:(NSString *)version;
- (ASBLEResult<NSNumber *> *)as_timeInterval;
- (ASBLEResult<ASAlarmLimits *> *)as_alarmLimits;
- (ASBLEResult<ASBatteryLevel *> *)as_batteryLevel;
- (ASBLEResult<ASImpact *> *)as_impactWithFirmwareVersion:(NSString *)version;
- (ASBLEResult<ASActivityState *> *)as_activityStateWithFirmwareVersion:(NSString *)version;
- (ASBLEResult<ASPIOState *> *)as_PIOStateWithFirmwareVersion:(NSString *)version;
- (ASBLEResult<ASAIOMeasurement *> *)as_AIOMeasurement;
- (ASBLEResult<ASErrorState *> *)as_errorState;
- (ASBLEResult<NSNumber *> *)as_accelerometerMode;
- (ASBLEResult<NSNumber *> *)as_accelerometerThreshold;
- (ASBLEResult<NSString *> *)as_UTF8String;
- (ASBLEResult<NSString *> *)as_serialNumber;
- (ASBLEResult<NSData *> *)as_registrationData;
- (ASBLEResult<NSArray<ASBLEResult<ASEnvironmentalMeasurement *> *> *> *)as_environmentalMeasurementBufferWithFirmwareVersion:(NSString *)version;
- (ASBLEResult<NSArray<ASBLEResult<ASImpact *> *> *> *)as_impactBufferWithFirmwareVersion:(NSString *)version;
- (ASBLEResult<NSArray<ASBLEResult<ASActivityState *> *> *> *)as_activityBufferWithFirmwareVersion:(NSString *)version;
- (ASBLEResult<NSArray<ASBLEResult<ASPIOState *> *> *> *)as_PIOBufferWithFirmwareVersion:(NSString *)version;
- (ASBLEResult<NSNumber *> *)as_bufferSize;

- (ASBLEResult<NSNumber *> *)as_OTAUVersion;
- (ASBLEResult<NSData *> *)as_OTAUDataTransfer;
- (ASBLEResult<NSNumber *> *)as_OTAUTransferControl;

@end
