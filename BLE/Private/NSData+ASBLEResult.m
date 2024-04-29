//
//  NSData+ASBLEResult.m
//  Blustream
//
//  Created by Michael Gordon on 7/7/16.
//
//

#import "NSData+ASBLEResult.h"

#import "ASActivityState.h"
#import "ASAIOMeasurement.h"
#import "ASAlarmLimits.h"
#import "ASBatteryLevel.h"
#import "ASEnvironmentalMeasurement.h"
#import "ASErrorDefinitions.h"
#import "ASErrorState.h"
#import "ASImpact.h"
#import "ASLog.h"
#import "ASManufacturerData.h"
#import "ASPIOState.h"
#import "NSDate+ASRoundDate.h"
#import "NSNumber+ASRoundNumber.h"
#import "NSError+ASError.h"

#import "NSString+ASHexString.h"

@implementation NSData (ASBLEResult)

- (ASBLEResult<ASManufacturerData *> *)as_manufacturerData {
    unsigned char *rawData = (unsigned char *) self.bytes;
    
    ASManufacturerData *manufacturerData = [[ASManufacturerData alloc] init];
    
    NSString *str = nil;
    str = [NSString stringWithFormat:@"%02x", rawData[5]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"%02x", rawData[4]]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"%02x", rawData[3]]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"%02x", rawData[2]]];
    
    manufacturerData.serialNumber = str;
    
    uint16_t humidity = (rawData[7] << 8) + rawData[6];
    int16_t temperature = (rawData[9] << 8) + rawData[8];
    NSDate *now = [[NSDate date] as_roundMillisecondsToThousands];
    manufacturerData.environmentalMeasurement = [[ASEnvironmentalMeasurement alloc] initWithDate:now humidity:[@(humidity / 100.0) as_roundToHundreths] temperature:[@(temperature / 100.0) as_roundToHundreths]];
    manufacturerData.batterylevel = [[ASBatteryLevel alloc] initWithDate:now batteryLevel:@(rawData[10])];
    manufacturerData.errorState = [[ASErrorState alloc] initWithDate:now errorState:@(rawData[11])];
    
    return [[ASBLEResult alloc] initWithValue:manufacturerData data:self error:nil];
}

- (ASBLEResult<ASEnvironmentalMeasurement *> *)as_environmentalMeasurementWithFirmwareVersion:(NSString *)version {
    NSParameterAssert(version);
    
    unsigned char *rawData = (unsigned char *) self.bytes;
    
    float h = 0;
    float t = 0;
    
    if (self.length == 8) {
        // Data format: 0-5 time in us, 6 is humidity (% RH), 7 is temp (deg C)
        uint8_t hraw = rawData[6];
        int8_t traw = rawData[7];
        
        h = hraw;
        t = traw;
    }
    else if (self.length == 10) {
        // Data format: 0-5 time in us, 6 and 7 are humidity (% RH), 8 and 9 are temp (deg C)
        int16_t hraw = (rawData[7] << 8) + rawData[6];
        int16_t traw = (rawData[9] << 8) + rawData[8];
        
        h = ((float) hraw) / 100.0;
        t = ((float) traw) / 100.0;
    }
    else {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorBufferSizeInvalid underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:self error:error];
    }
    
    // Make sure humidity is ok
    if ([@"4.0.0" compare:version options:NSNumericSearch] != NSOrderedDescending) {
        ASLog(@"%x %x", rawData[6], rawData[7]);
        if ((h < -5) || (h > 105)) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorDataOutOfRange underlyingError:nil];
            return [[ASBLEResult alloc] initWithValue:nil data:self error:error];
        }
    }
    else {
        if ((h < 0) || (h > 100)) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorDataOutOfRange underlyingError:nil];
            return [[ASBLEResult alloc] initWithValue:nil data:self error:error];
        }
    }
    
    // Make sure temperature is ok
    if ((t < -50) || (t > 150)) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorDataOutOfRange underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:self error:error];
    }
    
    // Calculate time
    NSDate *time = nil;
    if ([@"2.0.0" compare:version options:NSNumericSearch] == NSOrderedDescending) {
        time = [self getTimeLegacy:[self subdataWithRange:NSMakeRange(0, 6)]];
    }
    else {
        time = [self getTime:[self subdataWithRange:NSMakeRange(0, 6)]];
    }
    
    // Check that time isn't more than a day in the future or more that year in past (it should never be in the future at all)
    NSError *invalidTimeError = [self invalidTimeError:time];
    if (invalidTimeError != nil) {
        return [[ASBLEResult alloc] initWithValue:nil data:self error:invalidTimeError];
    }
    
    NSNumber *humidity = [@(h) as_roundToHundreths];
    NSNumber *temperature = [@(t) as_roundToHundreths];
    ASEnvironmentalMeasurement *measurement = [[ASEnvironmentalMeasurement alloc] initWithDate:time humidity:humidity temperature:temperature];
    
    return [[ASBLEResult alloc] initWithValue:measurement data:self error:nil];
}

