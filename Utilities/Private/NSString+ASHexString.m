//
//  NSString+ASHexString.m
//  Pods
//
//  Created by Michael Gordon on 11/17/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "NSString+ASHexString.h"

@implementation NSString (ASHexString)

+ (NSString *)as_hexStringWithData:(NSData *)data {
    unsigned char *dataBuffer = (unsigned char *)data.bytes;
    
    if (!dataBuffer) {
        return @"";
    }
    
    NSUInteger length = data.length;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(length * 2)];
    
    for (int i = 0; i < length; ++i) {
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    
    return [NSString stringWithString:hexString];
}

@end
