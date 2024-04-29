//
//  ASServiceV1.m
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASServiceV1.h"

#import "ASBLEDefinitions.h"
#import "ASDevice.h"
#import "ASEnvironmentalDataCharacteristic.h"
#import "ASEnvironmentalDataCharacteristic.h"
#import "ASEnvironmentalMeasurementIntervalCharacteristic.h"
#import "ASEnvironmentalAlertIntervalCharacteristic.h"
#import "ASEnvironmentalAlarmLimitsCharacteristic.h"
#import "ASEnvironmentalRealtimeModeCharacteristic.h"
#import "ASImpactDataCharacteristic.h"
#import "ASActivityDataCharacteristic.h"
#import "ASAccelerometerModeCharacteristic.h"
#import "ASImpactThresholdCharacteristic.h"
#import "ASErrorStateCharacteristic.h"
#import "ASPIOCharacteristic.h"
#import "ASAIOCharacteristic.h"
#import "ASBlinkCharacteristic.h"
#import "ASRegistrationCharacteristic.h"
#import "ASTimeSyncCharacteristic.h"

@implementation ASServiceV1

+ (NSString *)identifier {
    return ASServiceUUID;
}

- (ASEnvironmentalDataCharacteristic *)environmentalDataCharacteristic {
    return (ASEnvironmentalDataCharacteristic *)self.characteristics[[ASEnvironmentalDataCharacteristic identifier].lowercaseString];
}

- (ASEnvironmentalMeasurementIntervalCharacteristic *)environmentalMeasurementIntervalCharacteristic {
    return (ASEnvironmentalMeasurementIntervalCharacteristic *)self.characteristics[[ASEnvironmentalMeasurementIntervalCharacteristic identifier].lowercaseString];;
}

- (ASEnvironmentalAlertIntervalCharacteristic *)environmentalAlertIntervalCharacteristic {
    return (ASEnvironmentalAlertIntervalCharacteristic *)self.characteristics[[ASEnvironmentalAlertIntervalCharacteristic identifier].lowercaseString];;
}

- (ASEnvironmentalAlarmLimitsCharacteristic *)environmentalAlarmLimitsCharacteristic {
    return (ASEnvironmentalAlarmLimitsCharacteristic *)self.characteristics[[ASEnvironmentalAlarmLimitsCharacteristic identifier].lowercaseString];
}

- (ASEnvironmentalRealtimeModeCharacteristic *)environmentalRealtimeModeCharacteristic {
    return (ASEnvironmentalRealtimeModeCharacteristic *)self.characteristics[[ASEnvironmentalRealtimeModeCharacteristic identifier].lowercaseString];;
}

- (ASImpactDataCharacteristic *)impactDataCharacteristic {
    return (ASImpactDataCharacteristic *)self.characteristics[[ASImpactDataCharacteristic identifier].lowercaseString];;
}

- (ASActivityDataCharacteristic *)activityDataCharacteristic {
    return (ASActivityDataCharacteristic *)self.characteristics[[ASActivityDataCharacteristic identifier].lowercaseString];;
}

- (ASAccelerometerModeCharacteristic *)accelerometerModeCharacteristic {
    return (ASAccelerometerModeCharacteristic *)self.characteristics[[ASAccelerometerModeCharacteristic identifier].lowercaseString];;
}

- (ASImpactThresholdCharacteristic *)impactThresholdCharacteristic {
    return (ASImpactThresholdCharacteristic *)self.characteristics[[ASImpactThresholdCharacteristic identifier].lowercaseString];;
}

- (ASErrorStateCharacteristic *)errorStateCharacteristic {
    return (ASErrorStateCharacteristic *)self.characteristics[[ASErrorStateCharacteristic identifier].lowercaseString];;
}

- (ASPIOCharacteristic *)PIOCharacteristic {
    return (ASPIOCharacteristic *)self.characteristics[[ASPIOCharacteristic identifier].lowercaseString];;
}

- (ASAIOCharacteristic *)AIOCharacteristic {
    return (ASAIOCharacteristic *)self.characteristics[[ASAIOCharacteristic identifier].lowercaseString];;
}

- (ASBlinkCharacteristic *)blinkCharacteristic {
    return (ASBlinkCharacteristic *)self.characteristics[[ASBlinkCharacteristic identifier].lowercaseString];;
}

- (ASRegistrationCharacteristic *)registrationCharacteristic {
    return (ASRegistrationCharacteristic *)self.characteristics[[ASRegistrationCharacteristic identifier].lowercaseString];
}

- (ASTimeSyncCharacteristic *)timeSyncCharacteristic {
    return (ASTimeSyncCharacteristic *)self.characteristics[[ASTimeSyncCharacteristic identifier].lowercaseString];
}

@end
