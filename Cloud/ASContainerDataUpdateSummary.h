//
//  ASContainerDataUpdateSummary.h
//  AFNetworking
//
//  Created by Michael Gordon on 3/8/19.
//  Copyright © 2019 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASContainerDataUpdateSummary : NSObject

@property (nonatomic, strong, readonly) NSString *containerIdentifier;

@property (nonatomic, strong, readonly) NSDate *latestActivityIngestionDate;
@property (nonatomic, strong, readonly) NSDate *latestBatteryIngestionDate;
@property (nonatomic, strong, readonly) NSDate *latestConnectionIngestionDate;
@property (nonatomic, strong, readonly) NSDate *latestEnvironmentalIngestionDate;
// NOTE: This is by regular date, not ingestion
@property (nonatomic, strong, readonly) NSDate *latestErrorDate;
@property (nonatomic, strong, readonly) NSDate *latestImpactIngestionDate;

@end
