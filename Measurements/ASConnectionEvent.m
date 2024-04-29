//
//  ASConnectionEvent.m
//  AFNetworking
//
//  Created by Michael Gordon on 12/5/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASConnectionEventPrivate.h"

// Do not change these
NSString * const ASConnectionEventTypeUnknownValue = @"unknown";
NSString * const ASConnectionEventTypeConnectedValue = @"connected";
NSString * const ASConnectionEventTypeDisconnectedValue = @"disconnected";
NSString * const ASConnectionEventTypeProximityValue = @"proximal";

NSString * const ASConnectionEventReasonUnknownValue = @"unknown";
NSString * const ASConnectionEventReasonNormalValue = @"normal";
NSString * const ASConnectionEventReasonErrorValue = @"error";
NSString * const ASConnectionEventReasonOTAUStartingValue = @"otauStarting";
NSString * const ASConnectionEventReasonOTAUFinishingValue = @"otauFinishing";
NSString * const ASConnectionEventReasonOTAUErrorValue = @"otauError";
NSString * const ASConnectionEventReasonTransitioningInsideRegionValue = @"transitioningInsideRegion";
NSString * const ASConnectionEventReasonTransitioningOutsideRegionValue = @"transitioningOutsideRegion";
NSString * const ASConnectionEventReasonTransitioningUnknownRegionValue = @"transitioningUnknownRegion";
NSString * const ASConnectionEventReasonStartedInsideRegionValue = @"startedInsideRegion";
NSString * const ASConnectionEventReasonStartedOutsideRegionValue = @"startedOutsideRegion";
NSString * const ASConnectionEventReasonStartedUnknownRegionValue = @"startedUnknownRegion";

@implementation ASConnectionEvent

- (id)initWithDate:(NSDate *)date hubIdentifier:(NSString *)hubIdentifier type:(ASConnectionEventType)type reason:(ASConnectionEventReason)reason {
    return [self initWithDate:date ingestionDate:nil hubIdentifier:hubIdentifier type:type reason:reason];
}

- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate hubIdentifier:(NSString *)hubIdentifier type:(ASConnectionEventType)type reason:(ASConnectionEventReason)reason {
    self = [super initWithDate:date ingestionDate:ingestionDate];
    
    if (self) {
        _hubIdentifier = hubIdentifier;
        _type = type;
        _reason = reason;
    }
    
    return self;
}

#define kHubIdentifier @"hubIdentifier"
#define kType @"type"
#define kReason @"reason"

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _hubIdentifier = [aDecoder decodeObjectForKey:kHubIdentifier];
        _type = ((NSNumber *)[aDecoder decodeObjectForKey:kType]).unsignedLongValue;
        _reason = ((NSNumber *)[aDecoder decodeObjectForKey:kReason]).unsignedLongValue;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_hubIdentifier forKey:kHubIdentifier];
    [encoder encodeObject:@(_type) forKey:kType];
    [encoder encodeObject:@(_reason) forKey:kReason];
}

- (NSString *)description {
    NSString *typeString = [[self class] stringForType:self.type];
    NSString *reasonString = [[self class] stringForReason:self.reason];
    
    return [NSString stringWithFormat:@"%@, Hub Identifier: %@, type: %@, reason: %@", [super description], self.hubIdentifier, typeString, reasonString];
}

+ (NSString *)stringForType:(ASConnectionEventType)type {
    switch (type) {
        case ASConnectionEventTypeUnknown:
            return ASConnectionEventTypeUnknownValue;
        case ASConnectionEventTypeConnected:
            return ASConnectionEventTypeConnectedValue;
        case ASConnectionEventTypeDisconnected:
            return ASConnectionEventTypeDisconnectedValue;
        case ASConnectionEventTypeProximity:
            return ASConnectionEventTypeProximityValue;
    }
}

+ (NSString *)stringForReason:(ASConnectionEventReason)reason {
    switch (reason) {
        case ASConnectionEventReasonUnknown:
            return ASConnectionEventReasonUnknownValue;
        case ASConnectionEventReasonNormal:
            return ASConnectionEventReasonNormalValue;
        case ASConnectionEventReasonError:
            return ASConnectionEventReasonErrorValue;
        case ASConnectionEventReasonOTAUStarting:
            return ASConnectionEventReasonOTAUStartingValue;
        case ASConnectionEventReasonOTAUFinishing:
            return ASConnectionEventReasonOTAUFinishingValue;
        case ASConnectionEventReasonOTAUError:
            return ASConnectionEventReasonOTAUErrorValue;
        case ASConnectionEventReasonTransitioningInsideRegion:
            return ASConnectionEventReasonTransitioningInsideRegionValue;
        case ASConnectionEventReasonTransitioningOutsideRegion:
            return ASConnectionEventReasonTransitioningOutsideRegionValue;
        case ASConnectionEventReasonTransitioningUnknownRegion:
            return ASConnectionEventReasonTransitioningUnknownRegionValue;
        case ASConnectionEventReasonStartedInsideRegion:
            return ASConnectionEventReasonStartedInsideRegionValue;
        case ASConnectionEventReasonStartedOutsideRegion:
            return ASConnectionEventReasonStartedOutsideRegionValue;
        case ASConnectionEventReasonStartedUnknownRegion:
            return ASConnectionEventReasonStartedUnknownRegionValue;
    }
    
    return ASConnectionEventReasonUnknownValue;
}

+ (ASConnectionEventType)typeForString:(NSString *)string {
    if ([ASConnectionEventTypeUnknownValue compare:string] == NSOrderedSame) {
        return ASConnectionEventTypeUnknown;
    }
    else if ([ASConnectionEventTypeDisconnectedValue compare:string] == NSOrderedSame) {
        return ASConnectionEventTypeDisconnected;
    }
    else if ([ASConnectionEventTypeConnectedValue compare:string] == NSOrderedSame) {
        return ASConnectionEventTypeConnected;
    }
    else if ([ASConnectionEventTypeProximityValue compare:string] == NSOrderedSame) {
        return ASConnectionEventTypeProximity;
    }
    
    return ASConnectionEventTypeUnknown;
}

+ (ASConnectionEventReason)reasonForString:(NSString *)string {
    if ([ASConnectionEventReasonUnknownValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonUnknown;
    }
    else if ([ASConnectionEventReasonNormalValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonNormal;
    }
    else if ([ASConnectionEventReasonErrorValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonError;
    }
    else if ([ASConnectionEventReasonOTAUStartingValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonOTAUStarting;
    }
    else if ([ASConnectionEventReasonOTAUFinishingValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonOTAUFinishing;
    }
    else if ([ASConnectionEventReasonOTAUErrorValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonOTAUError;
    }
    else if ([ASConnectionEventReasonTransitioningInsideRegionValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonTransitioningInsideRegion;
    }
    else if ([ASConnectionEventReasonTransitioningOutsideRegionValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonTransitioningOutsideRegion;
    }
    else if ([ASConnectionEventReasonTransitioningUnknownRegionValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonTransitioningUnknownRegion;
    }
    else if ([ASConnectionEventReasonStartedInsideRegionValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonStartedInsideRegion;
    }
    else if ([ASConnectionEventReasonStartedOutsideRegionValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonStartedOutsideRegion;
    }
    else if ([ASConnectionEventReasonStartedUnknownRegionValue compare:string] == NSOrderedSame) {
        return ASConnectionEventReasonStartedUnknownRegion;
    }
    
    return ASConnectionEventReasonUnknown;
}

@end
