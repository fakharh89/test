//
//  ASUtils.m
//  Blustream
//
//  Created by Michael Gordon on 10/14/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASUtils.h"

@implementation ASUtils

+ (BOOL)detectChangeBetweenString:(NSString *)str1 string:(NSString *)str2 {
    BOOL changed = NO;
    
    if (str1 != str2) {
        if (str1 && str2) {
            changed = ([str1 compare:str2] != NSOrderedSame);
        }
        else {
            changed = YES;
        }
    }
    
    return changed;
}

@end
