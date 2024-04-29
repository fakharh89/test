//
//  ASServiceV1.h
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

#import "ASAttribute.h"
#import "ASService.h"

@class ASEnvironmentalDataCharacteristic;
@class ASEnvironmentalMeasurementIntervalCharacteristic;
@class ASEnvironmentalAlertIntervalCharacteristic;
@class ASEnvironmentalAlarmLimitsCharacteristic;
@class ASEnvironmentalRealtimeModeCharacteristic;
@class ASImpactDataCharacteristic;
@class ASActivityDataCharacteristic;
@class ASAccelerometerModeCharacteristic;
@class ASImpactThresholdCharacteristic;
@class ASErrorStateCharacteristic;
@class ASPIOCharacteristic;
@class ASAIOCharacteristic;
@class ASBlinkCharacteristic;
@class ASRegistrationCharacteristic;
@class ASTimeSyncCharacteristic;

@interface ASServiceV1 : ASService <ASService>

@property (strong, readwrite, nonatomic) ASEnvironmentalDataCharacteristic *environmentalDataCharacteristic;
@property (strong, readwrite, nonatomic) ASEnvironmentalMeasurementIntervalCharacteristic *environmentalMeasurementIntervalCharacteristic;
@property (strong, readwrite, nonatomic) ASEnvironmentalAlertIntervalCharacteristic *environmentalAlertIntervalCharacteristic;
@property (strong, readwrite, nonatomic) ASEnvironmentalAlarmLimitsCharacteristic *environmentalAlarmLimitsCharacteristic;
@property (strong, readwrite, nonatomic) ASEnvironmentalRealtimeModeCharacteristic *environmentalRealtimeModeCharacteristic;
@property (strong, readwrite, nonatomic) ASImpactDataCharacteristic *impactDataCharacteristic;
@property (strong, readwrite, nonatomic) ASActivityDataCharacteristic *activityDataCharacteristic;
@property (strong, readwrite, nonatomic) ASAccelerometerModeCharacteristic *accelerometerModeCharacteristic;
@property (strong, readwrite, nonatomic) ASImpactThresholdCharacteristic *impactThresholdCharacteristic;
@property (strong, readwrite, nonatomic) ASErrorStateCharacteristic *errorStateCharacteristic;
@property (strong, readwrite, nonatomic) ASPIOCharacteristic *PIOCharacteristic;
@property (strong, readwrite, nonatomic) ASAIOCharacteristic *AIOCharacteristic;
@property (strong, readwrite, nonatomic) ASBlinkCharacteristic *blinkCharacteristic;
@property (strong, readwrite, nonatomic) ASRegistrationCharacteristic *registrationCharacteristic;
@property (strong, readwrite, nonatomic) ASTimeSyncCharacteristic *timeSyncCharacteristic;

@end
