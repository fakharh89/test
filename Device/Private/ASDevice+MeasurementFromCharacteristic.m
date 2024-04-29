//
//  ASDevice+MeasurementFromCharacteristic.m
//  Blustream
//
//  Created by Michael Gordon on 7/19/16.
//
//

#import "ASDevice+MeasurementFromCharacteristic.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "ASAlarmLimits.h"
#import "ASBLEDefinitions.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "ASImpact.h"
#import "CBPeripheral+ASUtils.h"
#import "NSData+ASBLEResult.h"
#import "NSError+ASError.h"

@implementation ASDevice (MeasurementFromCharacteristic)

- (ASBLEResult<ASEnvironmentalMeasurement *> *)as_processEnvironmentalMeasurementFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASEnvDataCharactUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_environmentalMeasurementWithFirmwareVersion:self.softwareRevision];
}

- (ASBLEResult<NSNumber *> *)as_processMeasurementIntervalFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    NSString *characteristicString = ASEnvMeasIntervalCharactUUID;
    
    if ([@"3.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        characteristicString = ASEnvironmentalMeasurementIntervalCharacteristicUUIDv3;
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:characteristicString];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_timeInterval];
}

- (ASBLEResult<NSNumber *> *)as_processAlertIntervalFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASEnvAlertIntervalCharactUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_timeInterval];
}

- (ASBLEResult<ASAlarmLimits *> *)as_processAlarmLimitsFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASEnvAlarmLimitsCharactUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_alarmLimits];
}

- (ASBLEResult<ASImpact *> *)as_processImpactFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASAccDataCharactUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_impactWithFirmwareVersion:self.softwareRevision];
}

- (ASBLEResult<ASActivityState *> *)as_processActivityStateFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASAccActivityCharactUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_activityStateWithFirmwareVersion:self.softwareRevision];
}

- (ASBLEResult<NSNumber *> *)as_processAccelerometerModeFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    NSString *characteristicString = ASAccEnableCharactUUID;
    
    if ([@"3.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        characteristicString = ASAccelerometerModeCharacteristicUUIDv3;
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:characteristicString];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_accelerometerMode];
}

- (ASBLEResult<NSNumber *> *)as_processAccelerometerThresholdFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    NSString *characteristicString = ASAccThresholdCharactUUID;
    
    if ([@"3.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        characteristicString = ASImpactThresholdCharacteristicUUIDv3;
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:characteristicString];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_accelerometerThreshold];
}

- (ASBLEResult<ASErrorState *> *)as_processErrorStateFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    // TODO Be clear on characteristics vs strings vs uuid strings
    NSString *characteristicString = ASErrorCharactUUID;
    
    if ([@"3.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        characteristicString = ASErrorStateCharacteristicUUIDv3;
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:characteristicString];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_errorState];
}

- (ASBLEResult<ASPIOState *> *)as_processPIOStateFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASPIOCharactUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_PIOStateWithFirmwareVersion:self.softwareRevision];
}

- (ASBLEResult<ASAIOMeasurement *> *)as_processAIOMeasurementFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASPIOCharactUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_AIOMeasurement];
}

- (ASBLEResult<ASBatteryLevel *> *)as_processBatteryLevelFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASBatteryCharactUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_batteryLevel];
}

- (ASBLEResult<NSString *> *)as_processSerialNumberFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASSerialNoCharactUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_serialNumber];
}

- (ASBLEResult<NSString *> *)as_processHardwareRevisionFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASHardwareRevCharactUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_UTF8String];
}

- (ASBLEResult<NSString *> *)as_processSoftwareRevisionFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASSoftwareRevCharactUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_UTF8String];
}

- (ASBLEResult<NSData *> *)as_processRegistrationDataFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    NSString *characteristicString = ASRegistrationCharactUUID;
    
    if ([@"3.0.0" compare:self.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        characteristicString = ASRegistrationCharacteristicUUIDv3;
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:characteristicString];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_registrationData];
}

- (ASBLEResult<NSArray<ASBLEResult<ASEnvironmentalMeasurement *> *> *> *)as_processEnvironmentalMeasurementBufferFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASEnvironmentalMeasurementBufferCharacteristicUUIDv3];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_environmentalMeasurementBufferWithFirmwareVersion:self.softwareRevision];
}

- (ASBLEResult<NSNumber *> *)as_processEnvironmentalBufferSizeFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASEnvironmentalMeasurementBufferSizeCharacteristicUUIDv3];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_bufferSize];
}

- (ASBLEResult<NSArray<ASBLEResult<ASImpact *> *> *> *)as_processImpactBufferFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASImpactBufferCharacteristicUUIDv3];
    
    return [characteristic.value as_impactBufferWithFirmwareVersion:self.softwareRevision];
}

- (ASBLEResult<NSNumber *> *)as_processImpactBufferSizeFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASImpactBufferSizeCharacteristicUUIDv3];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_bufferSize];
}

- (ASBLEResult<NSArray<ASBLEResult<ASActivityState *> *> *> *)as_processActivityBufferFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASActivityBufferCharacteristicUUIDv3];
    
    return [characteristic.value as_activityBufferWithFirmwareVersion:self.softwareRevision];
}

- (ASBLEResult<NSNumber *> *)as_processActivityBufferSizeFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASActivityBufferSizeCharacteristicUUIDv3];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_bufferSize];
}

- (ASBLEResult<NSArray<ASBLEResult<ASPIOState *> *> *> *)as_processPIOBufferFromCharacteristic {
    if (!self.softwareRevision) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorVersionUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASPIOBufferCharacteristicUUIDv3];
    
    return [characteristic.value as_PIOBufferWithFirmwareVersion:self.softwareRevision];
}

- (ASBLEResult<NSNumber *> *)as_processPIOBufferSizeFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASPIOBufferSizeCharacteristicUUIDv3];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_bufferSize];
}

- (ASBLEResult<NSNumber *> *)as_processOTAUVersionFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASOTAUVersionCharacteristicUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_OTAUVersion];
}

- (ASBLEResult<NSData *> *)as_processOTAUDataTransferFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASOTAUDataTransferCharacteristicUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_OTAUDataTransfer];
}

- (ASBLEResult<NSNumber *> *)as_processOTAUTransferControlFromCharacteristic {
    CBCharacteristic *characteristic = [self.peripheral getCharacteristic:ASOTAUControlTransferCharacteristicUUID];
    
    if (!characteristic.value) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceErrorCharacteristicDataMissing underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [characteristic.value as_OTAUTransferControl];
}

@end