- (ASBLEResult<NSNumber *> *)as_timeInterval {
    unsigned char *rawData = (unsigned char *) self.bytes;
    unsigned int time = 0;
    
    for (int i = 3; i >= 0; i--) {
        time = time << 8;
        time |= (unsigned char) rawData[i];
    }
    
    return [[ASBLEResult alloc] initWithValue:@(time) data:self error:nil];
}

- (ASBLEResult<ASAlarmLimits *> *)as_alarmLimits {
    unsigned char *rawData = (unsigned char *) self.bytes;
    
    ASAlarmLimits *limits = [[ASAlarmLimits alloc] init];
    
    if (self.length == 4) {
        limits.maximumHumidity = @(rawData[0]);
        limits.minimumHumidity = @(rawData[1]);
        limits.maximumTemperature = @(rawData[2]);
        limits.minimumTemperature = @(rawData[3]);
    }
    else if (self.length == 8) {
        uint16_t hMax = (rawData[1] << 8) + rawData[0];
        uint16_t hMin = (rawData[3] << 8) + rawData[2];
        int16_t tMax = (rawData[5] << 8) + rawData[4];
        int16_t tMin = (rawData[7] << 8) + rawData[6];
        
        limits.maximumHumidity = @(((float) hMax) / 100.0);
        limits.minimumHumidity = @(((float) hMin) / 100.0);
        limits.maximumTemperature = @(((float) tMax) / 100.0);
        limits.minimumTemperature = @(((float) tMin) / 100.0);
    }
    else {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorBufferSizeInvalid underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:self error:error];
    }
    
    return [[ASBLEResult alloc] initWithValue:limits data:self error:nil];
}

- (ASBLEResult<ASBatteryLevel *> *)as_batteryLevel {
    unsigned char *rawData = (unsigned char *) self.bytes;
    NSNumber *battery = @(rawData[0]);
    NSDate *now = [[NSDate date] as_roundMillisecondsToThousands];
    
    ASBatteryLevel *level = [[ASBatteryLevel alloc] initWithDate:now batteryLevel:battery];
    return [[ASBLEResult alloc] initWithValue:level data:self error:nil];
}

- (ASBLEResult<ASImpact *> *)as_impactWithFirmwareVersion:(NSString *)version {
    unsigned char *rawData = (unsigned char *) self.bytes;
    
    // Calculate time
    NSDate *time = nil;
    if ([@"2.0.0" compare:version options:NSNumericSearch] == NSOrderedDescending) {
        time = [self getTimeLegacy:[self subdataWithRange:NSMakeRange(0, 6)]];
    }
    else {
        time = [self getTime:[self subdataWithRange:NSMakeRange(0, 6)]];
    }
    
    // Check that time isn't more than a day in the future or more that year in past (it should never be in the future at all)
    NSError *invalidTimeError = [self invalidTimeError:time];
    if (invalidTimeError != nil) {
        return [[ASBLEResult alloc] initWithValue:nil data:self error:invalidTimeError];
    }
    
    int16_t x_raw = 0, y_raw = 0, z_raw = 0;
    
    x_raw = (rawData[7] << 8) + rawData[6];
    y_raw = (rawData[9] << 8) + rawData[8];
    z_raw = (rawData[11] << 8) + rawData[10];
    
    // 4 milli-G's per LSB
    float x = 31.25 * x_raw / 1000.0;
    float y = 31.25 * y_raw / 1000.0;
    float z = 31.25 * z_raw / 1000.0;
    
    NSNumber *magnitude = [@(sqrtf(x * x + y * y + z * z)) as_roundToHundreths];
    
    ASImpact *impact = [[ASImpact alloc] initWithDate:time x:[@(x) as_roundToHundreths] y:[@(y) as_roundToHundreths] z:[@(z) as_roundToHundreths] magnitude:magnitude];
    
    return [[ASBLEResult alloc] initWithValue:impact data:self error:nil];
}

