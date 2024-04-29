//
//  ASUserAPIService.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 12/26/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASUserAPIService.h"

#import "ASUserPrivate.h"
#import "ASSystemManager.h"
#import "ASCloudPrivate.h"
#import "AFHTTPSessionManager.h"
#import "ASRESTServiceError.h"
#import "ASLog.h"
#import "ASDateFormatter.h"
#import "ASErrorDefinitions.h"
#import "ASHub.h"

#import "NSError+ASError.h"
#import "NSString+ASJSONToString.h"

@interface ASUserAPIService()

@property (nonatomic, strong) ASSystemManager *systemManager;
@property (nonatomic, strong) ASUser *user;

@end

@implementation ASUserAPIService

- (instancetype)initWithUser:(ASUser *)user systemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _user = user;
        _systemManager = systemManager;
    }
    
    return self;
}

- (void)getUserDataWithSuccess:(void(^)(NSDictionary *userDictionary))success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"users/%@/", self.user.usernameWithTag];
    
    [self.systemManager.cloud.HTTPManager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully got user from server");
        
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to get user from server");

        if (failure) {
            error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
            failure(error);
        }
    }];
}

- (void)deleteWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure; {
    NSString *url = [NSString stringWithFormat:@"users/%@/", self.user.usernameWithTag];
    
    __block ASUserAPIService *blockSafeSelf = self;
    [self.systemManager.cloud.HTTPManager DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully deleted user (%@) from server", responseObject[@"username"]);
        
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to deleted user (%@) from server: %@", blockSafeSelf.user.username, error);
        
        if (failure) {
            error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
            failure(error);
        }
    }];
}

- (void)postWithSuccess:(void(^)(NSDate *lastSynced))success failure:(ASFailureBlock)failure  {
    NSString *url = [NSString stringWithFormat:@"users/%@/", self.user.usernameWithTag];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters addEntriesFromDictionary:@{@"givenName":(self.user.firstName ?: @"")}];
    [parameters addEntriesFromDictionary:@{@"surname":(self.user.lastName ?: @"")}];
    [parameters addEntriesFromDictionary:@{@"optIn":@(self.user.optIn ? 1 : 0)}]; // Convert to integer, not bool
    [parameters addEntriesFromDictionary:@{@"contents":(self.user.fullMetadata ? [NSString stringWithDictionary:self.user.fullMetadata] : @"")}];
    
    __block ASUserAPIService *blockSafeSelf = self;
    [self.systemManager.cloud.HTTPManager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully posted user (%@) to server", responseObject[@"username"]);
        
        if (success) {
            ASDateFormatter *formatter = [ASDateFormatter new];
            NSDate *lastSynced = [formatter dateFromString:responseObject[@"lastModified"]];
            success(lastSynced);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to post user (%@) to server: %@", blockSafeSelf.user.username, error);
        
        if (failure) {
            error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
            failure(error);
        }
    }];
}

- (void)postImageWithSuccess:(void(^)(NSString *imageURL, NSDate *imageLastSynced))success failure:(ASFailureBlock)failure;  {
    NSString *url = [NSString stringWithFormat:@"users/%@/avatar", self.user.usernameWithTag];
    
    __block ASUserAPIService *blockSafeSelf = self;
    [self.systemManager.cloud.HTTPManager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *png = UIImagePNGRepresentation(blockSafeSelf.user.image);
        
        if (!png) {
            png = [NSData new];
        }
        
        NSString *name = @"avatar";
        NSString *fileName = [NSString stringWithFormat:@"%@.png", [NSUUID UUID].UUIDString];
        NSString *size = [NSString stringWithFormat:@"%lu", (unsigned long) png.length];
        NSString *mimeType = @"image/png";
        
        NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
        [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"; size=\"%@\"", name, fileName, size] forKey:@"Content-Disposition"];
        [mutableHeaders setValue:mimeType forKey:@"Content-Type"];
        
        [formData appendPartWithHeaders:mutableHeaders body:png];
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASDateFormatter *formatter = [ASDateFormatter new];
        NSDate *imageLastSynced = [formatter dateFromString:responseObject[@"avatarLastModified"]];
        if (success) {
           
            success(responseObject[@"avatarUrl"], imageLastSynced);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
            failure(error);
        }
    }];
}

