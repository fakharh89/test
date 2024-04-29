//
//  ASCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 12/11/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASCharacteristic.h"

#import <CoreBluetooth/CoreBluetooth.h>

@implementation ASCharacteristic

- (instancetype)initWithDevice:(ASDevice *)device service:(id<ASService>)service internalCharacteristic:(CBCharacteristic *)internalCharacteristic {
    self = [super init];
    if (self) {
        _device = device;
        _internalCharacteristic = internalCharacteristic;
        _service = service;
    }
    return self;
}

@end
