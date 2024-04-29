//
//  NSData+ASHexString.m
//  Pods
//
//  Created by Michael Gordon on 2/1/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "NSData+ASHexString.h"

@implementation NSData (ASHexString)

+ (NSData *)as_dataWithHexString:(NSString *)hexString {
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    hexString = [hexString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    
    char byte_chars[3] = {'\0','\0','\0'};
    
    for (int i = 0; i < hexString.length / 2; i++) {
        byte_chars[0] = [hexString characterAtIndex:i * 2];
        byte_chars[1] = [hexString characterAtIndex:(i * 2) + 1];
        unsigned char byte = strtol(byte_chars, NULL, 16);
        [mutableData appendBytes:&byte length:1];
    }
    
    return [NSData dataWithData:mutableData];
}

@end
