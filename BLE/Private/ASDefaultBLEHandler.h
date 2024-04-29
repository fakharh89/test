//
//  ASBLEDefaultHandler.h
//  Blustream
//
//  Created by Michael Gordon on 7/10/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

#import "ASBLEInterface.h"

@class ASSystemManager;

@interface ASDefaultBLEHandler : NSObject <ASBLEInterfaceDelegate>

@property (nonatomic, weak, readonly) ASSystemManager *systemManager;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager NS_DESIGNATED_INITIALIZER;

@end
