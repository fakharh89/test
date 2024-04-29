//
//  ASService.m
//  Pods
//
//  Created by Michael Gordon on 12/11/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASService.h"

#import "ASAttribute.h"
#import "ASBLEDefinitions.h"
#import "ASDevice.h"

#import <CoreBluetooth/CoreBluetooth.h>

@implementation ASService

// This is not threadsafe
- (void)addCharacteristic:(id<ASCharacteristic>)characteristic {
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:self.characteristics];
    [mutableDictionary addEntriesFromDictionary:@{[[characteristic class] identifier].lowercaseString : characteristic}];
    _characteristics = [NSDictionary dictionaryWithDictionary:mutableDictionary];
}

- (instancetype)initWithDevice:(ASDevice *)device internalService:(CBService *)internalService {
    self = [super init];
    if (self) {
        _device = device;
        _internalService = internalService;
    }
    return self;
}

@end