- (ASBLEResult<ASActivityState *> *)as_activityStateWithFirmwareVersion:(NSString *)version {
    // Need to subtract 56 seconds - this is the timeout for the activity packet
    
    unsigned char *rawData = (unsigned char *) self.bytes;
    
    // Calculate time
    NSDate *time = nil;
    if ([@"2.0.0" compare:version options:NSNumericSearch] == NSOrderedDescending) {
        time = [self getTimeLegacy:[self subdataWithRange:NSMakeRange(0, 6)]];
    }
    else {
        time = [self getTime:[self subdataWithRange:NSMakeRange(0, 6)]];
    }
    
    // Check that time isn't more than a day in the future or more that year in past (it should never be in the future at all)
    NSError *invalidTimeError = [self invalidTimeError:time];
    if (invalidTimeError != nil) {
        return [[ASBLEResult alloc] initWithValue:nil data:self error:invalidTimeError];
    }
    
    NSNumber *activity;
    if (rawData[6]) {
        activity = @YES;
    }
    else {
        activity = @NO;
    }
    
    ASActivityState *state = [[ASActivityState alloc] initWithDate:time activityState:activity];
    
    return [[ASBLEResult alloc] initWithValue:state data:self error:nil];
}

- (ASBLEResult<ASPIOState *> *)as_PIOStateWithFirmwareVersion:(NSString *)version {
    unsigned char *rawData = (unsigned char *) self.bytes;
    
    ASPIOState *state = nil;
    
    if (self.length == 7) {
        // Calculate time
        NSDate *time = nil;
        if ([@"2.0.0" compare:version options:NSNumericSearch] == NSOrderedDescending) {
            time = [self getTimeLegacy:[self subdataWithRange:NSMakeRange(0, 6)]];
        }
        else {
            time = [self getTime:[self subdataWithRange:NSMakeRange(0, 6)]];
        }
        NSNumber *PIOData = @(rawData[6]);
        
        state = [[ASPIOState alloc] initWithDate:time PIOState:PIOData];
    }
    else if (self.length == 1) {
        NSNumber *PIOData = @(rawData[0]);
        state = [[ASPIOState alloc] initWithDate:[[NSDate date] as_roundMillisecondsToThousands] PIOState:PIOData];
    }
    else {
        NSError *error = [NSError errorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorUnknown userInfo:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:self error:error];
    }
    
    return [[ASBLEResult alloc] initWithValue:state data:self error:nil];

}

- (ASBLEResult<ASAIOMeasurement *> *)as_AIOMeasurement {
    unsigned char *rawData = (unsigned char *) self.bytes;
    
    uint16_t a0 = 0, a1 = 0, a2 = 0;
    
    a0 = (rawData[1] << 8) + rawData[0];
    a1 = (rawData[3] << 8) + rawData[2];
    a2 = (rawData[5] << 8) + rawData[4];
    
    NSArray *AIOData = @[@(a0), @(a1), @(a2)];
    NSDate *now = [[NSDate date] as_roundMillisecondsToThousands];
    
    ASAIOMeasurement *measurement = [[ASAIOMeasurement alloc] initWithDate:now AIOVoltages:AIOData];
    
    return [[ASBLEResult alloc] initWithValue:measurement data:self error:nil];
}

- (ASBLEResult<ASErrorState *> *)as_errorState {
    unsigned char *rawData = (unsigned char *) self.bytes;

    NSDate *now = [[NSDate date] as_roundMillisecondsToThousands];
    NSNumber *state = @(rawData[0]);
    
    ASErrorState *errorState = [[ASErrorState alloc] initWithDate:now errorState:state];
    return [[ASBLEResult alloc] initWithValue:errorState data:self error:nil];
}

- (ASBLEResult<NSNumber *> *)as_accelerometerMode {
    NSNumber *mode = @(((unsigned char *) self.bytes)[0]);
    return [[ASBLEResult alloc] initWithValue:mode data:self error:nil];
}

- (ASBLEResult<NSNumber *> *)as_accelerometerThreshold {
    NSNumber *threshold = @(((float) ((unsigned char *) self.bytes)[0]) * 0.0625);
    return [[ASBLEResult alloc] initWithValue:threshold data:self error:nil];
}

