//
//  ASServiceV3.h
//  Pods
//
//  Created by Michael Gordon on 12/6/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

#import "ASAttribute.h"
#import "ASService.h"

@class ASTimeSyncCharacteristicV3;
@class ASRegistrationCharacteristicV3;
@class ASErrorStateCharacteristicV3;
@class ASBlinkCharacteristicV3;
@class ASEnvironmentalBufferCharacteristic;
@class ASEnvironmentalBufferSizeCharacteristic;
@class ASEnvironmentalMeasurementIntervalCharacteristicV3;
@class ASAccelerometerModeCharacteristicV3;
@class ASImpactBufferCharacteristic;
@class ASImpactBufferSizeCharacteristic;
@class ASImpactThresholdCharacteristicV3;
@class ASActivityBufferCharacteristic;
@class ASActivityBufferSizeCharacteristic;
@class ASPIOBufferCharacteristic;
@class ASPIOBufferSizeCharacteristic;
@class ASAIOCharacteristicV3;

@interface ASServiceV3 : ASService <ASService>

@property (strong, readwrite, nonatomic) ASTimeSyncCharacteristicV3 *timeSyncCharacteristic;
@property (strong, readwrite, nonatomic) ASRegistrationCharacteristicV3 *registrationCharacteristic;
@property (strong, readwrite, nonatomic) ASErrorStateCharacteristicV3 *errorStateCharacteristic;
@property (strong, readwrite, nonatomic) ASBlinkCharacteristicV3 *blinkCharacteristic;
@property (strong, readwrite, nonatomic) ASEnvironmentalBufferCharacteristic *environmentalBufferCharacteristic;
@property (strong, readwrite, nonatomic) ASEnvironmentalBufferSizeCharacteristic *environmentalBufferSizeCharacteristic;
@property (strong, readwrite, nonatomic) ASEnvironmentalMeasurementIntervalCharacteristicV3 *environmentalMeasurementIntervalCharacteristic;
@property (strong, readwrite, nonatomic) ASAccelerometerModeCharacteristicV3 *accelerometerModeCharacteristic;
@property (strong, readwrite, nonatomic) ASImpactBufferCharacteristic *impactBufferCharacteristic;
@property (strong, readwrite, nonatomic) ASImpactBufferSizeCharacteristic *impactBufferSizeCharacteristic;
@property (strong, readwrite, nonatomic) ASImpactThresholdCharacteristicV3 *impactThresholdCharacteristic;
@property (strong, readwrite, nonatomic) ASActivityBufferCharacteristic *activityBufferCharacteristic;
@property (strong, readwrite, nonatomic) ASActivityBufferSizeCharacteristic *activityBufferSizeCharacteristic;
@property (strong, readwrite, nonatomic) ASPIOBufferCharacteristic *PIOBufferCharacteristic;
@property (strong, readwrite, nonatomic) ASPIOBufferSizeCharacteristic *PIOBufferSizeCharacteristic;
@property (strong, readwrite, nonatomic) ASAIOCharacteristicV3 *AIOCharacteristic;

@end
