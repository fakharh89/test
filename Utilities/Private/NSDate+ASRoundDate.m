//
//  NSDate+ASRoundDate.m
//  Blustream
//
//  Created by Michael Gordon on 7/17/16.
//
//

#import "NSDate+ASRoundDate.h"

@implementation NSDate (ASRoundDate)

- (NSDate *)as_roundMillisecondsToThousands {
    NSTimeInterval timeSince1970 = [self timeIntervalSince1970];
    timeSince1970 = round(timeSince1970 * 1000.0) / 1000.0;
    
    return [NSDate dateWithTimeIntervalSince1970:timeSince1970];
}

@end
