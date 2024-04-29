//
//  NSString+ASJSONToString.h
//  Blustream
//
//  Created by Michael Gordon on 6/28/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@interface NSString (ASJSONToString)

+ (NSString *)stringWithDictionary:(NSDictionary *)dictionary;

@end
