//
//  NSString+Compatibility.m
//  Blustream
//
//  Created by Michael Gordon on 4/4/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "NSString+ASCompatibility.h"

#import "ASConfig.h"
#import "ASSystemManager.h"

@implementation NSString (ASCompatibility)

- (BOOL)as_serialNumberIsCompatible {
    NSString *serialNumberType = [self substringFromIndex:[self length] - 2];
    ASDeviceAvailability deviceAvailability = ASSystemManager.shared.config.deviceAvailability;
    
    if ([serialNumberType caseInsensitiveCompare:@"10"] == NSOrderedSame) {
        if (deviceAvailability & ASDeviceAvailabilityTaylor) {
            return YES;
        }
    }
    
    if ([serialNumberType caseInsensitiveCompare:@"01"] == NSOrderedSame) {
        if (deviceAvailability & ASDeviceAvailabilityDAddario) {
            return YES;
        }
    }
    
    if ([serialNumberType caseInsensitiveCompare:@"02"] == NSOrderedSame) {
        if (deviceAvailability & ASDeviceAvailabilityTKL) {
            return YES;
        }
    }
    
    if ([serialNumberType caseInsensitiveCompare:@"42"] == NSOrderedSame) {
        if (deviceAvailability & ASDeviceAvailabilityBlustream) {
            return YES;
        }
    }
    
    if ([serialNumberType caseInsensitiveCompare:@"43"] == NSOrderedSame) {
        if (deviceAvailability & ASDeviceAvailabilityBoveda) {
            return YES;
        }
    }
    
    return NO;
}

@end
