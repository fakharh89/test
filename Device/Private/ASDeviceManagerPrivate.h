//
//  ASDeviceManagerPrivate.h
//  Blustream
//
//  Created by Michael Gordon on 6/26/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDeviceManager.h"

@class ASBLEInterface;
@class ASSystemManager;

@interface ASDeviceManager ()

@property (nonatomic, strong) NSMutableArray *devicesInternal;
@property (nonatomic, strong) NSMutableArray *stuckDevicesInternal;

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager;

- (void)addDevice:(ASDevice *)device;
- (void)loadDevices;
- (void)saveDevices;
- (void)resetDevices;

- (void)addStuckDevice:(ASDevice *)device;
- (void)removeStuckDevice:(ASDevice *)device;

- (void)saveDevice:(ASDevice *)device;

@end
