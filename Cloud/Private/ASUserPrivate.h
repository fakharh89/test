//
//  ASUser.h
//  Blustream
//
//  Created by Michael Gordon on 3/16/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASUser.h"

@class AFOAuthCredential;

@interface ASUser () <NSCoding>

@property (nonatomic, strong, readwrite) AFOAuthCredential *credential;
@property (nonatomic, strong, readwrite) NSDate *lastSynced;
@property (nonatomic, strong, readwrite) NSDate *creationDate;
@property (nonatomic, strong, readwrite) NSString *imageURL;
@property (nonatomic, strong, readwrite) NSDate *imageLastSynced;
@property (nonatomic, strong, readwrite) NSDictionary *fullMetadata;
@property (nonatomic, copy, readwrite) NSString *usernameWithTag;
@property (nonatomic, strong, readwrite) NSDictionary<NSString *, NSString *> *externalTokens;
@property (nonatomic, strong, readwrite) NSDate *logginExpirationDate;
@property (nonatomic, assign) BOOL isSyncingImage;
@property (nonatomic, assign) BOOL isSyncing;

+ (BOOL)clearCredentials;
- (void)unsafeSetImage:(UIImage *)image;

@end
