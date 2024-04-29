//
//  NSNumber+ASRoundNumber.m
//  Blustream
//
//  Created by Michael Gordon on 7/17/16.
//
//

#import "NSNumber+ASRoundNumber.h"

@implementation NSNumber (ASRoundNumber)

- (NSNumber *)as_roundToHundreths {
    return @(roundf(self.floatValue * 100.0) / 100.0);
}

@end
