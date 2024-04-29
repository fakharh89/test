//
//  ASActivityState.m
//  Blustream
//
//  Created by Michael Gordon on 7/15/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASActivityState.h"

@implementation ASActivityState

- (id)initWithDate:(NSDate *)date activityState:(NSNumber *)state {
    return [self initWithDate:date ingestionDate:nil activityState:state];
}

- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate activityState:(NSNumber *)state {
    self = [super initWithDate:date ingestionDate:ingestionDate];
    
    if (self) {
        _state = state;
    }
    
    return self;
}

#define kState @"State"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if (self) {
        _state = [decoder decodeObjectForKey:kState];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_state forKey:kState];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, State: %@", [super description], self.state.boolValue ? @"active" : @"inactive"];
}

@end
