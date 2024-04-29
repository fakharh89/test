//
//  ASDevice+OTAU.m
//  Pods
//
//  Created by Michael Gordon on 11/3/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice+OTAU.h"

#import <objc/runtime.h>

#import "ASBLEInterface.h"
#import "ASBLEResult.h"
#import "ASConfig.h"
#import "ASDevicePrivate.h"
#import "ASLog.h"
#import "ASResourceManager.h"
#import "ASSystemManagerPrivate.h"
#import "ASErrorDefinitions.h"
#import "NSError+ASError.h"
#import "ASDateFormatter.h"

#import "ASOTAUApplicationService.h"

#import "ASOTAUCurrentAppCharacteristic.h"
#import "ASOTAUDataTransferCharacteristic.h"
#import "ASOTAUKeyBlockCharacteristic.h"
#import "ASOTAUVersionCharacteristic.h"

#import "ASOTAUBootService.h"
#import "ASOTAUKeyCharacteristic.h"
#import "ASOTAUControlTransferCharacteristic.h"

#import "ASApplicationImage.h"
#import "ASOTAUCache.h"
#import "ASDevice+OTAUCompatibility.h"
#import "ASOTAUInfo.h"

#import "ASDeviceManagerPrivate.h"

#import "NSString+ASHexString.h"
#import "NSData+ASHexString.h"

NSString * const ASOTAUOptionUserKeyKey = @"ASOTAUOptionUserKeyKey";
NSString * const ASOTAUOptionDefaultKey = @"ASOTAUOptionDefaultKey";
NSString * const ASOTAUStateLastUpdatedDateKey = @"OTAUStateDate";
NSString * const ASOTAUStateKey = @"OTAUState";

NSString * const ASOTAUOptionImagePathKey = @"9130c310-e3df-11e6-a9f9-406c8f530492";

// Must remain 32 characters long
static NSString * const BSOTAUDefaultUserKey = @"00000000000000000000000000000000";

@interface ASDevice (_OTAU)

@property (strong, readwrite, nonatomic, setter = setOTAUInfo:) ASOTAUInfo *OTAUInfo;

@end

@implementation ASDevice (_OTAU)

- (ASOTAUInfo *)OTAUInfo {
    return (ASOTAUInfo *)objc_getAssociatedObject(self, @selector(OTAUInfo));
}

- (void)setOTAUInfo:(ASOTAUInfo *)newOTAUInfo {
    objc_setAssociatedObject(self, @selector(OTAUInfo), newOTAUInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation ASDevice (OTAU)

- (BOOL)isUpdateAvailable {
    if ([self isInBootloaderMode]) {
        return YES;
    }
    
    return [self as_isUpdateAvailable];
}

- (BOOL)isInBootloaderMode {
    return (self.connectionMode == ASDeviceConnectionModeOverTheAirUpdate);
}

- (NSString *)latestAvailableUpdate {
    return [self as_latestAvailableUpdate];
}

- (void)startUpdateWithOptions:(NSDictionary *)options progress:(void (^)(ASOTAUProgressState state, float percentComplete))progress completion:(void (^)(NSError *error))completion {
    if (self.OTAUInfo) {
        if (completion) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorUpdateAlreadyInProgress underlyingError:nil];
            completion(error);
        }
        return;
    }
    
    self.OTAUInfo = [[ASOTAUInfo alloc] init];
    self.OTAUInfo.OTAUBlock = completion;
    self.OTAUInfo.progressBlock = progress;
    
    if (options) {
        id userKey = options[ASOTAUOptionUserKeyKey];
        if (userKey && [userKey isKindOfClass:[NSData class]]) {
            NSData *userKeyData = userKey;
            if (userKeyData.length == 16) {
                self.OTAUInfo.customUserKey = userKeyData;
            }
        }
        
        self.OTAUInfo.allowDefaultKey = [options[ASOTAUOptionDefaultKey] boolValue];
        
        id imagePath = options[ASOTAUOptionImagePathKey];
        if (imagePath && [imagePath isKindOfClass:[NSString class]]) {
            self.OTAUInfo.imagePath = imagePath;
        }
    }
    
    if (!self.OTAUInfo.imagePath) {
        if (![self isUpdateAvailable] && (self.connectionMode != ASDeviceConnectionModeOverTheAirUpdate)) {
            if (completion) {
                NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorNoUpdateAvailable underlyingError:nil];
                [self finishWithError:error];
            }
            return;
        }
        self.OTAUInfo.imagePath = [self as_imagePath];
    }
    
    if (!self.OTAUInfo.imagePath) {
        if (completion) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorInvalidDeviceType underlyingError:nil];
            [self finishWithError:error];
        }
        return;
    }
    
    if (self.connectionMode == ASDeviceConnectionModeOverTheAirUpdate) {
#warning check to make sure connected and characteristics are set up
        [self readOTAUVersionBootMode];
        return;
    }
    
    [self readOTAUVersion];
}

