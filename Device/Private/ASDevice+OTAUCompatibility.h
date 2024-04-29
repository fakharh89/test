//
//  ASDevice+ASDevice_OTAUCompatibility.h
//  Pods
//
//  Created by Michael Gordon on 1/25/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice.h"

@interface ASDevice (OTAUCompatibility)

- (BOOL)as_isUpdateAvailable;
- (NSString *)as_latestAvailableUpdate;
- (NSString *)as_imagePath;

@end
