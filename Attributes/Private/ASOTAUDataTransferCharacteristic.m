//
//  ASOTAUDataTransferCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 1/12/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASOTAUDataTransferCharacteristic.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import "ASBLEDefinitions.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "ASNotifications.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"
#import "NSData+ASBLEResult.h"

@interface ASOTAUDataTransferCharacteristic ()

@property (copy, readwrite, nonatomic) void (^readCompletion)(NSError *error);
@property (copy, readwrite, nonatomic) void (^notifyCompletion)(NSError *error);
@property (copy, readwrite, nonatomic) void (^writeCompletion)(NSError *error);

@end

@implementation ASOTAUDataTransferCharacteristic

+ (NSString *)identifier {
    return ASOTAUDataTransferCharacteristicUUID;
}

- (void)didDisconnectWithError:(NSError *)error {
    [self didCompleteNotifyWithError:error];
    [self didCompleteReadWithError:error sendFailureNotification:NO];
    [self didCompleteWriteWithError:error];
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
        [self sendNotificationWithError:error];
    }
}

- (ASBLEResult<NSData *> *)process {
    NSData *data = self.internalCharacteristic.value;
    if (!data) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }

    return [data as_OTAUDataTransfer];
}

- (void)sendNotificationWithError:(NSError *)error {
    NSDictionary *userInfo = nil;

    if (error) {
        userInfo = @{@"error":error};
    }

    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"dataTransferCharacteristic" object:self.device userObject:userInfo waitUntilDone:YES];
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

#pragma mark - ASWriteableCharacteristic Methods

- (void)write:(NSData *)imageChunk withCompletion:(void (^)(NSError *error))completion {
    if (self.writeCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorAlreadyPending underlyingError:nil];
        completion(error);
        return;
    }
    
    self.writeCompletion = completion;
    
    [self.device.peripheral writeValue:imageChunk forCharacteristic:self.internalCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)didCompleteWriteWithError:(NSError *)error {
    if (self.writeCompletion) {
        void (^failureCopy)(NSError *error) = self.writeCompletion;
        self.writeCompletion = nil;
        
        failureCopy(error);
    }
}

@end
