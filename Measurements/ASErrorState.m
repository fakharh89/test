//
//  ASErrorState.m
//  Blustream
//
//  Created by Michael Gordon on 7/15/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASErrorState.h"

@implementation ASErrorState

- (id)initWithDate:(NSDate *)date errorState:(NSNumber *)state {
    return [self initWithDate:date ingestionDate:nil errorState:state];
}

- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate errorState:(NSNumber *)state {
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
    return [NSString stringWithFormat:@"%@, State: 0x%02x", [super description], self.state.unsignedCharValue];
}

@end
