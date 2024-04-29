//
//  ASBLEResult.m
//  Pods
//
//  Created by Michael Gordon on 12/5/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASBLEResult.h"

@implementation ASBLEResult

- (BOOL)successful {
    if (self.data && self.value && !self.error) {
        return YES;
    }
    else {
        return NO;
    }
}

- (instancetype)initWithValue:(id)value data:(NSData *)data error:(NSError *)error {
    self = [super init];
    if (self) {
        _value = value;
        _data = data;
        _error = error;
    }
    return self;
}

@end
