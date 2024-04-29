//
//  ASService.h
//  Pods
//
//  Created by Michael Gordon on 12/11/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@protocol ASCharacteristic;
@class ASDevice, CBService;

@interface ASService : NSObject

@property (weak, readonly, nonatomic) ASDevice *device;
@property (strong, readonly, nonatomic) CBService *internalService;

@property (strong, readonly, nonatomic) NSDictionary<NSString *, id<ASCharacteristic>> *characteristics;

- (instancetype)initWithDevice:(ASDevice *)device internalService:(CBService *)internalService;
- (void)addCharacteristic:(id<ASCharacteristic>)characteristic;

@end
