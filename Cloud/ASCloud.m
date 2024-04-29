//
//  ASCloud.m
//  Blustream
//
//  Created by Michael Gordon on 11/19/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASCloudPrivate.h"

#import "AFHTTPSessionManager.h"
#import "AFOAuth2Manager.h"
#import "AFHTTPRequestSerializer+OAuth2.h"
#import "ASConfig.h"
#import "ASContainerManagerPrivate.h"
#import "ASDataUpdateResponsePrivate.h"
#import "ASDeviceManagerPrivate.h"
#import "ASDevicePrivate.h"
#import "ASErrorDefinitions.h"
#import "ASHub+RESTAPI.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASPurchasingManagerPrivate.h"
#import "ASPUTQueue.h"
#import "ASRemoteNotificationManager.h"
#import "ASSyncManager.h"
#import "ASSystemManagerPrivate.h"
#import "ASUserPrivate.h"
#import "NSBundle+ASMobileProvisioning.h"
#import "ASDateFormatter.h"
#import "NSDictionary+ASAccountCheck.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"
#import "ASNetworkResponseErrorHandler.h"

// This queue is serial to prevent syncing and user events from happening at the same time
// TODO Make this queue concurrent.  Any adjustments it makes needs to be thread safe on the base class
// We can't touch the main queue
dispatch_queue_t cloud_processing_queue(void) {
    static dispatch_queue_t as_cloud_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        as_cloud_processing_queue = dispatch_queue_create("com.acoustic-stream.cloud.completion", DISPATCH_QUEUE_SERIAL);
    });
    return as_cloud_processing_queue;
}

dispatch_queue_t cloud_save_queue() {
    static dispatch_queue_t as_cloud_save_queue;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        as_cloud_save_queue = dispatch_queue_create("com.acoustic-stream.cloud.save", DISPATCH_QUEUE_SERIAL);
    });
    
    return as_cloud_save_queue;
}

@implementation ASCloud

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _userStatus = ASUserLoggedOut;
        _systemManager = systemManager;
        
        NSURL *baseURL;
        if (systemManager.config.server == ASServerDevelopment) {
            baseURL = [NSURL URLWithString:@"https://dev.acousticstream.com/v1/"];
        }
        else if (systemManager.config.server == ASServerProduction) {
            baseURL = [NSURL URLWithString:@"https://api.acousticstream.com/v1/"];
        }
        else if (systemManager.config.server == ASServerStaging) {
            baseURL = [NSURL URLWithString:@"https://staging.acousticstream.com/v1/"];
        }
        else if (systemManager.config.server == ASServerDevelopmentH2) {
            baseURL = [NSURL URLWithString:@"http://dev.api.blustream.io/v1/"];
        }
        else {
            NSAssert(NO, @"INVALID SERVER CONFIGURATION");
        }
        
        self.HTTPManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        self.HTTPManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.HTTPManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.HTTPManager.completionQueue = cloud_processing_queue();
        self.HTTPManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        //        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        //        self.HTTPManager.securityPolicy = securityPolicy;
        
        [self loadUser];
        
        // Check tag
        // Don't check tag on user restore.  It causes problems with logging in with the framework
        // demo app using different tags.
        
        //        NSString *tag = ASSystemManager.shared.config.accountTag;
        //        NSRange range = [self.user.usernameWithTag rangeOfString:tag options:NSBackwardsSearch];
        //        if ((range.location + tag.length) != self.user.usernameWithTag.length) {
        //            ASLog(@"User tag is bad!");
        //            [self deleteSavedUser];
        //        }
        
        
        if (self.user.credential) {
            ASLog(@"User credential is restored");
            self.userStatus = ASUserLoggedIn;
            [self.HTTPManager.requestSerializer setAuthorizationHeaderFieldWithCredential:self.user.credential];
        }
        else {
            ASLog(@"User credential is missing!");
            [self deleteSavedUser];
        }
        
        _PUTQueue = [[ASPUTQueue alloc] initWithSystemManager:systemManager];
        _syncManager = [[ASSyncManager alloc] initWithSystemManager:systemManager];
        
        if (self.systemManager.config.enableRemoteNotifications) {
            _remoteNotificationManager = [[ASRemoteNotificationManager alloc] initWithSystemManager:systemManager];
        }
        
        _purchasingManager = [[ASPurchasingManager alloc] initWithHTTPSessionManager:self.HTTPManager];
    }
    return self;
}

