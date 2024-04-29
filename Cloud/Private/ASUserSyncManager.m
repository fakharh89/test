//
//  ASSyncUserManager.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 12/28/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASUserSyncManager.h"

#import "ASSystemManager.h"
#import "ASUserPrivate.h"
#import "ASUserAPIService.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASCloudPrivate.h"
#import "ASContainer.h"
#import "ASContainerManagerPrivate.h"
#import "ASDeviceManagerPrivate.h"
#import "ASDateFormatter.h"
#import "ASUtils.h"
#import "NSDictionary+ASStringToJSON.h"

#import "ASErrorDefinitions.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

@interface ASUserSyncManager()

@property (nonatomic, strong) ASUser *user;
@property (nonatomic, strong) ASUserAPIService *apiService;
@property (nonatomic, weak) ASSystemManager *systemManager;

@end

@implementation ASUserSyncManager

- (instancetype)initWithUser:(ASUser *)user systemManager:(ASSystemManager *)systemManager apiService:(ASUserAPIService *)apiService {
    self = [super init];
    
    if (self) {
        _user = user;
        _systemManager = systemManager;
        _apiService = apiService;
    }
    
    return self;
}

- (void)synchronizeWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    
    if (self.user.isSyncing) {
        NSError *error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:    ASCloudErrorSyncingAlreadyInProgress underlyingError:nil];
        
        if (failure) {
            failure(error);
        }
        return;
    }
    
    self.user.isSyncing = YES;
    
    [self.apiService getUserDataWithSuccess:^(NSDictionary *userDictionary) {
        if ([self syncUserFromDictionary:userDictionary]) {
            ASLog(@"Synced user");
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASUserSyncedNotification object:nil];
        }
        else {
            ASLog(@"User info didn't change");
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASUserSyncedNoChangeNotification object:nil];
        }
        
        [self syncUserImageFromDictionary:userDictionary];
        [self.systemManager.cloud saveUser];
       
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        self.user.isSyncing = NO;
        if (error) {
            [self.systemManager.cloud handleUserLogoutWithError:error];
        }
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - User data

