//
//  ASOTAUControlTransferCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 1/12/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASOTAUControlTransferCharacteristic.h"

#import "ASBLEDefinitions.h"
#import "ASContainerPrivate.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "NSData+ASBLEResult.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ASOTAUControlTransferCharacteristic ()

@property (copy, readwrite, nonatomic) void (^readCompletion)(NSError *error);
@property (copy, readwrite, nonatomic) void (^notifyCompletion)(NSError *error);
@property (copy, readwrite, nonatomic) void (^writeCompletion)(NSError *error);

@end

@implementation ASOTAUControlTransferCharacteristic

+ (NSString *)identifier {
    return ASOTAUControlTransferCharacteristicUUID;
}

- (void)didDisconnectWithError:(NSError *)error {
    [self didCompleteNotifyWithError:error];
    [self didCompleteReadWithError:error sendFailureNotification:NO];
    [self didCompleteWriteWithError:error];
}

//- (BOOL)updateDeviceWithData:(ASErrorState *)data error:(NSError *__autoreleasing *)error {
//    ASLog(@"Read Error State: %@", data);
//    [self.device.container addNewErrorStateMeasurement:data];
//    return YES;
//}

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

- (ASBLEResult<NSNumber *> *)process {
    NSData *data = self.internalCharacteristic.value;
    if (!data) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [data as_OTAUTransferControl];
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

- (void)write:(NSNumber *)control withCompletion:(void (^)(NSError *error))completion {
    if (self.writeCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorAlreadyPending underlyingError:nil];
        completion(error);
        return;
    }
    
    self.writeCompletion = completion;
    
    uint16_t rawValue = control.unsignedShortValue;
    NSData *data = [NSData dataWithBytes:(void *)&rawValue length:sizeof(rawValue)];
    
    [self.device.peripheral writeValue:data forCharacteristic:self.internalCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)didCompleteWriteWithError:(NSError *)error {
    if (self.writeCompletion) {
        void (^failureCopy)(NSError *error) = self.writeCompletion;
        self.writeCompletion = nil;
        
        failureCopy(error);
    }
}

@end
