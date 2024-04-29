//
//  ASMeasurement.h
//  Blustream
//
//  Created by Michael Gordon on 7/20/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASMeasurement.h"

typedef NS_ENUM(NSUInteger, ASSyncStatus) {
    ASSyncStatusUnsent = 0,
    ASSyncStatusSending = 1,
    ASSyncStatusSent = 2
};

@interface ASMeasurement ()

@property (assign, readwrite, nonatomic) ASSyncStatus syncStatus;

@end
