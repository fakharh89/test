//
//  ASBLEDefinitions.m
//  Blustream
//
//  Created by Michael Gordon on 12/10/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASBLEDefinitions.h"

// Acoustic Stream Services and Characteristics

NSString * const ASServiceUUID                                            = @"5a6b1c40-362f-11e5-afb5-0002a5d5c51b";

NSString * const ASEnvDataCharactUUID                                     = @"21a8aa20-3630-11e5-9c4c-0002a5d5c51b";
NSString * const ASEnvMeasIntervalCharactUUID                             = @"38e61100-3630-11e5-81cc-0002a5d5c51b";
NSString * const ASEnvAlertIntervalCharactUUID                            = @"3d1b5640-3630-11e5-9b71-0002a5d5c51b";
NSString * const ASEnvAlarmLimitsCharactUUID                              = @"42e37080-3630-11e5-b2c0-0002a5d5c51b";
NSString * const ASEnvRealtimeCharactUUID                                 = @"466ac280-3630-11e5-8e99-0002a5d5c51b";

NSString * const ASAccDataCharactUUID                                     = @"4b8e1140-3630-11e5-9012-0002a5d5c51b";
NSString * const ASAccActivityCharactUUID                                 = @"4fcaf7a0-3630-11e5-974a-0002a5d5c51b";
NSString * const ASAccEnableCharactUUID                                   = @"543bbf40-3630-11e5-9f31-0002a5d5c51b";
NSString * const ASAccSelfTestCharactUUID                                 = @"800a";
NSString * const ASAccCalParamsCharactUUID                                = @"800b";
NSString * const ASAccThresholdCharactUUID                                = @"57be7d60-3630-11e5-a315-0002a5d5c51b";

NSString * const ASErrorCharactUUID                                       = @"5d468160-3630-11e5-9b4a-0002a5d5c51b";
NSString * const ASPIOCharactUUID                                         = @"616afdc0-3630-11e5-b95c-0002a5d5c51b";
NSString * const ASAIOCharactUUID                                         = @"663d6d60-3630-11e5-a427-0002a5d5c51b";
NSString * const ASBlinkCharactUUID                                       = @"69cad9e0-3630-11e5-b752-0002a5d5c51b";
NSString * const ASRegistrationCharactUUID                                = @"6e01a5c0-3630-11e5-97c0-0002a5d5c51b";
NSString * const ASTimeSyncCharactUUID                                    = @"00e73036-d41e-11e5-ab30-625662870761";

NSString * const ASServiceUUIDv3                                          = @"c6edd504-3e96-11e6-ac61-9e71128cae77";
NSString * const ASTimeSyncCharacteristicUUIDv3                           = @"480821a6-3ead-11e6-ac61-9e71128cae77";
NSString * const ASRegistrationCharacteristicUUIDv3                       = @"5030c5a0-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASErrorStateCharacteristicUUIDv3                         = @"5030c190-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASBlinkCharacteristicUUIDv3                              = @"5030c4d8-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASEnvironmentalMeasurementBufferCharacteristicUUIDv3     = @"5030b0ba-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASEnvironmentalMeasurementBufferSizeCharacteristicUUIDv3 = @"5030b45c-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASEnvironmentalMeasurementIntervalCharacteristicUUIDv3   = @"5030b5b0-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASAccelerometerModeCharacteristicUUIDv3                  = @"5030bcfe-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASImpactBufferCharacteristicUUIDv3                       = @"5030b98e-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASImpactBufferSizeCharacteristicUUIDv3                   = @"5030ba88-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASImpactThresholdCharacteristicUUIDv3                    = @"5030bdd0-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASActivityBufferCharacteristicUUIDv3                     = @"5030bb5a-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASActivityBufferSizeCharacteristicUUIDv3                 = @"5030bc2c-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASPIOBufferCharacteristicUUIDv3                          = @"5030c26c-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASPIOBufferSizeCharacteristicUUIDv3                      = @"5030c348-3e9d-11e6-ac61-9e71128cae77";
NSString * const ASAIOCharacteristicUUIDv3                                = @"5030c410-3e9d-11e6-ac61-9e71128cae77";

// V4 uses many of the same characteristic uuids as v3 for it's uuids
// Do not duplicate UUIDs, else uniqueness will be broken for identification
NSString * const ASServiceUUIDv4                                          = @"02935d36-fc5b-11e6-bc64-92361f002671";

