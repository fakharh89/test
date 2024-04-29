//
//  ASPIOState.m
//  Blustream
//
//  Created by Michael Gordon on 7/15/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASPIOState.h"

@implementation ASPIOState

- (id)initWithDate:(NSDate *)date PIOState:(NSNumber *)state {
    self = [super initWithDate:date];
    
    if (self) {
        _state = state;
//        if (state) {
//            uint8_t pinAll = state.charValue;
//            NSMutableArray<NSNumber *> *mutablePins = [[NSMutableArray alloc] init];
//            for (int i = 0; i < 8; i++) {
//                BOOL pinI = pinAll & (1 << i);
//                [mutablePins addObject:@(pinI)];
//            }
//            _pins = [NSArray arrayWithArray:mutablePins];
//        }
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
    return [NSString stringWithFormat:@"%@, PIO: 0x%02x", [super description], self.state.unsignedCharValue];
}

@end
