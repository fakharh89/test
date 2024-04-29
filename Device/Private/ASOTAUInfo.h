//
//  ASOTAUInfo.h
//  Pods
//
//  Created by Michael Gordon on 1/26/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

typedef void (^OTAUCompletionBlock)(NSError *error);
typedef void (^ProgressBlock)(NSInteger state, float percentComplete);

typedef NS_ENUM(NSInteger, ASDeviceKeyRequestType) {
    ASDeviceKeyRequestTypeUnknown,
    ASDeviceKeyRequestTypeBuildID,
    ASDeviceKeyRequestTypeMACAddress,
    ASDeviceKeyRequestTypeCrystalTrim,
    ASDeviceKeyRequestTypeUserKey
};

@interface ASOTAUInfo : NSObject

@property (copy, readwrite, nonatomic) OTAUCompletionBlock OTAUBlock;
@property (copy, readwrite, nonatomic) ProgressBlock progressBlock;
@property (assign, readwrite, nonatomic) ASDeviceKeyRequestType lastKeyRequestType;
@property (strong, readwrite, nonatomic) NSString *peripheralBuildID;
@property (assign, readwrite, nonatomic) BOOL shouldReconnect;
@property (strong, readwrite, nonatomic) NSData *MACAddress;
@property (strong, readwrite, nonatomic) NSData *crystalTrim;
@property (strong, readwrite, nonatomic) NSData *userKey;
@property (strong, readwrite, nonatomic) NSString *imagePath;
@property (strong, readwrite, nonatomic) NSData *customUserKey;
@property (strong, readwrite, nonatomic) NSString *customImagePath;
@property (assign, readwrite, nonatomic) BOOL allowDefaultKey;

@end
