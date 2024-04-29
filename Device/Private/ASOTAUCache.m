//
//  ASOTAUCache.m
//  Pods
//
//  Created by Michael Gordon on 1/25/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASOTAUCache.h"

#import "ASSystemManagerPrivate.h"
#import "ASLog.h"
#import "NSData+ASHexString.h"

#define ASOTAUCacheQueryField @"otau"

dispatch_queue_t OTAU_cache_queue() {
    static dispatch_queue_t as_OTAU_cache_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        as_OTAU_cache_queue = dispatch_queue_create("com.acoustic-stream.otau-cache", DISPATCH_QUEUE_SERIAL);
    });
    return as_OTAU_cache_queue;
}

@implementation ASOTAUCache

+ (BOOL)addMACAddress:(NSData *)MACAddress userKey:(NSData *)userKey {
    NSParameterAssert(MACAddress);
    NSParameterAssert(userKey);
    
    NSDictionary *existingKeys = [self loadKeys];
    NSMutableDictionary *newMutableKeys = [[NSMutableDictionary alloc] initWithDictionary:existingKeys];
    [newMutableKeys addEntriesFromDictionary:@{MACAddress : userKey}];
    
    NSDictionary *newKeys = [[NSDictionary alloc] initWithDictionary:newMutableKeys];
    
    return [self saveKeys:newKeys];
}

+ (BOOL)addMACAddressesAndKeysFromURL:(NSURL *)url {
    NSParameterAssert(url);
    
    NSArray *queryComponents = [[url query] componentsSeparatedByString:@"&"];
    
    NSString *base64EncodedPairsString = nil;
    
    for (NSString *component in queryComponents) {
        NSArray *pairComponents = [component componentsSeparatedByString:@"="];
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        if (key && value
            && ([key compare:ASOTAUCacheQueryField] == NSOrderedSame)) {
            base64EncodedPairsString = value;
            break;
        }
    }
    
    if (!base64EncodedPairsString) {
        return NO;
    }
    
    NSData *pairsStringData = [[NSData alloc] initWithBase64EncodedString:base64EncodedPairsString options:0];
    
    NSString *pairsString = [[NSString alloc] initWithData:pairsStringData encoding:NSUTF8StringEncoding];
    
    NSArray *pairComponents = [pairsString componentsSeparatedByString:@"\n"];

    if (!pairComponents || (pairComponents.count == 0)) {
        return NO;
    }
    
    BOOL added = NO;
    
    for (NSString *pair in pairComponents) {
        NSArray *pairComponents = [pair componentsSeparatedByString:@","];
        NSString *serialNumber = pairComponents.firstObject;
        NSString *userKey = pairComponents.lastObject;
        
        // Fill serialNumber with 0's
        // Convert to NSData
        
        ASLog(@"%lu", (unsigned long)userKey.length);
        ASLog(@"%lu", (unsigned long)serialNumber.length);
        
        if (!serialNumber || !userKey) {
            continue;
        }
        
        if ((serialNumber.length == 0) || (serialNumber.length > 6)) {
            continue;
        }
        
        if (userKey.length == 37) {
            userKey = [userKey substringToIndex:(userKey.length - 1)];
        }
        
        if (userKey.length != 36) {
            continue;
        }
        
        NSString *userKeyString = [userKey stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        if (userKeyString.length != 32) {
            continue;
        }
        
        NSRange typeRange = NSMakeRange(0, serialNumber.length - 2);
        NSString *serialNumberWithoutType = [serialNumber substringWithRange:typeRange];
        NSRange MACRange = NSMakeRange(12 - serialNumberWithoutType.length, serialNumberWithoutType.length);
        NSString *MACAddressString = [@"0c1a10000000" stringByReplacingCharactersInRange:MACRange withString:serialNumberWithoutType];
        
        NSData *serialNumberData = [NSData as_dataWithHexString:MACAddressString];
        NSData *userKeyData = [NSData as_dataWithHexString:userKeyString];
        
        [self addMACAddress:serialNumberData userKey:userKeyData];
        added = YES;
#warning need to save device type
    }
    
    return added;
}

+ (NSData *)userKeyForMACAddress:(NSData *)MACAddress {
    NSParameterAssert(MACAddress);
    
    NSDictionary *existingKeys = [self loadKeys];
    return existingKeys[MACAddress];
}

+ (BOOL)deleteUserKeyForMACAddress:(NSData *)MACAddress {
    NSParameterAssert(MACAddress);
    
    NSDictionary *existingKeys = [self loadKeys];
    NSMutableDictionary *newMutableKeys = [[NSMutableDictionary alloc] initWithDictionary:existingKeys];
    [newMutableKeys removeObjectForKey:MACAddress];
    
    NSDictionary *newKeys = [[NSDictionary alloc] initWithDictionary:newMutableKeys];
    
    return [self saveKeys:newKeys];
}

+ (NSDictionary *)loadKeys {
    __block NSDictionary *keys;
    dispatch_sync(OTAU_cache_queue(), ^{
        keys = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getDataPath]];
        if (!keys) {
            keys = @{};
        }
    });
    return keys;
}

+ (BOOL)saveKeys:(NSDictionary *)keys {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:keys];
    
    __block BOOL success;
    dispatch_sync(OTAU_cache_queue(), ^{
        success = [data writeToFile:[self getDataPath] atomically:YES];
        
        if (success) {
            // Set folder to not backup to iCloud.  Writing erases this attribute
            [ASSystemManager addSkipBackupAttributeToItemAtPath:[self getDataPath]];
        }
    });
    return success;
}

// Returns save path for data as an NSString
+ (NSString *)getDataPath {
    NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
    NSString *filename = [docsPath stringByAppendingPathComponent:@"OTAUCache"];
    return filename;
}

@end