- (void)readOTAUVersion {
    [self updateProgressWithState:ASOTAUProgressStatePreparingBootMode step:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataTransferCharacteristicUpdated:) name:@"dataTransferCharacteristic" object:nil];
    
    NSString *serviceString = [ASOTAUApplicationService identifier];
    NSString *characteristicString = [ASOTAUVersionCharacteristic identifier];
    
    ASOTAUVersionCharacteristic *characteristic = (ASOTAUVersionCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];

    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic readWithCompletion:^(NSError *error) {
        if (error) {
            [self finishWithError:error];
            return;
        }
        
        ASBLEResult<NSNumber *> *result = characteristic.process;
        if (result.error) {
            [self finishWithError:result.error];
            return;
        }
        
        int version = result.value.intValue;
        
        if (version == 6) {
            [self setDataTransferNotify];
        }
        else {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorBootloaderVersionIncompatible underlyingError:nil];
            [self finishWithError:error];
        }
    }];
}

- (void)setDataTransferNotify {
    [self updateProgressWithState:ASOTAUProgressStatePreparingBootMode step:1];
    
    __block ASDevice *blockSafeSelf = self;
    
    NSString *serviceString = [ASOTAUApplicationService identifier];
    NSString *characteristicString = [ASOTAUDataTransferCharacteristic identifier];
    
    ASOTAUDataTransferCharacteristic *characteristic = (ASOTAUDataTransferCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic setNotify:YES withCompletion:^(NSError *error) {
        if (error) {
            [blockSafeSelf finishWithError:error];
            return;
        }
        
        [blockSafeSelf getBuildID];
    }];
}

- (void)getBuildID {
    [self updateProgressWithState:ASOTAUProgressStatePreparingBootMode step:2];
    
    uint32_t keyBlock = 0x20000;
    self.OTAUInfo.lastKeyRequestType = ASDeviceKeyRequestTypeBuildID;
    
    NSString *serviceString = [ASOTAUApplicationService identifier];
    NSString *characteristicString = [ASOTAUKeyBlockCharacteristic identifier];
    
    ASOTAUKeyBlockCharacteristic *characteristic = (ASOTAUKeyBlockCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic write:@(keyBlock) withCompletion:^(NSError *error) {
        if (error) {
            [self finishWithError:error];
            return;
        }
        // Do nothing now - we wait for the data transfer characteristic to update
    }];
}

