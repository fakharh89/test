//
//  ASEnvironmentalMeasurementIntervalCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASEnvironmentalMeasurementIntervalCharacteristic.h"

#import "ASBLEDefinitions.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "NSData+ASBLEResult.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ASEnvironmentalMeasurementIntervalCharacteristic ()

@property (copy, readwrite, nonatomic) void (^readCompletion)(NSError *error);
@property (copy, readwrite, nonatomic) void (^writeCompletion)(NSError *error);
@property (strong, readwrite, nonatomic) NSNumber *writtenMeasurementInterval;

@end

@implementation ASEnvironmentalMeasurementIntervalCharacteristic

#pragma mark - ASCharacteristic Methods

+ (NSString *)identifier {
    return ASEnvMeasIntervalCharactUUID;
}

- (void)didDisconnectWithError:(NSError *)error {
    [self didCompleteWriteWithError:error];
    [self didCompleteReadWithError:error sendFailureNotification:NO];
}

- (BOOL)updateDeviceWithData:(NSNumber *)data error:(NSError *__autoreleasing *)error {
    self.device.measurementInterval = data;
    ASLog(@"Read measurement interval: %llu", [data unsignedLongLongValue]);
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
}

- (ASBLEResult<NSNumber *> *)process {
    NSData *data = self.internalCharacteristic.value;
    if (!data) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [data as_timeInterval];
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

- (void)readProcessUpdateDeviceAndSendNotification {
    [self readWithCompletion:^(NSError *error) {
        if (error) {
            [self sendNotificationWithError:error];
            return;
        }
        
        ASBLEResult<NSNumber *> *result = [self process];
        
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
    }];
}

#pragma mark - ASWriteableCharacteristic Methods

- (void)write:(NSNumber *)measurementInterval withCompletion:(void (^)(NSError *error))completion {
    if (self.writeCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorAlreadyPending underlyingError:nil];
        completion(error);
        return;
    }
    
    self.writeCompletion = completion;
    
    uint32_t num = measurementInterval.unsignedIntValue;
    NSData *rawData = [NSData dataWithBytes:&num length:sizeof(num)];
    
    self.writtenMeasurementInterval = measurementInterval;
    
    [self.device.peripheral writeValue:rawData forCharacteristic:self.internalCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)didCompleteWriteWithError:(NSError *)error {
    if (self.writeCompletion) {
        void (^failureCopy)(NSError *error) = self.writeCompletion;
        self.writeCompletion = nil;
        
        if (!error) {
            [self updateDeviceWithData:self.writtenMeasurementInterval error:&error];
        }
        
        self.writtenMeasurementInterval = nil;
        
        failureCopy(error);
    }
}

@end
