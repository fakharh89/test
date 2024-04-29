//
//  ASOTAUCache.h
//  Pods
//
//  Created by Michael Gordon on 1/25/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@interface ASOTAUCache : NSObject

+ (BOOL)addMACAddress:(NSData *)MACAddress userKey:(NSData *)userKey;
+ (BOOL)addMACAddressesAndKeysFromURL:(NSURL *)url;
+ (NSData *)userKeyForMACAddress:(NSData *)MACAddress;
+ (BOOL)deleteUserKeyForMACAddress:(NSData *)MACAddress;

@end