- (void)dataTransferCharacteristicUpdated:(NSNotification *)notification {
    NSError *error = notification.userInfo[@"error"];
    if (error) {
        ASLog(@"Error with data transfer characteristic: %@", error);
        return;
    }
    
    NSString *serviceString = [ASOTAUApplicationService identifier];
    NSString *characteristicString = [ASOTAUDataTransferCharacteristic identifier];
    
    ASOTAUDataTransferCharacteristic *characteristic = (ASOTAUDataTransferCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    ASBLEResult<NSData *> *result = characteristic.process;
    NSData *data = result.value;
    
    switch (self.OTAUInfo.lastKeyRequestType) {
        case ASDeviceKeyRequestTypeBuildID: {
            uint16_t *build = (uint16_t *)[data bytes];
            NSString *peripheralBuildId = [NSString stringWithFormat:@"%d", *build];
            ASLog(@"Build ID: %@", peripheralBuildId);
            self.OTAUInfo.peripheralBuildID = peripheralBuildId;
            
            [self updateProgressWithState:ASOTAUProgressStatePreparingBootMode step:3];
            
            // Get MAC Address
            [self getKeyID:1 requestType:ASDeviceKeyRequestTypeMACAddress];
            break;
        }
        case ASDeviceKeyRequestTypeMACAddress: {
            Byte b[] = {0, 0, 0, 0, 0, 0};
            NSUInteger length = 6;
            if ( length > data.length ) {
                length = data.length;
            }
            for ( NSUInteger i = 0; ( i < length ); ++i ) {
                NSRange range = {length - i - 1, 1};
                [data getBytes:&b[i] range:range];
            }
            NSData *MACAddress = [NSData dataWithBytes:b length:length];
            self.OTAUInfo.MACAddress = MACAddress;
            ASLog(@"Read MAC Address: %@", MACAddress);
            
            [self updateProgressWithState:ASOTAUProgressStatePreparingBootMode step:4];
            
            // Get Crystal Trim
            [self getKeyID:2 requestType:ASDeviceKeyRequestTypeCrystalTrim];
            break;
        }
        case ASDeviceKeyRequestTypeCrystalTrim: {
            NSData *crystalTrim = data;
            self.OTAUInfo.crystalTrim = crystalTrim;
            ASLog(@"Crystal Trim: %@", crystalTrim);
            
            [self updateProgressWithState:ASOTAUProgressStatePreparingBootMode step:5];
            
            // Get User Key
            if (!self.OTAUInfo.userKey) {
                [self getKeyID:4 requestType:ASDeviceKeyRequestTypeUserKey];
            }
            else {
                [self setBootMode];
            }
            break;
        }
        case ASDeviceKeyRequestTypeUserKey: {
            NSData *userKey = data;
            self.OTAUInfo.userKey = data;
            ASLog(@"User Key: %@", userKey);
            
            [self updateProgressWithState:ASOTAUProgressStatePreparingBootMode step:6];
            
            [ASOTAUCache addMACAddress:self.OTAUInfo.MACAddress userKey:self.OTAUInfo.userKey];
            
            [self setBootMode];
            break;
        }
        default: {
            ASLog(@"Read unknown data: %@", data);
            break;
        }
    }
}

- (void)getKeyID:(int)keyID requestType:(ASDeviceKeyRequestType)requestType {
    NSDictionary *CSKeyEntry = nil;
    
    NSString *keyIdAsString = [NSString stringWithFormat:@"%d", keyID];
    NSArray *allBuilds = ASSystemManager.shared.resourceManager.CSKeyDatabase[@"PSKEY_DATABASE"][@"PSKEYS"];
    for (NSDictionary *build in allBuilds) {
        if ([build[@"BUILD_ID"] compare:self.OTAUInfo.peripheralBuildID] == NSOrderedSame) {
            NSArray *keysForThisBuild = build[@"PSKEY"];
            for (NSDictionary *CSKey in keysForThisBuild) {
                if ([CSKey[@"ID"] compare:keyIdAsString] == NSOrderedSame) {
                    CSKeyEntry = CSKey;
                }
                if (CSKeyEntry) {
                    break;
                }
            }
        }
        if (CSKeyEntry) {
            break;
        }
    }
    
    uint16_t offset = [CSKeyEntry[@"OFFSET"] intValue];
    uint16_t lenBytes = [CSKeyEntry[@"LENGTH"] intValue] * 2;
    
    NSMutableData *csCommand = [[NSMutableData alloc] init];
    [csCommand appendBytes:(void *)&offset length:sizeof(offset)];
    [csCommand appendBytes:(void *)&lenBytes length:sizeof(lenBytes)];
    
    uint32_t keyBlock;
    [csCommand getBytes:&keyBlock length:sizeof(keyBlock)];
    
    self.OTAUInfo.lastKeyRequestType = requestType;
    
    NSString *serviceString = [ASOTAUApplicationService identifier];
    NSString *characteristicString = [ASOTAUKeyBlockCharacteristic identifier];
    
    ASOTAUKeyBlockCharacteristic *characteristic = (ASOTAUKeyBlockCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic write:@(keyBlock) withCompletion:^(NSError *error) {
        if (error) {
            [self finishWithError:error];
            return;
        }
        // Do nothing now - we wait for the data transfer characteristic to update
    }];
}

- (void)setBootMode {
    [self updateProgressWithState:ASOTAUProgressStateBootingIntoOTAUMode step:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OTAUIsReadyCallback:) name:@"OTAUModeReady" object:nil];
    
    self.connectionMode = ASDeviceConnectionModeOverTheAirUpdate;
    [self saveStateInMeta:@"ConnectionModeOverTheAirUpdate"];
    self.OTAUInfo.shouldReconnect = YES;
    
    NSString *serviceString = [ASOTAUApplicationService identifier];
    NSString *characteristicString = [ASOTAUCurrentAppCharacteristic identifier];
    
    ASOTAUCurrentAppCharacteristic *characteristic = (ASOTAUCurrentAppCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic write:@(1) withCompletion:^(NSError *error) {
        if (error) {
            [self finishWithError:error];
            return;
        }
        [self updateProgressWithState:ASOTAUProgressStateBootingIntoOTAUMode step:1];
    }];
}