- (BOOL)syncUserFromDictionary:(NSDictionary *)dictionary {
    BOOL changed = NO;
    
    // Check to make sure identifier is correct
    if ([((NSString *) dictionary[@"username"]) caseInsensitiveCompare:self.user.usernameWithTag] != NSOrderedSame) {
        self.user.isSyncing = NO;
        return NO;
    }
    
    // Creation Date
    NSString *createdString = dictionary[@"created"];
    if ([createdString isKindOfClass:[NSNull class]]) {
        createdString = nil;
    }
    
    NSDate *creationDate = nil;
    if (createdString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        creationDate = [formatter dateFromString:createdString];
    }
    
    if (creationDate) {
        self.user.creationDate = creationDate;
    }
    
    // Last Sync Date
    NSString *serverLastSyncedString = dictionary[@"lastModified"];
    if ([serverLastSyncedString isKindOfClass:[NSNull class]]) {
        serverLastSyncedString = nil;
    }
    
    NSDate *serverLastSynced = nil;
    if (serverLastSyncedString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        serverLastSynced = [formatter dateFromString:serverLastSyncedString];
    }
    
    if ([self isUserDataEqualToDictionary:dictionary]) {
        changed = NO;
        self.user.lastSynced = serverLastSynced;
        self.user.isSyncing = NO;
    }
    else {
        // if no local sync or server is newer
        if (!self.user.lastSynced || !serverLastSynced || ([self.user.lastSynced timeIntervalSinceDate:serverLastSynced] <= 0)) {
            // Update local from server
            changed = YES;
            [self updateFromDictionary:dictionary];
            self.user.isSyncing = NO;
        }
        else {
            // Post local to server
            [self.apiService postWithSuccess:^(NSDate *lastSynced) {
                self.user.lastSynced = lastSynced;
                self.user.isSyncing = NO;
            } failure:^(NSError *error) {
                self.user.isSyncing = NO;
                if (error) {
                    [self.systemManager.cloud handleUserLogoutWithError:error];
                }
            }];
        }
    }
    
    return changed;
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    // Last Sync Date
    NSString *newLastSyncedString = dictionary[@"lastModified"];
    if ([newLastSyncedString isKindOfClass:[NSNull class]]) {
        newLastSyncedString = nil;
    }
    
    NSDate *newLastSynced = nil;
    if (newLastSyncedString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        newLastSynced = [formatter dateFromString:newLastSyncedString];
    }
    self.user.lastSynced = newLastSynced;
    
    // First Name
    NSString *newFirstName = dictionary[@"givenName"];
    if ([newFirstName isKindOfClass:[NSNull class]]) {
        newFirstName = nil;
    }
    self.user.firstName = newFirstName;
    
    // Last Name
    NSString *newLastName = dictionary[@"surname"];
    if ([newLastName isKindOfClass:[NSNull class]]) {
        newLastName = nil;
    }
    self.user.lastName = newLastName;
    
    // Metadata
    NSString *newMetadataString = dictionary[@"contents"];
    if ([newMetadataString isKindOfClass:[NSNull class]]) {
        newMetadataString = nil;
    }
    
    NSDictionary *newMetadata = nil;
    if (newMetadataString) {
        newMetadata = [NSDictionary dictionaryWithString:newMetadataString];
    }
    self.user.fullMetadata = newMetadata;
    
    // Opt-In
    BOOL newOptIn = [dictionary[@"optIn"] boolValue];
    self.user.optIn = newOptIn;
    
    // External Tokens
    NSDictionary *newExternalTokens = dictionary[@"externalTokens"];
    if ([newExternalTokens isKindOfClass:[NSNull class]]) {
        newExternalTokens = nil;
    }
    self.user.externalTokens = newExternalTokens;
    
    // Loggin expiration date
    NSString *newLogginExpirationDateString = dictionary[@"logUntil"];
    if ([newLogginExpirationDateString isKindOfClass:[NSNull class]]) {
        newLogginExpirationDateString = nil;
    }
    
    NSDate *newLogginExpirationDate = nil;
    if (newLogginExpirationDateString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        newLogginExpirationDate = [formatter dateFromString:newLogginExpirationDateString];
    }
    self.user.logginExpirationDate = newLogginExpirationDate;
}

- (void)syncUserImageFromDictionary:(NSDictionary *)userDictionary {
    [self syncUserImageFromDictionary:userDictionary
                              success:^{
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASUserImageSyncedNotification
                                                                            object:nil];
    }
                              failure:nil];
}

- (void)syncUserImageFromDictionary:(NSDictionary *)dictionary success:(ASSuccessBlock)success failure:(void (^)(NSError *error))failure {
    
    if (self.user.isSyncingImage) {
        NSError *error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:    ASCloudErrorSyncingAlreadyInProgress underlyingError:nil];
        
        if (failure) {
            failure(error);
        }
        return;
    }
    
    self.user.isSyncingImage = YES;
    
    // Check to make sure identifier is correct
    if ([((NSString *) dictionary[@"username"]) compare:self.user.usernameWithTag] != NSOrderedSame) {
        self.user.isSyncingImage = NO;
        if (failure) {
            failure(nil);
        }
        
        return;
    }
    
    NSString *newImageLastSyncedString = dictionary[@"avatarLinkLastModified"];
    if ([newImageLastSyncedString isKindOfClass:[NSNull class]]) {
        newImageLastSyncedString = nil;
    }
    
    if (!newImageLastSyncedString) {
        [self postMissedImageToServerWithSuccess:^{
            self.user.isSyncingImage = NO;
            if (success) {
                success();
            }
        } failure:^(NSError *error) {
            self.user.isSyncingImage = NO;
            if (failure) {
                failure(error);
            }
        }];
        
        return;
    }
    
    NSDate *serverImageLastSynced = nil;
    if (newImageLastSyncedString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        serverImageLastSynced = [formatter dateFromString:dictionary[@"avatarLinkLastModified"]];
    }
    
    if ([self isUserImageDataEqualToDictionary:dictionary]) {
        ASLog(@"User image didn't change");
        self.user.imageLastSynced = serverImageLastSynced;
        self.user.isSyncingImage = NO;
        if (success) {
            success();
        }
        
        return;
    }
    
    // if no local sync or server is newer
    if (!self.user.imageLastSynced || !serverImageLastSynced || ([self.user.imageLastSynced timeIntervalSinceDate:serverImageLastSynced] <= 0)) {
        [self updateImageDataFromDictionary:dictionary];
        [self updateLocalImageFromServerWithSuccess:^{
            self.user.isSyncingImage = NO;
            if (success) {
                success();
            }
        } failure:^(NSError *error) {
            self.user.isSyncingImage = NO;
            if (failure) {
                failure(error);
            }
        }];
    }
    else {
        [self postLocalImageToServerWithSuccess:^{
            self.user.isSyncingImage = NO;
            if (success) {
                success();
            }
        } failure:^(NSError *error) {
            self.user.isSyncingImage = NO;
            if (failure) {
                failure(error);
            }
        }];
    }
}

