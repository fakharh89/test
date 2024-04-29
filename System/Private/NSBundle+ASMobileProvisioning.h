//
//  NSBundle+ASMobileProvisioning.h
//  Pods
//
//  Created by Michael Gordon on 11/17/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ASAPSEnvironment) {
    ASAPSEnvironmentUnknown,
    ASAPSEnvironmentDevelopment,
    ASAPSEnvironmentProduction
};

@interface NSBundle (ASMobileProvisioning)

- (ASAPSEnvironment)as_APSEnvironment;

@end
