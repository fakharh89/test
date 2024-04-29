//
//  ASRegistrationCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASRegistrationCharacteristic.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "ASBLEDefinitions.h"
#import "ASDevicePrivate.h"
#import "ASNotifications.h"
#import "ASErrorDefinitions.h"
#import "NSData+ASBLEResult.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

@interface ASRegistrationCharacteristic ()

@property (copy, readwrite, nonatomic) void (^writeCompletion)(NSError *error);
@property (copy, readwrite, nonatomic) void (^notifyCompletion)(NSError *error);

@end

@implementation ASRegistrationCharacteristic

#pragma mark - ASCharacteristic Methods

+ (NSString *)identifier {
    return ASRegistrationCharactUUID;
}

- (void)didDisconnectWithError:(NSError *)error {
    [self didCompleteWriteWithError:error];
    [self didCompleteNotifyWithError:error];
}

- (BOOL)updateDeviceWithData:(NSData *)data error:(NSError *__autoreleasing *)error {
    self.device.registrationData = data;
    return YES;
}

#pragma mark - ASUpdatableCharacteristic Methods

- (void)didReadDataWithError:(NSError *)error {
    [self processUpdateDeviceAndSendNotificationWithError:error];
}

- (ASBLEResult<NSData *> *)process {
    NSData *data = self.internalCharacteristic.value;
    if (!data) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [data as_registrationData];
}

//- (void)sendNotificationWithError:(NSError *)error {
//    NSDictionary *userInfo = nil;
//    NSString *notificationName = nil;
//
//    if (error) {
//        notificationName = ASContainerCharacteristicReadFailedNotification;
//        userInfo = @{@"characteristic":[[self class] identifier],
//                     @"error":error};
//    }
//    else {
//        notificationName = ASContainerCharacteristicReadNotification;
//        userInfo = @{@"characteristic":[[self class] identifier]};
//    }
//
//    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:notificationName object:self.device.container userObject:userInfo waitUntilDone:YES];
//}

- (void)sendNotificationWithError:(NSError *)error {
    if (!error)  {
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:@"registrationDataRead" object:self.device userObject:@{@"characteristic":ASRegistrationCharactUUID} waitUntilDone:YES];
    }
}

- (void)processUpdateDeviceAndSendNotificationWithError:(NSError *)error {
    if (error) {
        [self sendNotificationWithError:error];
        return;
    }
    
    ASBLEResult<NSData *> *result = [self process];
    
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

#pragma mark - ASWriteableCharacteristic Methods

- (void)write:(NSData *)data withCompletion:(void (^)(NSError *error))completion {
    if (self.writeCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorAlreadyPending underlyingError:nil];
        completion(error);
        return;
    }
    
    self.writeCompletion = completion;
    
    const char *bytes = [data bytes];
    char *reverseBytes = malloc(sizeof(char) * [data length]);
    unsigned long index = [data length] - 1;
    for (int i = 0; i < [data length]; i++) {
        reverseBytes[index--] = bytes[i];
    }
    NSData *reversedData = [NSData dataWithBytes:reverseBytes length:[data length]];
    free(reverseBytes);
    
    [self.device.peripheral writeValue:reversedData forCharacteristic:self.internalCharacteristic type:CBCharacteristicWriteWithResponse];
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

#pragma mark - ASNotifiableCharacteristic Methods

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