- (void)OTAUIsReadyCallback:(NSNotification *)notification {
    if (notification.object == self) {
        ASLog(@"Did connect!");
        [self updateProgressWithState:ASOTAUProgressStateBootingIntoOTAUMode step:2];
        [self readOTAUVersionBootMode];
    }
}

- (void)readOTAUVersionBootMode {
    [self updateProgressWithState:ASOTAUProgressStatePreparingImageWrite step:0];
    
    self.OTAUInfo.shouldReconnect = NO;
    
    NSString *serviceString = [ASOTAUBootService identifier];
    NSString *characteristicString = [ASOTAUVersionCharacteristic identifier];
    
    ASOTAUVersionCharacteristic *characteristic = (ASOTAUVersionCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic readWithCompletion:^(NSError *error) {
        if (error) {
            [self finishWithError:error];
            return;
        }
        
        ASBLEResult<NSNumber *> *result = characteristic.process;
        if (result.error) {
            [self finishWithError:result.error];
            return;
        }
        
        int version = result.value.intValue;
        
        if (version == 6) {
            [self getTransferControlState];
        }
        else {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorBootloaderVersionIncompatible underlyingError:nil];
            [self finishWithError:error];
        }
    }];
}

- (void)getTransferControlState {
    [self updateProgressWithState:ASOTAUProgressStatePreparingImageWrite step:1];
    
    NSString *serviceString = [ASOTAUBootService identifier];
    NSString *characteristicString = [ASOTAUControlTransferCharacteristic identifier];
    
    ASOTAUControlTransferCharacteristic *characteristic = (ASOTAUControlTransferCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic readWithCompletion:^(NSError *error) {
        if (error) {
            [self finishWithError:error];
            return;
        }
        
        ASBLEResult<NSNumber *> *result = [characteristic process];
        
        if (result.error) {
            [self finishWithError:error];
            return;
        }
        
        int state = result.value.intValue;
        
        if (state == 1) {
            [self getMACAddressBootMode];
        }
        else {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorBootloaderNotReady underlyingError:nil];
            [self finishWithError:error];
        }
    }];
}

