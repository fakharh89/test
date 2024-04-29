//
//  ASMeasurement.m
//  Blustream
//
//  Created by Michael Gordon on 5/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASMeasurementPrivate.h"

@implementation ASMeasurement

- (id)initWithDate:(NSDate *)date {
    return [self initWithDate:date ingestionDate:nil];
}

- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate {
    self = [super init];
    
    if (self) {
        _date = date;
        _syncStatus = ASSyncStatusUnsent;
        _ingestionDate = ingestionDate;
    }
    
    return self;
}

#define kDate          @"date"
#define kIngestionDate @"ingestionDate"
#define kSyncStatus    @"SyncStatus"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        _date = [decoder decodeObjectForKey:kDate];
        _syncStatus = ((NSNumber *) [decoder decodeObjectForKey:kSyncStatus]).unsignedCharValue;
        _ingestionDate = [decoder decodeObjectForKey:kIngestionDate];
        
        // Reset sync status on app relaunch
        if (_syncStatus == ASSyncStatusSending) {
            _syncStatus = ASSyncStatusUnsent;
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_date forKey:kDate];
    [encoder encodeObject:@(_syncStatus) forKey:kSyncStatus];
    [encoder encodeObject:_ingestionDate forKey:kIngestionDate];
}

// TODO Document hash, isEqual, and compare method overrides in public API

- (BOOL)isEqual:(id)object {
    return [self.date isEqualToDate:((ASMeasurement *)object).date];
}

- (NSUInteger)hash {
    return [self.date hash];
}

- (NSComparisonResult)compare:(ASMeasurement *)otherObject {
    return [self.date compare:otherObject.date];
}

- (NSString *)description {
    NSString *description = nil;
    
    if (self.ingestionDate) {
        description = [NSString stringWithFormat:@"Date: %@, Ingestion: %@", self.date, self.ingestionDate];
    }
    else {
        description = [NSString stringWithFormat:@"Date: %@", self.date];
    }
    
    return description;
}

@end
