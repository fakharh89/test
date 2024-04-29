//
//  ASEnvironmentalAlarmLimitsCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASEnvironmentalAlarmLimitsCharacteristic.h"

#import "ASAlarmLimits.h"
#import "ASBLEDefinitions.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "ASNotifications.h"
#import "NSData+ASBLEResult.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ASEnvironmentalAlarmLimitsCharacteristic ()

@property (copy, readwrite, nonatomic) void (^readCompletion)(NSError *error);
@property (copy, readwrite, nonatomic) void (^writeCompletion)(NSError *error);
@property (strong, readwrite, nonatomic) ASAlarmLimits *writtenAlarmLimits;

@end

@implementation ASEnvironmentalAlarmLimitsCharacteristic

#pragma mark - ASCharacteristic Methods

+ (NSString *)identifier {
    return ASEnvAlarmLimitsCharactUUID;
}

- (void)didDisconnectWithError:(NSError *)error {
    [self didCompleteWriteWithError:error];
    [self didCompleteReadWithError:error sendFailureNotification:NO];
}

- (BOOL)updateDeviceWithData:(ASAlarmLimits *)data error:(NSError *__autoreleasing *)error {
    self.device.hardwareHumidAlarmMax = data.maximumHumidity;
    self.device.hardwareHumidAlarmMin = data.minimumHumidity;
    self.device.hardwareTempAlarmMax = data.maximumTemperature;
    self.device.hardwareTempAlarmMin = data.minimumTemperature;
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

- (ASBLEResult<ASAlarmLimits *> *)process {
    NSData *data = self.internalCharacteristic.value;
    if (!data) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorUnknown underlyingError:nil];
        return [[ASBLEResult alloc] initWithValue:nil data:nil error:error];
    }
    
    return [data as_alarmLimits];
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
        
        ASBLEResult<ASAlarmLimits *> *result = [self process];
        
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

- (void)write:(ASAlarmLimits *)alarmLimits withCompletion:(void (^)(NSError *error))completion {
    if (self.writeCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorAlreadyPending underlyingError:nil];
        completion(error);
        return;
    }
    
    self.writeCompletion = completion;
    
    uint16_t b0 = CFSwapInt16HostToLittle((uint16_t) (100 * alarmLimits.maximumHumidity.floatValue));
    uint16_t b1 = CFSwapInt16HostToLittle((uint16_t) (100 * alarmLimits.minimumHumidity.floatValue));
    uint16_t b2 = CFSwapInt16HostToLittle((uint16_t) (100 * alarmLimits.maximumTemperature.floatValue));
    uint16_t b3 = CFSwapInt16HostToLittle((uint16_t) (100 * alarmLimits.minimumTemperature.floatValue));
    
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    [mutableData appendBytes:&b0 length:2];
    [mutableData appendBytes:&b1 length:2];
    [mutableData appendBytes:&b2 length:2];
    [mutableData appendBytes:&b3 length:2];
    NSData *rawData = [NSData dataWithData:mutableData];
    
    NSNumber *hHighWritten, *hLowWritten, *tHighWritten, *tLowWritten;
    
    hHighWritten = @(((int16_t) CFSwapInt16LittleToHost(b0)) / 100.0);
    hLowWritten = @(((int16_t) CFSwapInt16LittleToHost(b1)) / 100.0);
    tHighWritten = @(((int16_t) CFSwapInt16LittleToHost(b2)) / 100.0);
    tLowWritten = @(((int16_t) CFSwapInt16LittleToHost(b3)) / 100.0);
    
    ASAlarmLimits *writtenLimits = [[ASAlarmLimits alloc] init];
    writtenLimits.maximumHumidity = hHighWritten;
    writtenLimits.minimumHumidity = hLowWritten;
    writtenLimits.maximumTemperature = tHighWritten;
    writtenLimits.minimumTemperature = tLowWritten;
    
    self.writtenAlarmLimits = writtenLimits;
    
    [self.device.peripheral writeValue:rawData forCharacteristic:self.internalCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)didCompleteWriteWithError:(NSError *)error {
    if (self.writeCompletion) {
        void (^failureCopy)(NSError *error) = self.writeCompletion;
        self.writeCompletion = nil;
        
        if (!error) {
            [self updateDeviceWithData:self.writtenAlarmLimits error:&error];
        }
        
        self.writtenAlarmLimits = nil;
        
        if (failureCopy) {
            failureCopy(error);
        }
    }
}

@end
