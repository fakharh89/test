//
//  ASSystemManagerPrivate.h
//  Blustream
//
//  Created by Michael Gordon on 8/3/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASSystemManager.h"

@class ASBLEInterface;
@class ASContainerManager;
@class ASDeviceManager;
@class ASLocationManager;
@class ASResourceManager;

@interface ASSystemManager ()

@property (nonatomic, strong) ASConfig *config;
@property (nonatomic, strong) ASBLEInterface *BLEInterface;
@property (nonatomic, strong) ASCloud *cloud;
@property (nonatomic, strong) ASContainerManager *containerManager;
@property (nonatomic, strong) ASDeviceManager *deviceManager;
@property (nonatomic, strong) ASLocationManager *locationManager;
@property (nonatomic, strong) ASResourceManager *resourceManager;
@property (nonatomic, assign) BOOL ready;

+ (NSString *)applicationHiddenDocumentsDirectory;
+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path;

@end
