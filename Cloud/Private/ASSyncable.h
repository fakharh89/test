//
//  ASSyncable.h
//  Pods
//
//  Created by Michael Gordon on 1/26/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@protocol ASSyncable <NSObject>

@required
@property (strong, readwrite, nonatomic) *lastUpdated;
- (void)getSyncableProperties:(NSDictionary *dictionary);
- (void)syncWithCompletion:(void (^)(NSError *error))completion;

@optional
@property (strong, readwrite, nonatomic) NSDictionary *metadata;

@end
