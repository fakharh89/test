//
//  ASOTAUKeyCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 1/12/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASOTAUKeyCharacteristic.h"

#import "ASBLEDefinitions.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "NSData+ASBLEResult.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ASOTAUKeyCharacteristic ()

@property (copy, readwrite, nonatomic) void (^writeCompletion)(NSError *error);

@end

@implementation ASOTAUKeyCharacteristic

#pragma mark - ASCharacteristic Methods

+ (NSString *)identifier {
    return ASOTAUKeyCharacteristicUUID;
}

- (void)didDisconnectWithError:(NSError *)error {
    [self didCompleteWriteWithError:error];
}

#pragma mark - ASWriteableCharacteristic Methods

- (void)write:(NSNumber *)keyBlock withCompletion:(void (^)(NSError *error))completion {
    if (self.writeCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorAlreadyPending underlyingError:nil];
        completion(error);
        return;
    }
    
    self.writeCompletion = completion;
    
    uint8_t rawValue = keyBlock.unsignedCharValue;
    NSData *data = [NSData dataWithBytes:(void *)&rawValue length:sizeof(rawValue)];
    
    ASLog(@"Writing OTAU Key Characteristic: %@", data);
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
