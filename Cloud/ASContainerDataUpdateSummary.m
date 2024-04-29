//
//  ASContainerDataUpdateSummary.m
//  AFNetworking
//
//  Created by Michael Gordon on 3/8/19.
//  Copyright © 2019 Blustream Corporation. All rights reserved.
//

#import "ASContainerDataUpdateSummaryPrivate.h"

@implementation ASContainerDataUpdateSummary

- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier {
    self = [super init];
    if (self) {
        _containerIdentifier = containerIdentifier;
    }
    return self;
}

- (BOOL)setDate:(NSDate *)date forDataTypeString:(NSString *)string {
    if (!string || string.length == 0) {
        return NO;
    }
    
    if ([string caseInsensitiveCompare:@"accelerometer"] == NSOrderedSame) {
        _latestImpactIngestionDate = date;
        return true;
    }
    else if ([string caseInsensitiveCompare:@"ambient"] == NSOrderedSame) {
        _latestEnvironmentalIngestionDate = date;
        return true;
    }
    else if ([string caseInsensitiveCompare:@"activity"] == NSOrderedSame) {
        _latestActivityIngestionDate = date;
        return true;
    }
    else if ([string caseInsensitiveCompare:@"battery"] == NSOrderedSame) {
        _latestBatteryIngestionDate = date;
        return true;
    }
    else if ([string caseInsensitiveCompare:@"connection"] == NSOrderedSame) {
        _latestConnectionIngestionDate = date;
        return true;
    }
    else if ([string caseInsensitiveCompare:@"error"] == NSOrderedSame) {
        _latestErrorDate = date;
        return true;
    }
    
    return false;
}

@end
