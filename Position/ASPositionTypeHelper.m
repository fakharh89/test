//
//  ASPositionTypeHelper.m
//  AS-iOS-Framework
//
//  Created by Michael Gordon on 5/3/21.
//  Copyright © 2021 Blustream Corporation. All rights reserved.
//

#import "ASPositionTypeHelper.h"

static NSString * const ASBaskingSitePositionId = @"basking";
static NSString * const ASCoolZonePositionId = @"coolzon";

@implementation ASPositionTypeHelper

+ (ASPositionType)positionTypeForExtId:(NSString *)extId {
    if ([ASCoolZonePositionId isEqualToString:extId]) {
        return ASPositionTypeCoolZone;
    }
    else if ([ASBaskingSitePositionId isEqualToString:extId]) {
        return ASPositionTypeBaskingSite;
    }
    else {
        return ASPositionTypeUnknown;
    }
}

+ (NSString *)extIdForPositionType:(ASPositionType)positionType {
    switch (positionType) {
        case ASPositionTypeBaskingSite:
            return ASBaskingSitePositionId;
        case ASPositionTypeCoolZone:
            return ASCoolZonePositionId;
        default:
            return nil;
    }
}

@end
