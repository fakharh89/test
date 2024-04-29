//
//  ASTimeSyncCharacteristic.m
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASTimeSyncCharacteristic.h"

#import "ASBLEDefinitions.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "NSError+ASError.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ASTimeSyncCharacteristic ()

@property (copy, readwrite, nonatomic) void (^writeCompletion)(NSError *error);

@end

@implementation ASTimeSyncCharacteristic

#pragma mark - ASCharacteristic Methods

+ (NSString *)identifier {
    return ASTimeSyncCharactUUID;
}

- (void)didDisconnectWithError:(NSError *)error {
    [self didCompleteWriteWithError:error];
}

#pragma mark - ASWriteableCharacteristic Methods

- (void)write:(NSDate *)date withCompletion:(void (^)(NSError *error))completion {
    if (self.writeCompletion) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorAlreadyPending underlyingError:nil];
        completion(error);
        return;
    }
    
    // Only do this if hardware version is 2.0.0 or above
    if ([@"2.0.0" compare:self.device.softwareRevision options:NSNumericSearch] == NSOrderedDescending) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceWriteErrorDomain code:ASDeviceWriteErrorVersionUnsupported underlyingError:nil];
        
        if (completion) {
            completion(error);
        }
        return;
    }
    
    self.writeCompletion = completion;
    
    NSTimeInterval interval = [date timeIntervalSince1970];
    uint64_t intervalMillisBase1024 = round(interval * 1000.0 * 1000.0 / 1024.0);
    NSData *rawData = [NSData dataWithBytes:&intervalMillisBase1024 length:sizeof(intervalMillisBase1024)];
    
    //    fixedData = [[self reverseData:data] subdataWithRange:NSMakeRange(2, 6)];
    //
    //    NSMutableData *mData = [[NSMutableData alloc] init];
    //    [mData appendData:[fixedData subdataWithRange:NSMakeRange(4, 2)]];
    //    [mData appendData:[fixedData subdataWithRange:NSMakeRange(2, 2)]];
    //    [mData appendData:[fixedData subdataWithRange:NSMakeRange(0, 2)]];
    //
    //    fixedData = [NSData dataWithData:mData];
    
    NSData *fixedData = [rawData subdataWithRange:NSMakeRange(0, 6)];
    
    [self.device.peripheral writeValue:fixedData forCharacteristic:self.internalCharacteristic type:CBCharacteristicWriteWithResponse];
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
