//
//  ASResourceManager.h
//  Pods
//
//  Created by Michael Gordon on 11/3/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@interface ASResourceManager : NSObject

@property (strong, readonly, nonatomic) NSBundle *bundle;
@property (strong, readonly, nonatomic) NSDictionary *CSKeyDatabase;
@property (strong, readonly, nonatomic) NSDictionary *OTAUImageDatabase;
@property (strong, readonly, nonatomic) NSArray<NSString *> *imagePaths;

- (id)initWithResourceName:(NSString *)name;

@end