// Loads devices from predetermined path
- (void)loadUser {
    ASUser *user = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getDataPath]];
    
    if (user) {
        _user = user;
    }
    else {
        ASLog(@"Failed to load user!");
    }
}

// Saves autoconnect devices to predetermined path
- (void)saveUser {
    dispatch_sync(cloud_save_queue(), ^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.user];
        if (![data writeToFile:[self getDataPath] atomically:YES]) {
            ASLog(@"Failed to save user!");
        }
        
        // Set folder to not backup to iCloud.  Writing erases this attribute
        [ASSystemManager addSkipBackupAttributeToItemAtPath:[self getDataPath]];
    });
}

- (void)deleteSavedUser {
    self.user = nil;
    [ASUser clearCredentials];
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self getDataPath]];
    if (exists) {
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self getDataPath] error:&error];
        if (!success) {
            ASLog(@"Error deleting user: %@", error);
        }
    }
}

// Returns save path for data as an NSString
- (NSString *)getDataPath {
    NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
    NSString *filename = [docsPath stringByAppendingPathComponent:@"User"];
    return filename;
}

#pragma mark - Helper Methods

- (NSString *)getPathForDevice:(ASDevice *)device {
    if (device.serialNumber) {
        return [NSString stringWithFormat:@"devices/%@/", device.serialNumber];
    }
    return nil;
}

- (void)handleUserLogoutWithError:(NSError *)error {
    if (([error.domain compare:ASCloudErrorDomain] == NSOrderedSame) && (error.code == ASCloudErrorInvalidCredentials)) {
        NSArray *callStackSymbols = [NSThread callStackSymbols];
        ASLog(@"//////////////////////////////// LOGGED OUT ////////////////////////////////");
        ASLog(@"////////////////////////////////////////////////////////////////////////////");
        ASLog(@"May have been logged out unintentionally!");
        ASLog(@"Error:\n%@", error);
        ASLog(@"Stack:\n%@", callStackSymbols);
        ASLog(@"////////////////////////////////////////////////////////////////////////////");
        ASLog(@"////////////////////////////////////////////////////////////////////////////");
        [self unsafeLogout];
        NSDictionary *userInfo = @{@"callStackSymbols" : callStackSymbols};
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASUserLoggedOutNotification object:error userObject:userInfo];
    }
}

#pragma mark - Public Methods

