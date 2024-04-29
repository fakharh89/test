//
//  ASCharacteristic.h
//  Pods
//
//  Created by Michael Gordon on 12/6/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

#import "ASBLEResult.h"

@class ASDevice;
@class ASMeasurement;
@class CBCharacteristic;
@class CBService;

@protocol ASCharacteristic;

@protocol ASAttribute <NSObject>

@required
@property (weak, readonly, nonatomic) ASDevice *device;

+ (NSString *)identifier;

@end

@protocol ASService <ASAttribute>

@required
@property (weak, readonly, nonatomic) CBService *internalService;
@property (strong, readonly, nonatomic) NSDictionary<NSString *, id<ASCharacteristic>> *characteristics;

- (instancetype)initWithDevice:(ASDevice *)device internalService:(CBService *)internalService;
- (void)addCharacteristic:(id<ASCharacteristic>)characteristic;

@end

@protocol ASCharacteristic <ASAttribute>

@required
@property (weak, readonly, nonatomic) CBCharacteristic *internalCharacteristic;
@property (weak, readonly, nonatomic) id<ASService> service;

- (instancetype)initWithDevice:(ASDevice *)device service:(id<ASService>)service internalCharacteristic:(CBCharacteristic *)internalCharacteristic;
- (void)didDisconnectWithError:(NSError *)error;

@optional
- (BOOL)updateDeviceWithData:(id)data error:(NSError * __autoreleasing *)error;

@end

@protocol ASWriteableCharacteristic <ASCharacteristic>

@required
- (void)write:(id)data withCompletion:(void (^)(NSError *error))completion;
- (void)didCompleteWriteWithError:(NSError *)error;

@end

@protocol ASUpdatableCharacteristic <ASCharacteristic>

@required
- (void)didReadDataWithError:(NSError *)error;
- (ASBLEResult *)process;

@optional
- (void)sendNotificationWithError:(NSError *)error;

@end

@protocol ASReadableCharacteristic <ASUpdatableCharacteristic>

@required
- (void)readWithCompletion:(void (^)(NSError *error))completion;

@optional
- (void)readProcessUpdateDeviceAndSendNotification;

@end

@protocol ASNotifiableCharacteristic <ASUpdatableCharacteristic>

@required
- (BOOL)isNotifying;
- (void)setNotify:(BOOL)enabled withCompletion:(void (^)(NSError *error))completion;
- (void)didSetNotifyWithError:(NSError *)error;

@end

@protocol ASBufferCharacteristic <ASReadableCharacteristic, ASWriteableCharacteristic>

@required
+ (NSString *)notificationCharacteristicString;
- (BOOL)updateDeviceWithMeasurement:(ASMeasurement *)measurement error:(NSError * __autoreleasing *)error;

@end

@protocol ASCustomizableCharacteristic

+ (NSString *)identifier;

@end