NSString * const ASBeaconModeUUID                                         = @"6a3010f4-2592-11e8-b467-0ed5f89f718b";
NSString * const ASBLEParametersUUID                                      = @"622cc956-25a1-11e8-b467-0ed5f89f718b";
NSString * const ASBLEConnectionModeUUID                                  = @"53ecb85e-25ad-11e8-b467-0ed5f89f718b";

// Standard Services and Characteristics
NSString * const ASBatteryServiceUUID          = @"180f";
NSString * const ASBatteryCharactUUID          = @"2a19";

// Device Information Service
NSString * const ASDevInfoServiceUUID          = @"180a";
NSString * const ASManNameCharactUUID          = @"2a29";
NSString * const ASModelNoCharactUUID          = @"2a24";
NSString * const ASSerialNoCharactUUID         = @"2a25";
NSString * const ASHardwareRevCharactUUID      = @"2a27";
NSString * const ASFirmwareRevCharactUUID      = @"2a26";
NSString * const ASSoftwareRevCharactUUID      = @"2a28";
NSString * const ASSystemIDCharactUUID         = @"2a23";

// CSR OTAU Service
NSString * const ASOTAUBootServiceUUID             = @"00001010-d102-11e1-9b23-00025b00a5a5";
NSString * const ASOTAUControlTransferCharacteristicUUID = @"00001015-d102-11e1-9b23-00025b00a5a5";

NSString * const ASOTAUApplicationServiceUUID = @"00001016-d102-11e1-9b23-00025b00a5a5";
NSString * const ASOTAUKeyCharacteristicUUID = @"00001017-d102-11e1-9b23-00025b00a5a5";
NSString * const ASOTAUCurrentAppCharacteristicUUID = @"00001013-d102-11e1-9b23-00025b00a5a5";
NSString * const ASOTAUKeyBlockCharacteristicUUID = @"00001018-d102-11e1-9b23-00025b00a5a5";
NSString * const ASOTAUDataTransferCharacteristicUUID = @"00001014-d102-11e1-9b23-00025b00a5a5";
NSString * const ASOTAUVersionCharacteristicUUID   = @"00001011-d102-11e1-9b23-00025b00a5a5";

@implementation ASBLECharacteristicHelper