- (void)getMACAddressBootMode {
    [self updateProgressWithState:ASOTAUProgressStatePreparingImageWrite step:2];
    
    if (self.OTAUInfo.MACAddress) {
        [self getCrystalTrimBootMode];
        return;
    }
    
    NSString *serviceString = [ASOTAUBootService identifier];
    NSString *characteristicString = [ASOTAUKeyCharacteristic identifier];
    
    ASOTAUKeyCharacteristic *characteristic = (ASOTAUKeyCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic write:@(1) withCompletion:^(NSError *error) {
        if (error) {
            [self finishWithError:error];
            return;
        }
        
        NSString *serviceString = [ASOTAUBootService identifier];
        NSString *characteristicString = [ASOTAUDataTransferCharacteristic identifier];
        
        ASOTAUDataTransferCharacteristic *characteristic = (ASOTAUDataTransferCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
        
        if (!characteristic) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
            [self finishWithError:error];
            return;
        }
        
        [characteristic readWithCompletion:^(NSError *error) {
            if (error) {
                [self finishWithError:error];
                return;
            }
            
            ASBLEResult<NSData *> *result = [characteristic process];
            
            if (result.error) {
                [self finishWithError:result.error];
                return;
            }
            
            NSData *data = result.value;
            
            Byte b[] = {0, 0, 0, 0, 0, 0};
            NSUInteger length = 6;
            if ( length > data.length ) {
                length = data.length;
            }
            for ( NSUInteger i = 0; ( i < length ); ++i ) {
                NSRange range = {length - i - 1, 1};
                [data getBytes:&b[i] range:range];
            }
            NSData *MACAddress = [NSData dataWithBytes:b length:length];
            self.OTAUInfo.MACAddress = MACAddress;
            ASLog(@"Read MAC Address: %@", MACAddress);
            
            [self getCrystalTrimBootMode];
        }];
    }];
}

- (void)getCrystalTrimBootMode {
    [self updateProgressWithState:ASOTAUProgressStatePreparingImageWrite step:3];
    
    if (self.OTAUInfo.crystalTrim) {
        [self getUserKeyBootMode];
        return;
    }
    
    NSString *serviceString = [ASOTAUBootService identifier];
    NSString *characteristicString = [ASOTAUKeyCharacteristic identifier];
    
    ASOTAUKeyCharacteristic *characteristic = (ASOTAUKeyCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic write:@(2) withCompletion:^(NSError *error) {
        if (error) {
            [self finishWithError:error];
            return;
        }
        
        NSString *serviceString = [ASOTAUBootService identifier];
        NSString *characteristicString = [ASOTAUDataTransferCharacteristic identifier];
        
        ASOTAUDataTransferCharacteristic *characteristic = (ASOTAUDataTransferCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
        
        if (!characteristic) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
            [self finishWithError:error];
            return;
        }
        
        [characteristic readWithCompletion:^(NSError *error) {
            if (error) {
                [self finishWithError:error];
                return;
            }
            
            ASBLEResult<NSData *> *result = [characteristic process];
            
            if (result.error) {
                [self finishWithError:result.error];
                return;
            }
            
            NSData *crystalTrim = result.value;
            self.OTAUInfo.crystalTrim = crystalTrim;
            ASLog(@"Crystal Trim: %@", crystalTrim);
            
            [self getUserKeyBootMode];
        }];
    }];
}

- (void)getUserKeyBootMode {
    [self updateProgressWithState:ASOTAUProgressStatePreparingImageWrite step:4];
    
    if (self.OTAUInfo.userKey) {
        [self setTransferControlNotify];
        return;
    }
    
    NSData *userKey = [ASOTAUCache userKeyForMACAddress:self.OTAUInfo.MACAddress];
    
    if (!userKey) {
        if (!self.OTAUInfo.allowDefaultKey) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorMissingUserKey underlyingError:nil];
            
            if (self.OTAUInfo.MACAddress) {
                NSString *string = [NSString as_hexStringWithData:[self.OTAUInfo.MACAddress subdataWithRange:NSMakeRange(3, 3)]];
                
                NSMutableDictionary *mutableUserInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
                [mutableUserInfo setValue:string forKey:@"MAC"];
                error = [NSError errorWithDomain:error.domain code:error.code userInfo:[NSDictionary dictionaryWithDictionary:mutableUserInfo]];
            }
            
            [self finishWithError:error];
            return;
        }
        else {
            userKey = [NSData as_dataWithHexString:BSOTAUDefaultUserKey];
        }
    }
    
    self.OTAUInfo.userKey = userKey;
    [self setTransferControlNotify];
}