- (void)wordPressLoginWithRedirectURL:(NSString *)redirectUrl
                      success:(void (^)(NSString *redirectUri))success
                      failure:(void (^)(NSError *error))failure {
    NSParameterAssert(redirectUrl);
    if (!self.user.credential.accessToken.length) {
        NSError *error = [NSError errorWithDomain:ASWordpressErrorDomain code:-1 userInfo:@{@"description" : @"User is not logged in. Access token is required"}];
        if (failure) {
            dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
        
        return;
    }
    
    NSDictionary *parameters = @{@"Authorization" : self.user.credential.accessToken};
    
    NSString *url = [NSString stringWithFormat:@"users/oauth/blustream/authorize/wp?redirect_url=%@", redirectUrl];
    
    [self.HTTPManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                NSString *uri = responseObject[@"redirect_uri"];
                success(uri);
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}

- (void)registerNewUser:(NSDictionary *)userInfo completion:(void (^)(NSError *error))completion {
    [self registerNewUser:userInfo accountTag:self.systemManager.config.accountTag authParameter:self.systemManager.config.authParameter completion:completion];
}

- (void)registerNewUser:(NSDictionary *)userInfo accountTag:(NSString *)accountTag authParameter:(NSString *)authParameter completion:(void (^)(NSError *error))completion {
    dispatch_async(cloud_processing_queue(), ^{
        ASLog(@"Registering new user");
        
        NSError *error = nil;
        if (![userInfo checkLoginInfoWithError:&error tagLength:accountTag ? accountTag.length : 0]) {
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
            return;
        }
        
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        
        NSString *usernameWithTag = [[NSString stringWithFormat:@"%@%@", userInfo[@"email"], accountTag] lowercaseString];
        
        NSString *email = userInfo[@"email"];
        email = [email lowercaseString];
        
        NSDictionary *parameters = @{@"username" : usernameWithTag,
                                     @"givenName" : userInfo[@"firstname"],
                                     @"surname" : userInfo[@"lastname"],
                                     @"emailAddress" : email,
                                     @"created" : [formatter stringFromDate:[NSDate date]]};
        
        if (userInfo[@"optIn"]) {
            NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
            int optInValue = ((NSNumber *)userInfo[@"optIn"]).boolValue ? 1 : 0; // Force 1 or 0 - server doesn't take bools
            [mutableParameters setValue:@(optInValue) forKey:@"optIn"];
            parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
        }
        
        AFHTTPSessionManager *registrationHTTPManager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.HTTPManager.baseURL];
        registrationHTTPManager.responseSerializer = [AFJSONResponseSerializer serializer];
        registrationHTTPManager.requestSerializer = [AFJSONRequestSerializer serializer];
        registrationHTTPManager.completionQueue = cloud_processing_queue();
        
        [registrationHTTPManager.requestSerializer setAuthorizationHeaderFieldWithUsername:usernameWithTag password:userInfo[@"password"]];
        
        NSString *URLString = [NSString stringWithFormat:@"users/%@", usernameWithTag];
        if (authParameter) {
            URLString = [NSString stringWithFormat:@"%@/%@", URLString, authParameter];
        }
        
        [registrationHTTPManager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            ASLog(@"Successfully registered new user");
            
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            ASLog(@"Failed to register new user");
            
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSInteger errorCode = response.statusCode;
            
            // I'm leaving this in as an example in the future
            NSString *errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            
            ASCloudError responseErr = [ASNetworkResponseErrorHandler parseErrorResponse:errorResponse];

            if (errorCode == 422) {
                error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorAccountAlreadyExists underlyingError:error];
                
            } else if (responseErr == ASCloudErrorAccountCreationTooManyAttemps) {
                error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorAccountCreationTooManyAttemps underlyingError:error];
            }
            else {
                error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
            }
            
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
        }];
    });
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(NSError *error))completion {
    [self loginWithUsername:username password:password accountTag:self.systemManager.config.accountTag authParameter:self.systemManager.config.authParameter completion:completion];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password accountTag:(NSString *)accountTag authParameter:(NSString *)authParameter completion:(void (^)(NSError *error))completion {
    dispatch_async(cloud_processing_queue(), ^{
        [self unsafeLogout];
        ASLog(@"Logging user in");
        
        self.userStatus = ASUserLoggingIn;
        
        NSURL *baseURLOAuth = self.HTTPManager.baseURL;
        
        AFOAuth2Manager *OAuth2Manager = [[AFOAuth2Manager alloc] initWithBaseURL:baseURLOAuth clientID:self.systemManager.config.clientID secret:self.systemManager.config.clientSecret];
        
        NSDictionary *OAuthParameters = @{@"grant_type" : @"password"};
        
        OAuth2Manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        NSString *usernameWithTag = [NSString stringWithFormat:@"%@%@", [username copy], accountTag];
        
        [OAuth2Manager.requestSerializer setAuthorizationHeaderFieldWithUsername:usernameWithTag password:password];
        
        NSString *URLString = @"users/oauth";
        if (authParameter) {
            URLString = [NSString stringWithFormat:@"%@/%@", URLString, authParameter];
        }
        
#define USE_USER_CREDENTIALS TRUE
#if USE_USER_CREDENTIALS
        [OAuth2Manager authenticateUsingOAuthWithURLString:URLString parameters:OAuthParameters success:^(AFOAuthCredential *newCredential) {
#endif
            ASLog(@"Successfully authenticated user");
            
            self.user = [[ASUser alloc] init];
#if USE_USER_CREDENTIALS
            self.user.usernameWithTag = usernameWithTag;
            self.user.credential = newCredential;
#else
            self.user.usernameWithTag = @"";
            self.user.credential = [AFOAuthCredential credentialWithOAuthToken:@"" tokenType:@"bearer"];
#endif
            
            [self saveUser];
            
            [self.HTTPManager.requestSerializer setAuthorizationHeaderFieldWithCredential:self.user.credential];
            
            self.userStatus = ASUserLoggedIn;
            
            [self.syncManager start];
            
            [self.systemManager.deviceManager stopScanning];
            [self.systemManager.deviceManager startScanning];
            
            [self.PUTQueue start];
            
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
#if USE_USER_CREDENTIALS
        } failure:^(NSError *error) {
            ASLog(@"Failed to authenticate user");
            
            self.userStatus = ASUserLoggedOut;
            
            error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
            
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
        }];
#endif
    });
}

- (void)logout {
    dispatch_sync(cloud_processing_queue(), ^{
        [self unsafeLogout];
    });
}

- (void)unsafeLogout {
    ASLog(@"Logging user out");
    
    [self.remoteNotificationManager.currentHub deleteWithCompletion:^(NSError *error) {
        if (error) {
            ASLog(@"Failed to delete hub: %@", error);
        }
        else {
            ASLog(@"Deleted hub!");
        }
    }];
    
    [self.remoteNotificationManager resetHubs];
    
    [ASUser clearCredentials];
    
    [self.HTTPManager.requestSerializer clearAuthorizationHeader];
    self.userStatus = ASUserLoggedOut;
    
    [self deleteSavedUser];
    
    for (ASDevice *device in self.systemManager.deviceManager.devices) {
        // Setting autoconnect will send a disconnect message to the device
        [device setAutoConnect:NO error:nil];
    }
    
    [self.PUTQueue stop];
    [self.syncManager stop];
    
    [self.systemManager.deviceManager resetDevices];
    [self.systemManager.containerManager resetContainers];
    
    [self.systemManager.deviceManager stopScanning];
}

- (void)sendPasswordResetEmailForUsername:(NSString *)username completion:(void (^)(NSError *error))completion {
    [self sendPasswordResetEmailForUsername:username accountTag:self.systemManager.config.accountTag completion:completion];
}

- (void)sendPasswordResetEmailForUsername:(NSString *)username accountTag:(NSString *)accountTag completion:(void (^)(NSError *error))completion {
    NSParameterAssert(username);
    username = username.lowercaseString;
    dispatch_async(cloud_processing_queue(), ^{
        NSString *usernameWithTag = [NSString stringWithFormat:@"%@%@", username, accountTag];
        
        NSString *url = [NSString stringWithFormat:@"users/%@/password/reset", usernameWithTag];
        
        if ([accountTag compare:@"+taylor"] == NSOrderedSame) {
            url = [NSString stringWithFormat:@"%@?brand=Taylor", url];
        }
        else if ([accountTag compare:@"+blustream"] == NSOrderedSame) {
            url = [NSString stringWithFormat:@"%@?brand=Blustream", url];
        }
        else if ([accountTag compare:@"+boveda"] == NSOrderedSame) {
            url = [NSString stringWithFormat:@"%@?brand=Boveda", url];
        }
        else if ([accountTag compare:@"+humiditrak"] == NSOrderedSame) {
            url = [NSString stringWithFormat:@"%@?brand=Humiditrak", url];
        }
        else if ([accountTag compare:@"+safeandsound"] == NSOrderedSame) {
            url = [NSString stringWithFormat:@"%@?brand=SafeAndSound", url];
        }
        
        NSDictionary *dict = @{@"userEmailAddress" : username};
        [self.HTTPManager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
            
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
        }];
    });
}

