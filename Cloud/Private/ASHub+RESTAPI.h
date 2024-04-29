//
//  ASHub+RESTAPI.h
//  Pods
//
//  Created by Michael Gordon on 11/21/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASHubPrivate.h"

@interface ASHub (RESTAPI)

- (void)putWithCompletion:(void (^)(NSError *error))completion;
- (void)deleteWithCompletion:(void (^)(NSError *error))completion;

@end
