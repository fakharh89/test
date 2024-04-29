//
//  ASDevice+Read.m
//  Blustream
//
//  Created by Michael Gordon on 2/10/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASConfig.h"
#import "ASDevice+Read.h"
#import "ASServiceV1.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "NSError+ASError.h"
#import "ASSystemManager.h"
#import "ASLog.h"
#import "ASPIOCharacteristic.h"

@implementation ASDevice (Read)

- (void)readAIOData {
    [self readAIODataWithSuccess:nil failure:nil];
}

- (void)readPIOData {
    [self readPIODataWithSuccess:nil failure:nil];
}

- (void)readAIODataWithSuccess:(void (^)(ASAIOMeasurement *measurement))success failure:(void (^)(NSError *error))failure {
    ASLog(@"AIO read not implemented");
}

- (void)readPIODataWithSuccess:(void (^)(ASPIOState *state))success failure:(void (^)(NSError *error))failure {
    ASServiceV1 *service = self.services[[ASServiceV1 identifier].lowercaseString];
    // TODO Make this function handle the measurement buffer reads for arrays
    
    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, PIO Data is requested", self.serialNumber]);
    
    if (!service.PIOCharacteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceReadErrorDomain code:ASDeviceReadErrorCharacteristicUndiscovered underlyingError:nil];
        if (failure) {
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
        return;
    }
    
    [service.PIOCharacteristic readWithCompletion:^(NSError *error) {
        if (error) {
            if (failure) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
            return;
        }
        
        ASBLEResult<ASPIOState *> *result = [service.PIOCharacteristic process];
        
        if (result.error) {
            if (failure) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure(result.error);
                });
            }
            return;
        }
        
        if (success) {
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                success(result.value);
            });
        }
    }];
}

//- (void)readOTAUVersionWithSuccess:(void (^)(int version))success failure:(void (^)(NSError *error))failure {
//    dispatch_async(self.processingQueue, ^{
//#warning broken
//        [self readCharacteristic:ASOTAUVersionCharacteristicUUID autoUpdate:NO success:^(ASBLEResult *result) {
//            if (success) {
//                int version = ((NSNumber *)result.value).intValue;
//                success(version);
//            }
//        } failure:^(NSError *error) {
//            if (failure) {
//                failure(error);
//            }
//        }];
//    });
//}

//- (void)readTransferControlStateWithSuccess:(void (^)(int state))success failure:(void (^)(NSError *error))failure {
//    dispatch_async(self.processingQueue, ^{
//#warning broken
////        [self readCharacteristic:ASOTAUControlTransferCharacteristicUUID autoUpdate:NO success:^(ASBLEResult *result) {
////            if (success) {
////                int state = ((NSNumber *)result.value).intValue;
////                success(state);
////            }
////        } failure:^(NSError *error) {
////            if (failure) {
////                failure(error);
////            }
////        }];
//    });
//}
//
//- (void)readOTAUDataTransferWithSuccess:(void (^)(NSData *data))success failure:(void (^)(NSError *error))failure {
//    dispatch_async(self.processingQueue, ^{
//#warning broken
////        [self readCharacteristic:ASOTAUDataTransferCharacteristicUUID autoUpdate:NO success:^(ASBLEResult *result) {
////            if (success) {
////                success((NSData *)result.value);
////            }
////        } failure:^(NSError *error) {
////            if (failure) {
////                failure(error);
////            }
////        }];
//    });
//}

@end
