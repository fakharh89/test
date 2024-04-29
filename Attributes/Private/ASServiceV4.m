//
//  ASServiceV3.m
//  Pods
//
//  Created by Michael Gordon on 3/7/18.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASServiceV4.h"

#import "ASBLEDefinitions.h"
#import "ASDevice.h"

#import "ASTimeSyncCharacteristicV3.h"
#import "ASRegistrationCharacteristicV3.h"
#import "ASErrorStateCharacteristicV3.h"
#import "ASBlinkCharacteristicV3.h"
#import "ASEnvironmentalBufferCharacteristic.h"
#import "ASEnvironmentalBufferSizeCharacteristic.h"
#import "ASEnvironmentalMeasurementIntervalCharacteristicV3.h"
#import "ASAccelerometerModeCharacteristicV3.h"
#import "ASImpactBufferCharacteristic.h"
#import "ASImpactBufferSizeCharacteristic.h"
#import "ASImpactThresholdCharacteristicV3.h"
#import "ASActivityBufferCharacteristic.h"
#import "ASActivityBufferSizeCharacteristic.h"
#import "ASPIOBufferCharacteristic.h"
#import "ASPIOBufferSizeCharacteristic.h"
#import "ASAIOCharacteristicV3.h"
#import "ASBeaconModeCharacteristic.h"
#import "ASBLEParametersCharacteristic.h"
#import "ASBLEConnectionModeCharacteristic.h"

@implementation ASServiceV4

+ (NSString *)identifier {
    return ASServiceUUIDv4;
}

- (ASTimeSyncCharacteristicV3 *)timeSyncCharacteristic  {
    return (ASTimeSyncCharacteristicV3 *)self.characteristics[[ASTimeSyncCharacteristicV3 identifier].lowercaseString];
}

- (ASRegistrationCharacteristicV3 *)registrationCharacteristic  {
    return (ASRegistrationCharacteristicV3 *)self.characteristics[[ASRegistrationCharacteristicV3 identifier].lowercaseString];
}

- (ASErrorStateCharacteristicV3 *)errorStateCharacteristic  {
    return (ASErrorStateCharacteristicV3 *)self.characteristics[[ASErrorStateCharacteristicV3 identifier].lowercaseString];
}

- (ASBlinkCharacteristicV3 *)blinkCharacteristic  {
    return (ASBlinkCharacteristicV3 *)self.characteristics[[ASBlinkCharacteristicV3 identifier].lowercaseString];
}

- (ASEnvironmentalBufferCharacteristic *)environmentalBufferCharacteristic {
    return (ASEnvironmentalBufferCharacteristic *)self.characteristics[[ASEnvironmentalBufferCharacteristic identifier].lowercaseString];
}

- (ASEnvironmentalBufferSizeCharacteristic *)environmentalBufferSizeCharacteristic  {
    return (ASEnvironmentalBufferSizeCharacteristic *)self.characteristics[[ASEnvironmentalBufferSizeCharacteristic identifier].lowercaseString];
}

- (ASEnvironmentalMeasurementIntervalCharacteristicV3 *)environmentalMeasurementIntervalCharacteristic  {
    return (ASEnvironmentalMeasurementIntervalCharacteristicV3 *)self.characteristics[[ASEnvironmentalMeasurementIntervalCharacteristicV3 identifier].lowercaseString];
}

- (ASAccelerometerModeCharacteristicV3 *)accelerometerModeCharacteristic  {
    return (ASAccelerometerModeCharacteristicV3 *)self.characteristics[[ASAccelerometerModeCharacteristicV3 identifier].lowercaseString];
}

- (ASImpactBufferCharacteristic *)impactBufferCharacteristic  {
    return (ASImpactBufferCharacteristic *)self.characteristics[[ASImpactBufferCharacteristic identifier].lowercaseString];
}

- (ASImpactBufferSizeCharacteristic *)impactBufferSizeCharacteristic  {
    return (ASImpactBufferSizeCharacteristic *)self.characteristics[[ASImpactBufferSizeCharacteristic identifier].lowercaseString];
}

- (ASImpactThresholdCharacteristicV3 *)impactThresholdCharacteristic  {
    return (ASImpactThresholdCharacteristicV3 *)self.characteristics[[ASImpactThresholdCharacteristicV3 identifier].lowercaseString];
}

- (ASActivityBufferCharacteristic *)activityBufferCharacteristic  {
    return (ASActivityBufferCharacteristic *)self.characteristics[[ASActivityBufferCharacteristic identifier].lowercaseString];
}

- (ASActivityBufferSizeCharacteristic *)activityBufferSizeCharacteristic  {
    return (ASActivityBufferSizeCharacteristic *)self.characteristics[[ASActivityBufferSizeCharacteristic identifier].lowercaseString];
}

- (ASPIOBufferCharacteristic *)PIOBufferCharacteristic {
    return (ASPIOBufferCharacteristic *)self.characteristics[[ASPIOBufferCharacteristic identifier].lowercaseString];
}

- (ASPIOBufferSizeCharacteristic *)PIOBufferSizeCharacteristic {
    return (ASPIOBufferSizeCharacteristic *)self.characteristics[[ASPIOBufferSizeCharacteristic identifier].lowercaseString];
}

- (ASAIOCharacteristicV3 *)AIOCharacteristic {
    return (ASAIOCharacteristicV3 *)self.characteristics[[ASAIOCharacteristicV3 identifier].lowercaseString];
}

- (ASBeaconModeCharacteristic *)beaconModeCharacteristic {
    return (ASBeaconModeCharacteristic *)self.characteristics[[ASBeaconModeCharacteristic identifier].lowercaseString];
}

- (ASBLEParametersCharacteristic *)BLEParametersCharacteristic {
    return (ASBLEParametersCharacteristic *)self.characteristics[[ASBLEParametersCharacteristic identifier].lowercaseString];
}

- (ASBLEConnectionModeCharacteristic *)BLEConnectionModeCharacteristic {
    return (ASBLEConnectionModeCharacteristic *)self.characteristics[[ASBLEConnectionModeCharacteristic identifier].lowercaseString];
}

@end
