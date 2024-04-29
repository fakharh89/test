//
//  ASPIOBufferCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 12/11/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASPIOBufferCharacteristic.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "ASBLEDefinitions.h"
#import "ASBLEResult.h"
#import "ASContainerPrivate.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASPIOState.h"
#import "NSData+ASBLEResult.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

@interface ASPIOBufferCharacteristic ()

@property (copy, readwrite, nonatomic) void (^readCompletion)(NSError *error);
@property (copy, readwrite, nonatomic) void (^writeCompletion)(NSError *error);

@end

@implementation ASPIOBufferCharacteristic

#pragma mark - ASCharacteristic Methods

+ (NSString *)identifier {
    return ASPIOBufferCharacteristicUUIDv3;
}

- (void)didDisconnectWithError:(NSError *)error {
    [self didCompleteWriteWithError:error];
    [self didCompleteReadWithError:error sendFailureNotification:NO];
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
}

- (ASBLEResult<NSArray<ASBLEResult<ASPIOState *> *> *> *)process {
    NSData *data = self.internalCharacteristic.value;
    if (!data) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [data as_PIOBufferWithFirmwareVersion:self.device.softwareRevision];
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

#pragma mark - ASWriteableCharacteristic Methods

- (void)write:(NSNumber *)sizeToPrepare withCompletion:(void (^)(NSError *error))completion {
    if (self.writeCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorAlreadyPending underlyingError:nil];
        completion(error);
        return;
    }
    
    self.writeCompletion = completion;
    
    uint8_t length = [sizeToPrepare unsignedCharValue];
    NSData *rawData = [NSData dataWithBytes:&length length:sizeof(length)];
    
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

#pragma mark - ASBufferCharacteristic Methods

+ (NSString *)notificationCharacteristicString {
    return ASPIOCharactUUID;
}

- (BOOL)updateDeviceWithMeasurement:(ASPIOState *)measurement error:(NSError * __autoreleasing *)error {
    NSParameterAssert(measurement);
    
    // Make sure we didn't go back in time
    NSTimeInterval timeInterval = [measurement.date timeIntervalSinceDate:self.device.container.PIOStates.lastObject.date];
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
    
    [self.device.container addNewPIOMeasurement:measurement];
    
    ASLog(@"Read PIO data: %@", measurement);
    
    return YES;
}

@end
