//
//  ASDevice+BLEUpdate.h
//  Blustream
//
//  Created by Michael Gordon on 2/16/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevicePrivate.h"

@class ASAdvertisementData;

@interface ASDevice (BLEUpdate)

- (void)updateFromAdvertisementData:(ASAdvertisementData *)advertisementData;

@end
