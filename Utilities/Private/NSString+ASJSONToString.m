//
//  NSString+ASJSONToString.m
//  Blustream
//
//  Created by Michael Gordon on 6/28/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "NSString+ASJSONToString.h"

@implementation NSString (ASJSONToString)

+ (NSString *)stringWithDictionary:(NSDictionary *)dictionary {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *string = nil;
    if (!error) {
        string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return string;
}

@end
