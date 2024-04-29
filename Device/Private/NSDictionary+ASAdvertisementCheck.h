//
//  NSDictionary+ASAdvertisementCheck.h
//  Blustream
//
//  Created by Michael Gordon on 2/16/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

#import "ASDevicePrivate.h"

@class ASAdvertisementData;

@interface NSDictionary (ASAdvertisementCheck)

- (ASAdvertisementData *)as_advertisementData;
- (ASDeviceConnectionMode)as_deviceConnectionMode;
- (void)as_dumpAdvertisingData;

@end
