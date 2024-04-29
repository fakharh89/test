//
//  ASConnectionEvent.h
//  AFNetworking
//
//  Created by Michael Gordon on 12/5/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASMeasurement.h"

// DO NOT CHANGE THESE
typedef NS_ENUM(NSUInteger, ASConnectionEventType) {
    ASConnectionEventTypeUnknown = 0,
    ASConnectionEventTypeConnected = 1,
    ASConnectionEventTypeDisconnected = 2,
    ASConnectionEventTypeProximity = 3
};

// DO NOT CHANGE THESE
typedef NS_ENUM(NSUInteger, ASConnectionEventReason) {
    ASConnectionEventReasonUnknown = 0,
    ASConnectionEventReasonNormal = 1,
    ASConnectionEventReasonError = 2,
    ASConnectionEventReasonOTAUStarting = 3,
    ASConnectionEventReasonOTAUFinishing = 4,
    ASConnectionEventReasonOTAUError = 5,
    ASConnectionEventReasonTransitioningInsideRegion = 6,
    ASConnectionEventReasonTransitioningOutsideRegion = 7,
    ASConnectionEventReasonTransitioningUnknownRegion = 8,
    ASConnectionEventReasonStartedInsideRegion = 9,
    ASConnectionEventReasonStartedOutsideRegion = 10,
    ASConnectionEventReasonStartedUnknownRegion = 11
};

@interface ASConnectionEvent : ASMeasurement <NSCoding>

@property (nonatomic, copy, readonly) NSString *hubIdentifier;
@property (nonatomic, assign, readonly) ASConnectionEventType type;
@property (nonatomic, assign, readonly) ASConnectionEventReason reason;

- (id)initWithDate:(NSDate *)date hubIdentifier:(NSString *)hubIdentifier type:(ASConnectionEventType)type reason:(ASConnectionEventReason)reason;
- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate hubIdentifier:(NSString *)hubIdentifier type:(ASConnectionEventType)type reason:(ASConnectionEventReason)reason;

+ (NSString *)stringForType:(ASConnectionEventType)type;
+ (NSString *)stringForReason:(ASConnectionEventReason)reason;

@end