- (void)sendRemoteNotificationToAllDevicesWithTitle:(NSString *)title message:(NSString *)message playSound:(BOOL)sound completion:(void (^)(NSError *error))completion {
    NSParameterAssert(message);
    
    dispatch_async(cloud_processing_queue(), ^{
        [self.remoteNotificationManager sendRemoteNotificationToAllDevicesWithTitle:title message:message playSound:sound bundleIdentifier:self.systemManager.config.bundleIdentifierOverride completion:^(NSError *error) {
//            error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
            
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
        }];
    });
}

- (void)sendSilentNotificationToAllDevicesWithPayload:(NSDictionary *)payload
                                              success:(void (^)(void))success
                                              failure:(void (^)(NSError *error))failure {
    dispatch_async(cloud_processing_queue(), ^{
        [self.remoteNotificationManager
         sendSilentNotificationToAllDevicesWithPayload:payload
         success:success failure:failure];
    });
}

- (void)checkForNewDataWithSuccess:(void (^)(ASDataUpdateResponse *response))success
                           failure:(void (^)(NSError *error))failure {
    dispatch_async(cloud_processing_queue(), ^{
        NSString *url = [NSString stringWithFormat:@"users/%@/update/data", self.user.usernameWithTag];

        [self.HTTPManager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success) {
                ASDataUpdateResponse *response = [[ASDataUpdateResponse alloc] initWithDictionaries:responseObject];
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    success(response);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
                
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    failure(error);
                });
            }
        }];
    });
}

@end
