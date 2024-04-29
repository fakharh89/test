//
//  ASDevice+BLEUpdate.m
//  Blustream
//
//  Created by Michael Gordon on 2/16/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice+BLEUpdate.h"

#import "ASEnvironmentalMeasurement.h"
#import "ASBatteryLevel.h"
#import "ASErrorState.h"

#import "ASAdvertisementData.h"
#import "ASManufacturerData.h"

@implementation ASDevice (BLEUpdate)

#pragma mark Public Methods

- (void)updateFromAdvertisementData:(ASAdvertisementData *)advertisementData {
    self.advertisedEnvironmentalMeasurement = advertisementData.manufacturerData.environmentalMeasurement;
    self.advertisedBatteryLevel = advertisementData.manufacturerData.batterylevel;
    self.advertisedErrorState = advertisementData.manufacturerData.errorState;
}

@end
