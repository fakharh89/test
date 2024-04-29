//
//  ASPIOCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASPIOCharacteristic.h"

#import "ASBLEDefinitions.h"
#import "ASContainerPrivate.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASPIOState.h"
#import "NSData+ASBLEResult.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ASPIOCharacteristic ()

@property (copy, readwrite, nonatomic) void (^readCompletion)(NSError *error);
@property (copy, readwrite, nonatomic) void (^notifyCompletion)(NSError *error);
@property (copy, readwrite, nonatomic) void (^writeCompletion)(NSError *error);

@end

@implementation ASPIOCharacteristic

#pragma mark - ASCharacteristic Methods

+ (NSString *)identifier {
    return ASPIOCharactUUID;
}

- (void)didDisconnectWithError:(NSError *)error {
    [self didCompleteWriteWithError:error];
    [self didCompleteReadWithError:error sendFailureNotification:NO];
    [self didCompleteNotifyWithError:error];
}

- (BOOL)updateDeviceWithData:(ASPIOState *)data error:(NSError *__autoreleasing *)error {
    // Make sure we didn't go back in time
    NSTimeInterval timeInterval = [data.date timeIntervalSinceDate:self.device.container.PIOStates.lastObject.date];
    if (timeInterval < 0) {
        ASLog(@"Bad PIO packet: Packet went back in time");
        if (error) {
            *error = [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorDateWentBackInTime underlyingError:nil];
        }
        return NO;
    } else if (timeInterval == 0) {
        ASLog(@"Bad PIO packet: Packet is same as last data added");
        if (error) {
            *error = [NSError ASErrorWithDomain:ASDeviceBLEDataErrorDomain code:ASDeviceBLEDataErrorDateNotUnique underlyingError:nil];
        }
        return NO;
    }
    
    [self.device.container addNewPIOMeasurement:data];
    
    ASLog(@"Read PIO data: %@", data);
    return YES;
}

#pragma mark - ASUpdatableCharacteristic Methods

- (void)didReadDataWithError:(NSError *)error {
    [self didCompleteReadWithError:error sendFailureNotification:YES];
}

- (void)didCompleteReadWithError:(NSError *)error sendFailureNotification:(BOOL)sendFailureNotification {
    if (self.readCompletion) {
        void (^failureCopy)(NSError *error) = self.readCompletion;
        self.readCompletion = nil;
        failureCopy(error);
    }
    else if (sendFailureNotification) {
        [self processUpdateDeviceAndSendNotificationWithError:error];
    }
}

- (ASBLEResult<ASPIOState *> *)process {
    NSData *data = self.internalCharacteristic.value;
    if (!data) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [data as_PIOStateWithFirmwareVersion:self.device.softwareRevision];
}

- (void)sendNotificationWithError:(NSError *)error {
    NSDictionary *userInfo = nil;
    NSString *notificationName = nil;
    
    if (error) {
        notificationName = ASContainerCharacteristicReadFailedNotification;
        userInfo = @{@"characteristic":[[self class] identifier],
                     @"error":error};
    }
    else {
        notificationName = ASContainerCharacteristicReadNotification;
        userInfo = @{@"characteristic":[[self class] identifier]};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:notificationName object:self.device.container userObject:userInfo waitUntilDone:YES];
}

#pragma mark - ASReadableCharacteristic Methods

- (void)readWithCompletion:(void (^)(NSError *error))failure {
    if (self.readCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorAlreadyPending underlyingError:nil];
        failure(error);
        return;
    }
    
    self.readCompletion = failure;
    [self.device.peripheral readValueForCharacteristic:self.internalCharacteristic];
}

- (void)processUpdateDeviceAndSendNotificationWithError:(NSError *)error {
    if (error) {
        [self sendNotificationWithError:error];
        return;
    }
    
    ASBLEResult<ASPIOState *> *result = [self process];
    
    if (result.error) {
        [self sendNotificationWithError:result.error];
        return;
    }
    
    NSError *updateError = nil;
    if (![self updateDeviceWithData:result.value error:&updateError]) {
        [self sendNotificationWithError:updateError];
        return;
    }
    
    [self sendNotificationWithError:nil];
}

- (void)readProcessUpdateDeviceAndSendNotification {
    [self readWithCompletion:^(NSError *error) {
        [self processUpdateDeviceAndSendNotificationWithError:error];
    }];
}

#pragma mark - ASWriteableCharacteristic Methods

- (void)write:(NSNumber *)byte withCompletion:(void (^)(NSError *error))completion {
    if (self.writeCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorAlreadyPending underlyingError:nil];
        completion(error);
        return;
    }
    
    self.writeCompletion = completion;
    
    uint8_t rawByte = byte.unsignedCharValue;
    
    // Ignore extra bytes that could be sent
    rawByte = (rawByte << 5) >> 5;
    NSData *rawData = [NSData dataWithBytes:&rawByte length:sizeof(rawByte)];
    
    [self.device.peripheral writeValue:rawData forCharacteristic:self.internalCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)didCompleteWriteWithError:(NSError *)error {
    if (self.writeCompletion) {
        void (^failureCopy)(NSError *error) = self.writeCompletion;
        self.writeCompletion = nil;
        if (failureCopy) {
            failureCopy(error);
        }
    }
}

#pragma mark - ASNotifiableMethods

- (BOOL)isNotifying {
    return self.internalCharacteristic.isNotifying;
}

- (void)setNotify:(BOOL)enabled withCompletion:(void (^)(NSError *error))completion {
    if (self.notifyCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceNotifyErrorDomain code:ASDeviceNotifyErrorAlreadyPending underlyingError:nil];
        completion(error);
        return;
    }
    
    self.notifyCompletion = completion;
    [self.device.peripheral setNotifyValue:enabled forCharacteristic:self.internalCharacteristic];
}

- (void)didSetNotifyWithError:(NSError *)error {
    [self didCompleteNotifyWithError:error];
}

- (void)didCompleteNotifyWithError:(NSError *)error {
    if (self.notifyCompletion) {
        void (^failureCopy)(NSError *error) = self.notifyCompletion;
        self.notifyCompletion = nil;
        failureCopy(error);
    }
}

@end