- (void)postMissedImageToServerWithSuccess:(ASSuccessBlock)success failure:(void (^)(NSError *error))failure {
    ASLog(@"User image missing on server - posting now");
    
    [self.apiService postImageWithSuccess:^(NSString *imageURL, NSDate *imageLastSynced) {
        ASLog(@"Posted user image");
        
        self.user.imageURL = imageURL;
        self.user.imageLastSynced = imageLastSynced;
        [self.systemManager.cloud saveUser];
        
        if (success) {
            success();
        }
        
    } failure:^(NSError *error) {
        ASLog(@"Failed to post user image");
        
        if (error) {
            [self.systemManager.cloud handleUserLogoutWithError:error];
        }
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateLocalImageFromServerWithSuccess:(ASSuccessBlock)success failure:(void (^)(NSError *error))failure {
    ASLog(@"Getting user image from server");
    
    [self.apiService getImageWithSuccess:^(UIImage *image) {
        ASLog(@"Got user image data");
        
        [self.user unsafeSetImage:image.copy];
        [self.systemManager.cloud saveUser];
        
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        ASLog(@"Problem getting user image data");
        self.user.imageLastSynced = nil;
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)postLocalImageToServerWithSuccess:(ASSuccessBlock)success failure:(void (^)(NSError *error))failure {
    ASLog(@"Server user image needs update");
    
    [self.apiService postImageWithSuccess:^(NSString *imageURL, NSDate *imageLastSynced) {
        ASLog(@"Posted user image");
        
        self.user.imageURL = imageURL;
        self.user.imageLastSynced = imageLastSynced;
        [self.systemManager.cloud saveUser];
        
        if (success) {
            success();
        }
        
    } failure:^(NSError *error) {
        ASLog(@"Failed to post user image");
        
        if (error) {
            [self.systemManager.cloud handleUserLogoutWithError:error];
        }
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateImageDataFromDictionary:(NSDictionary *)dictionary {
    // Image Last Modified
    NSString *newImageLastSyncedString = dictionary[@"avatarLinkLastModified"];
    if ([newImageLastSyncedString isKindOfClass:[NSNull class]]) {
        newImageLastSyncedString = nil;
    }
    
    NSDate *newImageLastSynced = nil;
    if (newImageLastSyncedString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        newImageLastSynced = [formatter dateFromString:dictionary[@"avatarLinkLastModified"]];
    }
    self.user.imageLastSynced = newImageLastSynced;
    
    // Image URL
    NSString *newImageURL = dictionary[@"avatarLink"];
    if ([newImageURL isKindOfClass:[NSNull class]]) {
        newImageURL = nil;
    }
    
    self.user.imageURL = newImageURL;
}

#pragma mark - Helpers

- (BOOL)isUserImageDataEqualToDictionary:(NSDictionary *)dictionary {
    // Image Last Modified
    NSString *newImageLastSyncedString = dictionary[@"avatarLinkLastModified"];
    if ([newImageLastSyncedString isKindOfClass:[NSNull class]]) {
        newImageLastSyncedString = nil;
    }
    
    NSDate *newImageLastSynced = nil;
    if (newImageLastSyncedString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        newImageLastSynced = [formatter dateFromString:dictionary[@"avatarLinkLastModified"]];
    }
    
    BOOL imageDateChanged = NO;
    if (newImageLastSynced != self.user.imageLastSynced) {
        if (newImageLastSynced && self.user.imageLastSynced) {
            imageDateChanged = !([newImageLastSynced compare:self.user.imageLastSynced] == NSOrderedSame);
        }
        else {
            imageDateChanged = YES;
        }
    }
    
    if (imageDateChanged) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isUserDataEqualToDictionary:(NSDictionary *)dictionary {
    // First Name
    NSString *newGivenName = dictionary[@"givenName"];
    if ([newGivenName isKindOfClass:[NSNull class]]) {
        newGivenName = nil;
    }
    
    if ([ASUtils detectChangeBetweenString:newGivenName string:self.user.firstName]) {
        return NO;
    }
    
    // Last Name
    NSString *newLastName = dictionary[@"surname"];
    if ([newLastName isKindOfClass:[NSNull class]]) {
        newLastName = nil;
    }
    
    if ([ASUtils detectChangeBetweenString:newLastName string:self.user.lastName]) {
        return NO;
    }
    
    // Metadata
    NSString *newMetadataString = dictionary[@"contents"];
    if ([newMetadataString isKindOfClass:[NSNull class]]) {
        newMetadataString = nil;
    }
    
    NSDictionary *newMetadata = nil;
    if (newMetadataString) {
        newMetadata = [NSDictionary dictionaryWithString:newMetadataString];
    }
    
    BOOL metadataChanged = NO;
    if (newMetadata != self.user.fullMetadata) {
        if (newMetadata && self.user.fullMetadata) {
            metadataChanged = ![newMetadata isEqualToDictionary:self.user.fullMetadata];
        }
        else {
            metadataChanged = YES;
        }
    }
    
    if (metadataChanged) {
        return NO;
    }
    
    // Opt-In
    BOOL newOptIn = [dictionary[@"optIn"] boolValue];
    if (newOptIn != self.user.optIn) {
        return NO;
    }
    
    // Loggin expiration date
    NSString *newLogginExpirationDateString = dictionary[@"logUntil"];
    if ([newLogginExpirationDateString isKindOfClass:[NSNull class]]) {
        newLogginExpirationDateString = nil;
    }
    
    NSDate *newLogginExpirationDate = nil;
    if (newLogginExpirationDateString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        newLogginExpirationDate = [formatter dateFromString:newLogginExpirationDateString];
        
        if (self.user.logginExpirationDate && newLogginExpirationDate) {
            if ([self.user.logginExpirationDate compare:newLogginExpirationDate] != NSOrderedSame) {
                return NO;
            }
        }
        else if (!self.user.logginExpirationDate && !newLogginExpirationDate) {
            // If both are nil, continue on with comparison
        }
        else {
            // One exists and the other does not
            return NO;
        }
    }
    
    // External Tokens
    NSDictionary *newExternalTokens = dictionary[@"externalTokens"];
    if ([newExternalTokens isKindOfClass:[NSNull class]]) {
        newExternalTokens = nil;
    }
    
    BOOL externalTokensChanged = NO;
    if (newExternalTokens != self.user.externalTokens) {
        if (newExternalTokens && self.user.externalTokens) {
            externalTokensChanged = ![newExternalTokens isEqualToDictionary:self.user.externalTokens];
        }
        else {
            externalTokensChanged = YES;
        }
    }
    
    if (externalTokensChanged) {
        return NO;
    }
    
    return YES;
}

@end
