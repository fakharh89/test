//
//  ASSyncManager.h
//  Blustream
//
//  Created by Michael Gordon on 7/14/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@class ASSystemManager;
@class MSWeakTimer;

@interface ASSyncManager : NSObject

@property (nonatomic, strong) MSWeakTimer *syncTimer;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager;

- (void)start;
- (void)stop;

@end