- (void)setTransferControlNotify {
    [self updateProgressWithState:ASOTAUProgressStatePreparingImageWrite step:5];
    __block ASDevice *blockSafeSelf = self;
    
    NSString *serviceString = [ASOTAUBootService identifier];
    NSString *characteristicString = [ASOTAUControlTransferCharacteristic identifier];
    
    ASOTAUControlTransferCharacteristic *characteristic = (ASOTAUControlTransferCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic setNotify:YES withCompletion:^(NSError *error) {
        if (error) {
            [blockSafeSelf finishWithError:error];
            return;
        }
        
        [blockSafeSelf setApplicationImageWriteTarget];
    }];
}

- (void)setApplicationImageWriteTarget {
    [self updateProgressWithState:ASOTAUProgressStatePreparingImageWrite step:6];
    
    NSString *serviceString = [ASOTAUBootService identifier];
    NSString *characteristicString = [ASOTAUCurrentAppCharacteristic identifier];
    
    ASOTAUCurrentAppCharacteristic *characteristic = (ASOTAUCurrentAppCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic write:@(1) withCompletion:^(NSError *error) {
        if (error) {
            //            [self finishWithError:error];
            //            return;
            ASLog(@"Writing current app characteristic failed.  Proceeding anyways!");
        }
        [self prepareToWriteImage];
    }];
}

- (void)prepareToWriteImage {
    [self updateProgressWithState:ASOTAUProgressStatePreparingImageWrite step:7];
    
    NSString *serviceString = [ASOTAUBootService identifier];
    NSString *characteristicString = [ASOTAUControlTransferCharacteristic identifier];
    
    ASOTAUControlTransferCharacteristic *characteristic = (ASOTAUControlTransferCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic write:@(2) withCompletion:^(NSError *error) {
        if (error) {
            [self finishWithError:error];
            return;
        }
        
        [self prepareImage];
    }];
}

#warning do this before we boot into boot mode
- (void)prepareImage {
    [self updateProgressWithState:ASOTAUProgressStatePreparingImageWrite step:8];
    
    ASApplicationImage *image = [[ASApplicationImage alloc] initWithImagePath:self.OTAUInfo.imagePath];
    
    [image updateUserKeys:self.OTAUInfo.userKey];
    [image updateMACAddress:self.OTAUInfo.MACAddress];
    [image updateCrystalTrim:self.OTAUInfo.crystalTrim];
    
    NSData *imageData = [image applicationImageData];
    
    if (!imageData) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorApplicationImageInvalid underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [self writeImage:imageData];
}

- (void)writeImage:(NSData *)image {
    [self updateProgressWithState:ASOTAUProgressStateWritingImage step:0 numberOfSteps:1];
    
    const uint8_t packetWriteSize = 20;
    
    dispatch_async(self.processingQueue, ^{
        [self writeImageData:image index:0 maxLength:packetWriteSize];
    });
}

- (void)writeImageData:(NSData *)image index:(NSUInteger)index maxLength:(uint8_t)packetWriteSize {
    [self updateProgressWithState:ASOTAUProgressStateWritingImage step:(int)index numberOfSteps:(int)[image length]];
    
    NSUInteger size = [image length];
    
    if (index >= size) {
        [self completeImageWrite];
        return;
    }
    
    NSUInteger lengthToWrite;
    
    if ((size - index) < packetWriteSize) {
        lengthToWrite = size - index;
    }
    else {
        lengthToWrite = packetWriteSize;
    }
    
    NSData *imageChunk = [image subdataWithRange:NSMakeRange(index, lengthToWrite)];
    
    NSString *serviceString = [ASOTAUBootService identifier];
    NSString *characteristicString = [ASOTAUDataTransferCharacteristic identifier];
    
    ASOTAUDataTransferCharacteristic *characteristic = (ASOTAUDataTransferCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic write:imageChunk withCompletion:^(NSError *error) {
        if (error) {
            [self finishWithError:error];
            return;
        }
        NSUInteger nextIndex = index + lengthToWrite;
        dispatch_async(self.processingQueue, ^{
            [self writeImageData:image index:nextIndex maxLength:packetWriteSize];
        });
    }];
}