- (ASBLEResult<NSString *> *)as_UTF8String {
    NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    return [[ASBLEResult alloc] initWithValue:string data:self error:nil];
}

- (ASBLEResult<NSString *> *)as_serialNumber {
    unsigned char * rawData = (unsigned char *) self.bytes;
    
    NSString *serialNumber;
    serialNumber = [NSString stringWithFormat:@"%02x", rawData[3]];
    serialNumber = [serialNumber stringByAppendingString:[NSString stringWithFormat:@"%02x", rawData[2]]];
    serialNumber = [serialNumber stringByAppendingString:[NSString stringWithFormat:@"%02x", rawData[1]]];
    serialNumber = [serialNumber stringByAppendingString:[NSString stringWithFormat:@"%02x", rawData[0]]];
    
    static NSDictionary *fixSerials;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fixSerials = @{@"00000014":@"00001410", // Greg Baker's
                       @"00000080":@"00008010", // Sophie London's
                       @"00000081":@"00008110", // Michael Gordon's
                       @"00000082":@"00008210", // Michael Gordon's
                       @"00000083":@"00008310", // Greg Baker's
                       @"00000084":@"00008410", // Greg Baker's
                       @"00000085":@"00008510", // Greg Baker's
                       @"00000088":@"00008810", // Jono Gray's
                       @"00000090":@"00009010", // Dave Hosler's
                       @"00000091":@"00009110", // Dave Hosler's
                       @"00000092":@"00009210", // Dave Hosler's
                       @"00000093":@"00009310", // Dave Hosler's
                       @"00000094":@"00009410", // Dave Hosler's
                       @"00000095":@"00009510", // Dave Hosler's
                       @"00000096":@"00009610", // Dave Hosler's
                       @"00000097":@"00009710", // Dave Hosler's
                       @"00000098":@"00009810", // Dave Hosler's
                       @"00000099":@"00009910", // Dave Hosler's
                       @"0000009a":@"00009a10", // Dave Hosler's
                       @"0000009b":@"00009b10", // Dave Hosler's
                       @"0000009c":@"00009c10"}; // Dave Hosler's
    });
    
    if (fixSerials[serialNumber]) {
        serialNumber = fixSerials[serialNumber];
    }
    
    return [[ASBLEResult alloc] initWithValue:serialNumber data:self error:nil];
}

- (ASBLEResult<NSArray<ASBLEResult<ASEnvironmentalMeasurement *> *> *> *)as_environmentalMeasurementBufferWithFirmwareVersion:(NSString *)version {
    NSParameterAssert(version);
    
    const unsigned int packetLength = 10;
    
    if ((self.length % packetLength) != 0) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorBufferSizeInvalid underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:self error:error];
    }
    
    NSMutableArray<ASBLEResult<ASEnvironmentalMeasurement *> *> *measurementResults = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (self.length / packetLength); i++) {
        NSData *packet = [self subdataWithRange:NSMakeRange(packetLength * i, packetLength)];
        
        ASBLEResult<ASEnvironmentalMeasurement *> *result = [packet as_environmentalMeasurementWithFirmwareVersion:version];
        
        [measurementResults addObject:result];
    }
    
    return [[ASBLEResult alloc] initWithValue:[NSArray arrayWithArray:measurementResults] data:self error:nil];
}

- (ASBLEResult<NSArray<ASBLEResult<ASImpact *> *> *> *)as_impactBufferWithFirmwareVersion:(NSString *)version {
    NSParameterAssert(version);
    
    const unsigned int packetLength = 12;
    
    if ((self.length % packetLength) != 0) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorBufferSizeInvalid underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:self error:error];
    }
    
    NSMutableArray<ASBLEResult<ASImpact *> *> *impacts = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (self.length / packetLength); i++) {
        NSData *packet = [self subdataWithRange:NSMakeRange(packetLength * i, packetLength)];
        
        ASBLEResult<ASImpact *> *impact = [packet as_impactWithFirmwareVersion:version];
        [impacts addObject:impact];
    }
    
    return [[ASBLEResult alloc] initWithValue:[NSArray arrayWithArray:impacts] data:self error:nil];
}

