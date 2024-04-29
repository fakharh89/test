//
//  ASBLEResult.h
//  Pods
//
//  Created by Michael Gordon on 12/5/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@interface ASBLEResult<ObjectType> : NSObject

@property (strong, readonly, nonatomic) NSData *data;
@property (strong, readwrite, nonatomic) NSError *error;
@property (assign, readonly, nonatomic) BOOL successful;
@property (strong, readonly, nonatomic) ObjectType value;

- (instancetype)initWithValue:(ObjectType)value data:(NSData *)rawData error:(NSError *)error;

@end
