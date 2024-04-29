//
//  ASAdvertisementData.h
//  Blustream
//
//  Created by Michael Gordon on 7/18/16.
//
//

#import <Foundation/Foundation.h>

@class ASManufacturerData;

@interface ASAdvertisementData : NSObject

@property (strong, readwrite, nonatomic) ASManufacturerData *manufacturerData;

@end
