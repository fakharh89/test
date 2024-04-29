//
//  NSDictionary+ASAccountCheck.h
//  Blustream
//
//  Created by Michael Gordon on 7/27/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ASAccountCheck)

- (BOOL)checkLoginInfoWithError:(NSError * __autoreleasing *)error tagLength:(NSInteger)tagLength;

@end
