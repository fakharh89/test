//
//  ASShippingOption.h
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASShippingOption : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *price;
@property (nonatomic, copy, readonly) NSString *serviceCode;
@property (nonatomic, copy, readonly) NSString *transitDays;
@property (nonatomic, copy, readonly) NSString *carrier;
@property (nonatomic, copy, readonly) NSString *vendor;
@property (nonatomic, copy, readonly) NSString *daysToShip; // Time for Boveda to ship

@end
