//
//  ASCharacteristic.h
//  Pods
//
//  Created by Michael Gordon on 12/11/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@class ASDevice, CBCharacteristic;
@protocol ASService;

@interface ASCharacteristic : NSObject

@property (weak, readonly, nonatomic) ASDevice *device;
@property (strong, readonly, nonatomic) CBCharacteristic *internalCharacteristic;
@property (weak, readonly, nonatomic) id<ASService> service;

- (instancetype)initWithDevice:(ASDevice *)device service:(id<ASService>)service internalCharacteristic:(CBCharacteristic *)internalCharacteristic;

@end
