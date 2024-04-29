//
//  ASEnvironmentalRealtimeModeCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASEnvironmentalRealtimeModeCharacteristic.h"

#import "ASBLEDefinitions.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "NSData+ASBLEResult.h"
#import "NSError+ASError.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ASEnvironmentalRealtimeModeCharacteristic ()

@property (copy, readwrite, nonatomic) void (^writeCompletion)(NSError *error);

@end

@implementation ASEnvironmentalRealtimeModeCharacteristic

#pragma mark - ASCharacteristic Methods

+ (NSString *)identifier {
    return ASEnvRealtimeCharactUUID;
}

- (void)didDisconnectWithError:(NSError *)error {
    [self didCompleteWriteWithError:error];
}

#pragma mark - ASWriteableCharacteristic Methods

- (void)write:(id)data withCompletion:(void (^)(NSError *error))completion {
    if (self.writeCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorAlreadyPending underlyingError:nil];
        completion(error);
        return;
    }
    
    self.writeCompletion = completion;
    
    uint8_t num = 1;
    NSData *rawData = [NSData dataWithBytes:&num length:sizeof(num)];
    
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

@end
