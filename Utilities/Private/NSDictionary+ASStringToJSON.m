//
//  NSDictionary+ASStringToJSON.m
//  Blustream
//
//  Created by Michael Gordon on 6/28/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "NSDictionary+ASStringToJSON.h"

@implementation NSDictionary (ASStringToJSON)

+ (NSDictionary *)dictionaryWithString:(NSString *)string {
    NSError *error = nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
}


@end
