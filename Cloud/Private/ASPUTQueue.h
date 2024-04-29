//
//  ASPUTQueue.h
//  Blustream
//
//  Created by Michael Gordon on 3/3/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@class ASSystemManager, ASContainer, MSWeakTimer;

@interface ASPUTQueue : NSObject

@property (nonatomic, strong) MSWeakTimer *PUTTimer;
@property (nonatomic, strong) MSWeakTimer *delayedFireTimer;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager;

- (void)start;
- (void)stop;
- (void)fire;
- (void)delayedFire;

@end
