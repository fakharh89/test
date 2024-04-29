//
//  ASManufacturerData.h
//  Blustream
//
//  Created by Michael Gordon on 7/18/16.
//
//

#import <Foundation/Foundation.h>

@class ASEnvironmentalMeasurement, ASErrorState, ASBatteryLevel;

@interface ASManufacturerData : NSObject

@property (strong, readwrite, nonatomic) NSString *serialNumber;
@property (strong, readwrite, nonatomic) ASEnvironmentalMeasurement *environmentalMeasurement;
@property (strong, readwrite, nonatomic) ASErrorState *errorState;
@property (strong, readwrite, nonatomic) ASBatteryLevel *batterylevel;

@end