+ (NSString *)characteristicNameFromIdentifier:(NSString *)identifier {
    NSString *lowercaseIdentifier = identifier.lowercaseString;
    
    if ([lowercaseIdentifier isEqualToString:ASServiceUUID]) {
        return @"ASServiceUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASEnvDataCharactUUID]) {
        return @"ASEnvDataCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASEnvMeasIntervalCharactUUID]) {
        return @"ASEnvMeasIntervalCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASEnvAlertIntervalCharactUUID]) {
        return @"ASEnvAlertIntervalCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASEnvAlarmLimitsCharactUUID]) {
        return @"ASEnvAlarmLimitsCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASEnvRealtimeCharactUUID]) {
        return @"ASEnvRealtimeCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASAccDataCharactUUID]) {
        return @"ASAccDataCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASAccActivityCharactUUID]) {
        return @"ASAccActivityCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASAccEnableCharactUUID]) {
        return @"ASAccEnableCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASAccSelfTestCharactUUID]) {
        return @"ASAccSelfTestCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASAccCalParamsCharactUUID]) {
        return @"ASAccCalParamsCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASAccCalParamsCharactUUID]) {
        return @"ASAccCalParamsCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASAccThresholdCharactUUID]) {
        return @"ASAccThresholdCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASErrorCharactUUID]) {
        return @"ASErrorCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASPIOCharactUUID]) {
        return @"ASPIOCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASAIOCharactUUID]) {
        return @"ASAIOCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASBlinkCharactUUID]) {
        return @"ASBlinkCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASRegistrationCharactUUID]) {
        return @"ASRegistrationCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASTimeSyncCharactUUID]) {
        return @"ASTimeSyncCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASServiceUUIDv3]) {
        return @"ASServiceUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASTimeSyncCharacteristicUUIDv3]) {
        return @"ASTimeSyncCharacteristicUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASRegistrationCharacteristicUUIDv3]) {
        return @"ASRegistrationCharacteristicUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASErrorStateCharacteristicUUIDv3]) {
        return @"ASErrorStateCharacteristicUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASBlinkCharacteristicUUIDv3]) {
        return @"ASBlinkCharacteristicUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASEnvironmentalMeasurementBufferCharacteristicUUIDv3]) {
        return @"ASEnvironmentalMeasurementBufferCharacteristicUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASEnvironmentalMeasurementBufferSizeCharacteristicUUIDv3]) {
        return @"ASEnvironmentalMeasurementBufferSizeCharacteristicUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASEnvironmentalMeasurementIntervalCharacteristicUUIDv3]) {
        return @"ASEnvironmentalMeasurementIntervalCharacteristicUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASAccelerometerModeCharacteristicUUIDv3]) {
        return @"ASAccelerometerModeCharacteristicUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASImpactBufferCharacteristicUUIDv3]) {
        return @"ASImpactBufferCharacteristicUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASImpactBufferSizeCharacteristicUUIDv3]) {
        return @"ASImpactBufferSizeCharacteristicUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASImpactThresholdCharacteristicUUIDv3]) {
        return @"ASImpactThresholdCharacteristicUUIDv3";
    }

    if ([lowercaseIdentifier isEqualToString:ASActivityBufferCharacteristicUUIDv3]) {
        return @"ASActivityBufferCharacteristicUUIDv3";
    }

    if ([lowercaseIdentifier isEqualToString:ASActivityBufferSizeCharacteristicUUIDv3]) {
        return @"ASActivityBufferSizeCharacteristicUUIDv3";
    }

    if ([lowercaseIdentifier isEqualToString:ASPIOBufferCharacteristicUUIDv3]) {
        return @"ASPIOBufferCharacteristicUUIDv3";
    }

    if ([lowercaseIdentifier isEqualToString:ASPIOBufferSizeCharacteristicUUIDv3]) {
        return @"ASPIOBufferSizeCharacteristicUUIDv3";
    }

    if ([lowercaseIdentifier isEqualToString:ASAIOCharacteristicUUIDv3]) {
        return @"ASAIOCharacteristicUUIDv3";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASServiceUUIDv4]) {
        return @"ASServiceUUIDv4";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASBeaconModeUUID]) {
        return @"ASBeaconModeUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASBLEParametersUUID]) {
        return @"ASBLEParametersUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASBLEConnectionModeUUID]) {
        return @"ASBLEConnectionModeUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASBatteryServiceUUID]) {
        return @"ASBatteryServiceUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASBatteryCharactUUID]) {
        return @"ASBatteryCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASDevInfoServiceUUID]) {
        return @"ASDevInfoServiceUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASManNameCharactUUID]) {
        return @"ASManNameCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASModelNoCharactUUID]) {
        return @"ASModelNoCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASSerialNoCharactUUID]) {
        return @"ASSerialNoCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASHardwareRevCharactUUID]) {
        return @"ASHardwareRevCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASFirmwareRevCharactUUID]) {
        return @"ASFirmwareRevCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASSoftwareRevCharactUUID]) {
        return @"ASSoftwareRevCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASSystemIDCharactUUID]) {
        return @"ASSystemIDCharactUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASOTAUBootServiceUUID]) {
        return @"ASOTAUBootServiceUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASOTAUControlTransferCharacteristicUUID]) {
        return @"ASOTAUControlTransferCharacteristicUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASOTAUApplicationServiceUUID]) {
        return @"ASOTAUApplicationServiceUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASOTAUKeyCharacteristicUUID]) {
        return @"ASOTAUKeyCharacteristicUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASOTAUCurrentAppCharacteristicUUID]) {
        return @"ASOTAUCurrentAppCharacteristicUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASOTAUKeyBlockCharacteristicUUID]) {
        return @"ASOTAUKeyBlockCharacteristicUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASOTAUDataTransferCharacteristicUUID]) {
        return @"ASOTAUDataTransferCharacteristicUUID";
    }
    
    if ([lowercaseIdentifier isEqualToString:ASOTAUVersionCharacteristicUUID]) {
        return @"ASOTAUVersionCharacteristicUUID";
    }
    
    return @"Unknown";
}

@end



