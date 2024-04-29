//
//  NSData+ASHexString.h
//  Pods
//
//  Created by Michael Gordon on 2/1/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@interface NSData (ASHexString)

+ (NSData *)as_dataWithHexString:(NSString *)hexString;

@end
