//
//  ASShippingOption.m
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASShippingOptionPrivate.h"

NSString * const ASShippingOptionName = @"name";
NSString * const ASShippingOptionPrice = @"price";
NSString * const ASShippingOptionServiceCode = @"serviceCode";
NSString * const ASShippingOptionTransitDays = @"transitDays";
NSString * const ASShippingOptionCarrier = @"carrier";
NSString * const ASShippingOptionVendor = @"vendorId";
NSString * const ASShippingOptionDaysToShip = @"daysToShip";

@implementation ASShippingOption

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _name = dictionary[ASShippingOptionName];
        _price = dictionary[ASShippingOptionPrice];
        _serviceCode = dictionary[ASShippingOptionServiceCode];
        _transitDays = dictionary[ASShippingOptionTransitDays];
        _carrier = dictionary[ASShippingOptionCarrier];
        _vendor = dictionary[ASShippingOptionVendor];
        _daysToShip = dictionary[ASShippingOptionDaysToShip];
    }
    
    return self;
}

- (NSDictionary *)dictionaryWithError:(NSError *__autoreleasing *)error {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[ASShippingOptionName] = self.name;
    dictionary[ASShippingOptionPrice] = self.price;
    dictionary[ASShippingOptionServiceCode] = self.serviceCode;
    dictionary[ASShippingOptionTransitDays] = self.transitDays;
    dictionary[ASShippingOptionCarrier] = self.carrier;
    dictionary[ASShippingOptionVendor] = self.vendor;
    dictionary[ASShippingOptionDaysToShip] = self.daysToShip;
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end
