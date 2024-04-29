//
//  ASDevice+ASDevice_OTAUCompatibility.m
//  Pods
//
//  Created by Michael Gordon on 1/25/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice+OTAUCompatibility.h"

#import "ASDevicePrivate.h"
#import "ASResourceManager.h"
#import "ASSystemManagerPrivate.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString * const ASOTAUDeviceNameTKL = @"tkl";
NSString * const ASOTAUDeviceNameTaylor = @"taylor";
NSString * const ASOTAUDeviceNameDAddario = @"humiditrak";
NSString * const ASOTAUDeviceNameBlustream = @"blustream";
NSString * const ASOTAUDeviceNameBoveda = @"boveda";

@implementation ASDevice (OTAUCompatibility)

- (BOOL)as_isUpdateAvailable {
    NSString *latestAvailableUpdate = [self as_latestAvailableUpdate];
    NSString *currentVersion = self.softwareRevision;
    
    if (!latestAvailableUpdate || !currentVersion) {
        return NO;
    }
    
    if ([currentVersion compare:latestAvailableUpdate options:NSNumericSearch] == NSOrderedAscending) {
        return YES;
    }
    
    return NO;
}

- (NSString *)as_imagePath {
    NSString *typeString = [self as_deviceTypeString];
    
    if (!typeString) {
        typeString = [self as_deviceTypeStringFromBootName];
    }
    
    if (!typeString) {
        return nil;
    }
    
    NSString *latestAvailableUpdate = [self as_latestAvailableUpdate];
    
    if (!latestAvailableUpdate) {
        return nil;
    }
    
    NSString *imageSuffix = [NSString stringWithFormat:@"%@-%@.img", typeString, latestAvailableUpdate];
    
    NSArray *imagePaths = ASSystemManager.shared.resourceManager.imagePaths;
    NSString *imagePath = nil;
    
    for (NSString *path in imagePaths) {
        if ([path.lowercaseString hasSuffix:imageSuffix.lowercaseString]) {
            imagePath = path;
            break;
        }
    }
    
    return imagePath;
}

- (NSString *)as_latestAvailableUpdate {
    NSString *typeString = [self as_deviceTypeString];
    
    if (!typeString) {
        typeString = [self as_deviceTypeStringFromBootName];
    }
    
    if (!typeString) {
        return nil;
    }
    
    NSArray<NSDictionary *> *imageDictionaries = ASSystemManager.shared.resourceManager.OTAUImageDatabase[@"images"];
    
    if (!imageDictionaries) {
        return nil;
    }
    
    NSDictionary *imageDictionary = nil;
    
    for (NSDictionary *dict in imageDictionaries) {
        if ([typeString compare:dict[@"type"]] == NSOrderedSame) {
            imageDictionary = dict;
            break;
        }
    }
    
    if (!imageDictionary) {
        return nil;
    }
    
    // Use URL here when ready
    
    return imageDictionary[@"version"];
}

- (NSString *)as_deviceTypeString {
    NSString *typeString = nil;
    
    switch (self.type) {
        case ASDeviceTypeTKL:
            typeString = ASOTAUDeviceNameTKL;
            break;
            
        case ASDeviceTypeTaylor:
            typeString = ASOTAUDeviceNameTaylor;
            break;
            
        case ASDeviceTypeDAddario:
            typeString = ASOTAUDeviceNameDAddario;
            break;
            
        case ASDeviceTypeBlustream:
            typeString = ASOTAUDeviceNameBlustream;
            break;
            
        case ASDeviceTypeBoveda:
            typeString = ASOTAUDeviceNameBoveda;
            break;
            
        default:
            break;
    };
    
    return typeString;
}

- (NSString *)as_deviceTypeStringFromBootName {
    NSString *typeString = nil;
    NSString *peripheralName = self.peripheral.name;
    
    if ([@"DA-OTA" caseInsensitiveCompare:peripheralName] == NSOrderedSame
        || [@"Humiditrak" caseInsensitiveCompare:peripheralName] == NSOrderedSame
        || [@"Humiditrak-OTA" caseInsensitiveCompare:peripheralName] == NSOrderedSame
        || [@"AS-D'Addario" caseInsensitiveCompare:peripheralName] == NSOrderedSame) {
        typeString = ASOTAUDeviceNameDAddario;
    }
    else if ([@"SafeNSound-OTA" caseInsensitiveCompare:peripheralName] == NSOrderedSame
             || [@"Safe&Sound" caseInsensitiveCompare:peripheralName] == NSOrderedSame) {
        typeString = ASOTAUDeviceNameTKL;
    }
    
    return typeString;
}

@end
