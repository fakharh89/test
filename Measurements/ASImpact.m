//
//  ASImpact.m
//  Blustream
//
//  Created by Michael Gordon on 7/15/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASImpact.h"

@implementation ASImpact

- (id)initWithDate:(NSDate *)date x:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z {
    return [self initWithDate:date ingestionDate:nil x:x y:y z:z];
}

- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate x:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z {
    return [self initWithDate:date ingestionDate:ingestionDate x:x y:y z:z magnitude:@(sqrt(x.doubleValue * x.doubleValue
                                                                                  + y.doubleValue * y.doubleValue
                                                                                  + z.doubleValue * z.doubleValue))];
}

- (id)initWithDate:(NSDate *)date magnitude:(NSNumber *)magnitude {
    return [self initWithDate:date ingestionDate:nil x:nil y:nil z:nil magnitude:magnitude];
}

- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate magnitude:(NSNumber *)magnitude {
    return [self initWithDate:date ingestionDate:ingestionDate x:nil y:nil z:nil magnitude:magnitude];
}

- (id)initWithDate:(NSDate *)date x:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z magnitude:(NSNumber *)magnitude {
    return [self initWithDate:date ingestionDate:nil x:x y:y z:z magnitude:magnitude];
}

- (id)initWithDate:(NSDate *)date ingestionDate:(NSDate *)ingestionDate x:(NSNumber *)x y:(NSNumber *)y z:(NSNumber *)z magnitude:(NSNumber *)magnitude {
    self = [super initWithDate:date ingestionDate:ingestionDate];
    
    if (self) {
        _x = x;
        _y = y;
        _z = z;
        _magnitude = magnitude;
    }
    
    return self;
}

#define kX         @"x"
#define kY         @"y"
#define kZ         @"z"
#define kMagnitude @"Magnitude"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if (self) {
        _x = [decoder decodeObjectForKey:kX];
        _y = [decoder decodeObjectForKey:kY];
        _z = [decoder decodeObjectForKey:kZ];
        _magnitude = [decoder decodeObjectForKey:kMagnitude];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_x forKey:kX];
    [encoder encodeObject:_y forKey:kY];
    [encoder encodeObject:_z forKey:kZ];
    [encoder encodeObject:_magnitude forKey:kMagnitude];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, x: %@ g, y: %@ g, z: %@ g, magnitude: %@ g", [super description], self.x, self.y, self.z, self.magnitude];
}

@end
