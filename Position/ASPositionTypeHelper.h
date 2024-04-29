//
//  ASPositionTypeHelper.h
//  AS-iOS-Framework
//
//  Created by Michael Gordon on 5/3/21.
//  Copyright © 2021 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ASPositionType) {
    ASPositionTypeUnknown,
    ASPositionTypeBaskingSite,
    ASPositionTypeCoolZone
};

@interface ASPositionTypeHelper : NSObject

+ (ASPositionType)positionTypeForExtId:(NSString *)extId;
+ (NSString *)extIdForPositionType:(ASPositionType)positionType;

@end