- (void)getImageWithSuccess:(void (^)(UIImage *))success failure:(ASFailureBlock)failure {

    if (!self.user.imageURL) {
        if (failure) {
            NSError *error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorImageURLMissing underlyingError:nil];
            failure(error);
        }
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    if (@available(iOS 13.0, *)) {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/octet-stream"];
    }
    manager.completionQueue = self.systemManager.cloud.HTTPManager.completionQueue;
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    [manager GET:self.user.imageURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getHubsWithSuccess:(void (^)(NSArray<ASHub *> *hubs))success failure:(ASFailureBlock)failure {
    ASLog(@"Getting hubs");
    NSString *url = [NSString stringWithFormat:@"users/%@/hubs/", self.user.usernameWithTag];
    
    [self.systemManager.cloud.HTTPManager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray<ASHub *> *hubs = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dictionary in responseObject) {
            ASHub *hub = [[ASHub alloc] initWithDictionary:dictionary];
            [hubs addObject:hub];
        }
        
        if (success) {
            success([NSArray arrayWithArray:hubs]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to get user container list");
        
        if (failure) {
            error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeSyncContainers];
            failure(error);
        }
    }];
}

- (void)subscribeHubToSilentNotifications:(ASHub *)hub withSuccess:(void (^)(ASHub *))success failure:(ASFailureBlock)failure {
    ASLog(@"Subscribing hub with identifier %@ to silent notifications ", hub.identifier);
    
    NSString *url = [NSString stringWithFormat:@"users/%@/hubs/%@/", self.user.usernameWithTag, hub.identifier];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters addEntriesFromDictionary:@{@"subscribedToSilentNotifications": @YES}];
    
    [self.systemManager.cloud.HTTPManager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            ASHub *hub = [[ASHub alloc] initWithDictionary:responseObject];
            success(hub);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
            failure(error);
        }
    }];
}

- (void)sendSilentNotificationToAllHubsWithPayload:(NSDictionary *)payload success:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    ASLog(@"Sending silent notification to all hubs");
    
    NSString *url = [NSString stringWithFormat:@"users/%@/hubs/ping/", self.user.usernameWithTag];
    
    [self.systemManager.cloud.HTTPManager PUT:url parameters:payload success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
            failure(error);
        }
    }];
}

- (void)updateAllHubsWithTitle:(NSString *)title message:(NSString *)message playSound:(BOOL)sound success:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    [self updateAllHubsWithTitle:title message:message playSound:sound bundleIdentifier:[NSBundle mainBundle].bundleIdentifier success:success failure:failure];
}

- (void)updateAllHubsWithTitle:(NSString *)title message:(NSString *)message playSound:(BOOL)sound bundleIdentifier:(NSString *)bundleIdentifier success:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    if (!bundleIdentifier || (bundleIdentifier.length == 0)) {
        bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    }
    
    NSString *url = [NSString stringWithFormat:@"users/%@/hubs/notify/%@", self.user.usernameWithTag, bundleIdentifier];
    
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
    
    if (title) {
        mutableDictionary[@"title"] = title;
    }
    if (message) {
        mutableDictionary[@"message"] = message;
    }
    
    mutableDictionary[@"playSound"] = @(sound);
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableDictionary];
    
    [self.systemManager.cloud.HTTPManager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
            failure(error);
        }
    }];
}

- (void)getUpdatedContainersForType:(ASAccessType)type success:(void (^)(NSArray *))success failure:(ASFailureBlock)failure {
    if (type != ASAccessTypeOwner) {
        if (failure) {
            failure(nil);
        }
    }
    
    NSString *accessLevel = @"Owner";
    
    NSString *url = [NSString stringWithFormat:@"users/%@/containers/", self.user.usernameWithTag];
    NSDictionary *parameters = @{@"accessLevel": accessLevel};
    
    [self.systemManager.cloud.HTTPManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to get user container list");
        
        if (failure) {
            error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeSyncContainers];
            failure(error);
        }
    }];
}

@end
