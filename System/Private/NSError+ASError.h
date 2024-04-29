//
//  NSError+ASError.h
//  Blustream
//
//  Created by Michael Gordon on 7/27/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@interface NSError (ASError)

+ (NSError *)ASErrorWithDomain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)underlyingError;
+ (NSMutableDictionary *)readableUserInfoWith:(NSDictionary *)userInfo;

@end