- (ASBLEResult<NSArray<ASActivityState *> *> *)as_activityBufferWithFirmwareVersion:(NSString *)version {
    NSParameterAssert(version);
    
    const unsigned int packetLength = 7;
    
    if ((self.length % packetLength) != 0) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorBufferSizeInvalid underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:self error:error];
    }
    
    NSMutableArray<ASBLEResult<ASActivityState *> *> *states = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (self.length / packetLength); i++) {
        NSData *packet = [self subdataWithRange:NSMakeRange(packetLength * i, packetLength)];
        
        ASBLEResult<ASActivityState *> *state = [packet as_activityStateWithFirmwareVersion:version];
        [states addObject:state];
    }
    
    return [[ASBLEResult alloc] initWithValue:[NSArray arrayWithArray:states] data:self error:nil];
}

- (ASBLEResult<NSArray<ASPIOState *> *> *)as_PIOBufferWithFirmwareVersion:(NSString *)version {
    NSParameterAssert(version);
    
    const unsigned int packetLength = 7;
    
    if ((self.length % packetLength) != 0) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorBufferSizeInvalid underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:self error:error];
    }
    
    NSMutableArray<ASBLEResult<ASPIOState *> *> *states = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (self.length / packetLength); i++) {
        NSData *packet = [self subdataWithRange:NSMakeRange(packetLength * i, packetLength)];
        
        ASBLEResult<ASPIOState *> *state = [packet as_PIOStateWithFirmwareVersion:version];
        
        [states addObject:state];
    }
    
    return [[ASBLEResult alloc] initWithValue:[NSArray arrayWithArray:states] data:self error:nil];
}

- (ASBLEResult<NSNumber *> *)as_bufferSize {
    unsigned char *rawData = (unsigned char *) self.bytes;
    
    uint16_t size = 0;
    for (int i = 3; i >= 0; i--) {
        size = size << 8;
        size |= (unsigned char) rawData[i];
    }
    
    return [[ASBLEResult alloc] initWithValue:@(size) data:self error:nil];
}

- (ASBLEResult<NSData *> *)as_registrationData {
    return [[ASBLEResult alloc] initWithValue:self data:self error:nil];
}

- (ASBLEResult<NSNumber *> *)as_OTAUVersion {
    unsigned char *rawData = (unsigned char *) self.bytes;
    NSNumber *version = @(rawData[0]);
    
    return [[ASBLEResult alloc] initWithValue:version data:self error:nil];
}

- (ASBLEResult<NSData *> *)as_OTAUDataTransfer {
    return [[ASBLEResult alloc] initWithValue:self data:self error:nil];
}

- (ASBLEResult<NSNumber *> *)as_OTAUTransferControl {
    unsigned char *rawData = (unsigned char *) self.bytes;
    NSNumber *state = @(rawData[0]);
    
    return [[ASBLEResult alloc] initWithValue:state data:self error:nil];
}

#pragma Private Methods

- (NSDate *)getTimeLegacy:(NSData *)data {
    unsigned char *timeArray = (unsigned char *) data.bytes;
    
    unsigned long long time_us = 0;
    
    for (int i = 5; i >= 0; i--) {
        time_us = time_us << 8;
        time_us |= (unsigned char) timeArray[i];
    }
    
    NSTimeInterval interval = ((NSTimeInterval) time_us) / 1e6;
    
    return [[NSDate dateWithTimeIntervalSinceNow:-interval] as_roundMillisecondsToThousands];
}

- (NSDate *)getTime:(NSData *)data {
    unsigned char *timeArray = (unsigned char *) data.bytes;
    
    unsigned long long time_us = 0;
    
    for (int i = 5; i >= 0; i--) {
        time_us = time_us << 8;
        time_us |= (unsigned char) timeArray[i];
    }
    
    NSTimeInterval interval = ((NSTimeInterval) time_us) * 1024.0 / 1000.0 / 1000.0;
    
    return [[NSDate dateWithTimeIntervalSince1970:(interval)] as_roundMillisecondsToThousands];
}

- (NSError *)invalidTimeError:(NSDate *)time {
    NSTimeInterval timeIntervalRelativeToNow = [time timeIntervalSinceNow];
    NSTimeInterval intervalOfDay = 24 * 60 * 60;
    NSTimeInterval intervalOfYear = intervalOfDay * 365;
    
    if (timeIntervalRelativeToNow > intervalOfDay) {
        return [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorDateWentForwardInTime underlyingError:nil];
    }
    
    if (timeIntervalRelativeToNow < -intervalOfYear) {
        return [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorDateWentBackInTime underlyingError:nil];
    }
    
    return nil;
}

@end
