//
//  ASApplicationImage.h
//  Pods
//
//  Created by Michael Gordon on 1/22/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@interface ASApplicationImage : NSObject

- (instancetype)initWithImagePath:(NSString *)imagePath;

- (void)updateCrystalTrim:(NSData *)crystalTrim;
- (void)updateMACAddress:(NSData *)MACAddress;
- (void)updateIdentityRoot:(NSData *)identityRoot;
- (void)updateEncryptionRoot:(NSData *)encryptionRoot;
- (void)updateUserKeys:(NSData *)userKeys;

- (NSData *)applicationImageData;

@end
