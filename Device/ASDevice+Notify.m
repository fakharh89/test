//
//  ASDevice+Notify.m
//  Blustream
//
//  Created by Michael Gordon on 2/6/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice+Notify.h"

#import "ASServiceV1.h"
#import "ASPIOCharacteristic.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "NSError+ASError.h"
#import "ASSystemManager.h"
#import "ASConfig.h"
#import "ASLog.h"

@implementation ASDevice (Notify)

#pragma mark - Public Methods

- (ASNotifyState)PIONotifyState {
    ASServiceV1 *service = self.services[[ASServiceV1 identifier].lowercaseString];
    
    if (service.PIOCharacteristic) {
        if (service.PIOCharacteristic.isNotifying) {
            return ASNotifyStateEnabled;
        }
        else {
            return ASNotifyStateDisabled;
        }
    }
    else {
        return ASNotifyStateUnknown;
    }
}


#pragma mark - Private Methods

- (void)setPIONotify:(BOOL)enabled completion:(void (^)(NSError *error))completion {
    ASServiceV1 *service = self.services[[ASServiceV1 identifier].lowercaseString];
    
    if (!service.PIOCharacteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceNotifyErrorDomain code:ASDeviceNotifyErrorCharacteristicUndiscovered underlyingError:nil];
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
        return;
    }
    
    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, Notify enabled: %@", self.serialNumber, @(enabled)]);
    
    [service.PIOCharacteristic setNotify:enabled withCompletion:^(NSError *error) {
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    }];
}

// OTAU
//- (void)setTransferControlNotify:(BOOL)enabled completion:(void (^)(NSError *error))completion {
//    dispatch_async(self.processingQueue, ^{
//#warning broken
////        [self setNotify:enabled toCharacteristic:ASOTAUControlTransferCharacteristicUUID completion:^(NSError *error) {
////            if (completion) {
////                completion(error);
////            }
////        }];
//    });
//}
//
//- (void)setDataTransferNotify:(BOOL)enabled completion:(void (^)(NSError *error))completion {
//    dispatch_async(self.processingQueue, ^{
//#warning broken
////        [self setNotify:enabled toCharacteristic:ASOTAUDataTransferCharacteristicUUID completion:^(NSError *error) {
////            if (completion) {
////                completion(error);
////            }
////        }];
//    });
//}
@end
