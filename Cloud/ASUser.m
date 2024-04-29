//
//  ASUser.m
//  Blustream
//
//  Created by Michael Gordon on 3/16/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASUserPrivate.h"

#import "AFOAuth2Manager.h"
#import "ASConfig.h"
#import "ASLog.h"
#import "ASSystemManagerPrivate.h"
#import "NSDate+ASRoundDate.h"

@implementation ASUser

#pragma mark - NSCoding

#define kUsernameWithTag @"UsernameWithTag"
#define kFirstName       @"FirstName"
#define kLastName        @"LastName"
#define kImage           @"UserImage"      // doesn't match because was swapped from userImage to image
#define kCreationDate    @"CreationDate"
#define kLastSynced      @"LastSynced"
#define kMetadata        @"Metadata"
#define kASAuthCred      @"ASAuthCred"
#define kImageLastSynced @"ImageLastSynced"
#define kImageURL        @"ImageURL"
#define kExternalTokens  @"ExternalTokens"
#define kLogginExpirationDate @"LogginExpirationDate"
#define kOptIn           @"OptIn"
#define kMessagesCache   @"MessagesCache"


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.usernameWithTag forKey:kUsernameWithTag];
    [encoder encodeObject:self.firstName forKey:kFirstName];
    [encoder encodeObject:self.lastName forKey:kLastName];
    [encoder encodeObject:UIImagePNGRepresentation(self.image) forKey:kImage];
    [encoder encodeObject:self.creationDate forKey:kCreationDate];
    [encoder encodeObject:self.lastSynced forKey:kLastSynced];
    [encoder encodeObject:self.fullMetadata forKey:kMetadata];
    [encoder encodeObject:self.imageLastSynced forKey:kImageLastSynced];
    [encoder encodeObject:self.imageURL forKey:kImageURL];
    [encoder encodeObject:self.externalTokens forKey:kExternalTokens];
    [encoder encodeObject:self.logginExpirationDate forKey:kLogginExpirationDate];
    [encoder encodeObject:@(self.optIn) forKey:kOptIn];
    [encoder encodeObject:self.messagesCache forKey:kMessagesCache];
    
    id securityAccessibility = nil;
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 43000) || (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090)
    if ((&kSecAttrAccessibleWhenUnlocked) != NULL) {
        securityAccessibility = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    }
#endif
    
    [AFOAuthCredential storeCredential:self.credential withIdentifier:kASAuthCred withAccessibility:securityAccessibility];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        ASLog(@"Restoring local user");
        _usernameWithTag = [decoder decodeObjectForKey:kUsernameWithTag];
        _firstName = [decoder decodeObjectForKey:kFirstName];
        _lastName = [decoder decodeObjectForKey:kLastName];
        _image = [UIImage imageWithData:[decoder decodeObjectForKey:kImage]];
        _creationDate = [decoder decodeObjectForKey:kCreationDate];
        _lastSynced = [decoder decodeObjectForKey:kLastSynced];
        _fullMetadata = [decoder decodeObjectForKey:kMetadata];
        _imageLastSynced = [decoder decodeObjectForKey:kImageLastSynced];
        _imageURL = [decoder decodeObjectForKey:kImageURL];
        _externalTokens = [decoder decodeObjectForKey:kExternalTokens];
        _logginExpirationDate = [decoder decodeObjectForKey:kLogginExpirationDate];
        _optIn = [[decoder decodeObjectForKey:kOptIn] boolValue];
        _messagesCache = [decoder decodeObjectForKey:kMessagesCache];
        
        // Cocoapods packager mangles AFOAuthCredential into PodAS_iOS_Framework_AFOAuthCredential
        @try {
            _credential = [AFOAuthCredential retrieveCredentialWithIdentifier:kASAuthCred];
        }
        @catch (NSException *exception) {
            _credential = nil;
        }
    }
    
    return self;
}

+ (BOOL)clearCredentials {
    return [AFOAuthCredential deleteCredentialWithIdentifier:kASAuthCred];
}

- (void)setFirstName:(NSString *)firstName {
    _firstName = firstName;
    self.lastSynced = [[NSDate date] as_roundMillisecondsToThousands];
}

- (void)setLastName:(NSString *)lastName {
    _lastName = lastName;
    self.lastSynced = [[NSDate date] as_roundMillisecondsToThousands];
}

- (void)setImage:(UIImage *)image {
    [self unsafeSetImage:image];
    self.imageLastSynced = [[NSDate date] as_roundMillisecondsToThousands];
}

- (void)setOptIn:(BOOL)optIn {
    _optIn = optIn;
    self.lastSynced = [[NSDate date] as_roundMillisecondsToThousands];
}

- (void)unsafeSetImage:(UIImage *)image {
    _image = [image copy];
    // TODO set up image saving system from ASContainer
}

- (NSDictionary *)metadata {
    NSDictionary *metadata = _fullMetadata[[NSBundle mainBundle].bundleIdentifier];
    
    if ([metadata isKindOfClass:[NSNull class]]) {
        metadata = nil;
    }
    
    return metadata;
}

- (void)setMetadata:(NSDictionary *)metadata {
    NSMutableDictionary *mutableFullMetadata = [NSMutableDictionary dictionaryWithDictionary:_fullMetadata];
    [mutableFullMetadata setObject:(metadata ? [metadata copy] : [NSNull null]) forKey:[NSBundle mainBundle].bundleIdentifier];
    _fullMetadata = [NSDictionary dictionaryWithDictionary:mutableFullMetadata];
    
    self.lastSynced = [[NSDate date] as_roundMillisecondsToThousands];
}

- (NSString *)username {
    NSString *tag = ASSystemManager.shared.config.accountTag;
    NSRange range = [self.usernameWithTag rangeOfString:tag options:NSBackwardsSearch];
    NSString *username = @"";
    if (range.location != NSNotFound) {
        username = [self.usernameWithTag substringToIndex:range.location];
    }
    else {
        username = self.usernameWithTag;
    }
    
    return username;
}

- (NSString *)token {
    return self.credential.accessToken;
}

@end