- (void)completeImageWrite {
    [self updateProgressWithState:ASOTAUProgressStateBootingIntoApplicationMode step:0];
    
    NSString *serviceString = [ASOTAUBootService identifier];
    NSString *characteristicString = [ASOTAUControlTransferCharacteristic identifier];
    
    ASOTAUControlTransferCharacteristic *characteristic = (ASOTAUControlTransferCharacteristic *)self.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    if (!characteristic) {
        NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
        [self finishWithError:error];
        return;
    }
    
    [characteristic write:@(4) withCompletion:^(NSError *error) {
        if (error) {
            [self finishWithError:error];
            return;
        }
        
        self.connectionMode = ASDeviceConnectionModeDefault;
        [self saveStateInMeta:@"ConnectionModeDefault"];
        
#warning check on reconnect
        [self finishWithError:nil];
    }];
}

- (BOOL)shouldReconnect {
    return self.OTAUInfo.shouldReconnect;
}

- (void)finishWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dataTransferCharacteristic" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OTAUModeReady" object:nil];
    
    if (!error) {
        [ASOTAUCache deleteUserKeyForMACAddress:self.OTAUInfo.MACAddress];
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        
        NSMutableDictionary *mutableDictionary = nil;
        
        if (self.metadata) {
            mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:self.metadata];
        }
        else {
            mutableDictionary = [[NSMutableDictionary alloc] init];
        }
        
        [mutableDictionary setObject:dateString forKey:@"OTAUDate"];
        self.metadata = [NSDictionary dictionaryWithDictionary:mutableDictionary];
        
        if ([[ASSystemManager shared].deviceManager.stuckDevices containsObject:self]) {
            [[ASSystemManager shared].deviceManager removeStuckDevice:self];
            [self setAutoConnect:NO error:nil];
        }
    }
    
    OTAUCompletionBlock block = self.OTAUInfo.OTAUBlock;
    self.OTAUInfo = nil;
    
    if (block) {
        dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
            block(error);
        });
    }
}

- (void)updateProgressWithState:(ASOTAUProgressState)state step:(int)step {
    int numSteps = 1; // Don't define as zero to avoid divide by 0
    NSString *stateString;
    switch (state) {
        case ASOTAUProgressStatePreparingBootMode:
            numSteps = 6;
            stateString = @"PreparingBootMode";
            break;
        case ASOTAUProgressStateBootingIntoOTAUMode:
            numSteps = 2;
            stateString = @"BootingIntoOTAUMode";
            break;
        case ASOTAUProgressStatePreparingImageWrite:
            numSteps = 8;
            stateString = @"PreparingImageWrite";
            break;
        case ASOTAUProgressStateWritingImage:
            NSAssert(NO, @"Need to call other function");
            numSteps = 20000;
            stateString = @"WritingImage";
            break;
        case ASOTAUProgressStateBootingIntoApplicationMode:
            numSteps = 1;
            stateString = @"BootingIntoApplicationMode";
            break;
        case ASOTAUProgressStateCheckingOTAU:
            numSteps = 1;
            stateString = @"CheckingOTAU";
            break;
        default:
            break;
    }
    [self saveStateInMeta:stateString];
    [self updateProgressWithState:state step:step numberOfSteps:numSteps];
}

- (void)updateProgressWithState:(ASOTAUProgressState)state step:(int)step numberOfSteps:(int)numberOfSteps {
    if (!self.OTAUInfo.progressBlock) {
        return;
    }
    
    ProgressBlock block = self.OTAUInfo.progressBlock;
    
    float progress = ((float) step) / ((float) numberOfSteps);
    
    dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
        block(state, progress);
    });
}

- (void)saveStateInMeta:(NSString *)state {
    ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
    NSString *currentDateString = [formatter stringFromDate:[NSDate date]];
    NSMutableDictionary *metadata = [self.metadata mutableCopy];
    metadata[ASOTAUStateLastUpdatedDateKey] = currentDateString;
    metadata[ASOTAUStateKey] = state;
    self.metadata = metadata;
}

@end
