//
//  ASOTAUKeyBlockCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 1/12/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASOTAUKeyBlockCharacteristic.h"

#import "ASBLEDefinitions.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "NSData+ASBLEResult.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ASOTAUKeyBlockCharacteristic ()

@property (copy, readwrite, nonatomic) void (^writeCompletion)(NSError *error);

@end

@implementation ASOTAUKeyBlockCharacteristic

#pragma mark - ASCharacteristic Methods

+ (NSString *)identifier {
    return ASOTAUKeyBlockCharacteristicUUID;
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
    
    uint32_t rawValue = keyBlock.unsignedIntValue;
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
