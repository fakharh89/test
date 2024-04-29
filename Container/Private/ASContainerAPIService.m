//
//  ASContainerAPIService.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 1/26/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import "ASContainerAPIService.h"

#import "ASDevicePrivate.h"
#import "ASUserPrivate.h"
#import "ASDeviceAPIService.h"
#import "ASContainerPrivate.h"
#import "ASSystemManager.h"
#import "ASCloudPrivate.h"
#import "AFHTTPSessionManager.h"
#import "ASRESTServiceError.h"
#import "ASLog.h"
#import "ASDateFormatter.h"
#import "ASErrorDefinitions.h"

#import "NSError+ASError.h"
#import "NSString+ASJSONToString.h"

@interface ASContainerAPIService()

@property (nonatomic, strong) ASSystemManager *systemManager;
@property (nonatomic, strong) ASContainer *container;

@end

@implementation ASContainerAPIService

- (instancetype)initWithContainer:(ASContainer *)container systemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _systemManager = systemManager;
        _container = container;
    }
    
    return self;
}

- (void)postWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"containers/%@/", self.container.identifier];
    
    [ASSystemManager.shared.cloud.HTTPManager POST:url parameters:[self getEditableJSONBlob] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully posted container (%@ - %@) to server", self.container.name, self.container.identifier);
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        self.container.lastSynced = [formatter dateFromString:responseObject[@"lastModified"]];
        [self.container save];
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to post container (%@ - %@) to server: %@", self.container.name, self.container.identifier, error);
        
        error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)putWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"containers/%@/", self.container.identifier];
    
    [ASSystemManager.shared.cloud.HTTPManager PUT:url parameters:[self getJSONBlob] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully put container (%@ - %@) to server", self.container.name, self.container.identifier);
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        self.container.lastSynced = [formatter dateFromString:responseObject[@"lastModified"]];
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to put container (%@ - %@) to server: %@", self.container.name, self.container.identifier, error);
        
        error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)deleteWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"containers/%@/", self.container.identifier];
    
    [ASSystemManager.shared.cloud.HTTPManager DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully deleted container (%@ - %@) from server", self.container.name, self.container.identifier);
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to delete container (%@ - %@) from server: %@", self.container.name, self.container.identifier, error);
        
        error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)postImageWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    
    NSString *url = [NSString stringWithFormat:@"containers/%@/avatar", self.container.identifier];
    
    [ASSystemManager.shared.cloud.HTTPManager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *png = UIImagePNGRepresentation(self.container.image);
        
        if (!png) {
            png = [[NSData alloc] init];
        }
        
        NSString *name = @"avatar";
        NSString *fileName = [NSString stringWithFormat:@"%@.png", self.container.identifier];
        NSString *size = [NSString stringWithFormat:@"%lu", (unsigned long) png.length];
        NSString *mimeType = @"image/png";
        
        NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
        [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"; size=\"%@\"", name, fileName, size] forKey:@"Content-Disposition"];
        [mutableHeaders setValue:mimeType forKey:@"Content-Type"];
        
        [formData appendPartWithHeaders:mutableHeaders body:png];
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.container.imageURL = responseObject[@"avatarUrl"];
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        self.container.imageLastSynced = [formatter dateFromString:responseObject[@"avatarLastModified"]];
        [self.container save];

        if (success) {
            success();
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];

        if (failure) {
            failure(error);
        }
    }];
}

- (void)getImageWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    
    if (!self.container.imageURL) {
        NSError *error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorImageURLMissing underlyingError:nil];
        if (failure) {
            failure(error);
        }
        return;
    }
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    if (@available(iOS 13.0, *)) {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/octet-stream"];
    }
    manager.completionQueue = ASSystemManager.shared.cloud.HTTPManager.completionQueue;
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    [manager GET:self.container.imageURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.container unsafeSetImage:responseObject];
        [self.container save];
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)putDeviceLink:(ASDevice *)device authenticationKey:(NSData *)key success:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    NSParameterAssert(device.serialNumber);
    
    ASDeviceAPIService *deviceAPIService = [[ASDeviceAPIService alloc] initWithDevice:device systemManager:ASSystemManager.shared];
    
    [deviceAPIService getWithSuccess:^{
        [self linkDevice:device withSuccess:success failure:failure];
    } failure:^(NSError * _Nullable error) {
        if (([error.domain compare:ASCloudErrorDomain] == NSOrderedSame) && (error.code == ASCloudErrorDeviceNotFound)) {
            // Device get failed because it isn't put
            ASDeviceAPIService *deviceAPIService = [[ASDeviceAPIService alloc] initWithDevice:device systemManager:ASSystemManager.shared];
            [deviceAPIService putWithSuccess:^{
                [self linkDevice:device withSuccess:success failure:failure];
            } failire:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
        else {
            if (failure) {
                failure(error);
            }
        }
    }];
}

- (void)linkDevice:(ASDevice *)device withSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"containers/%@/devices/%@", self.container.identifier, device.serialNumber];
    
    NSDictionary *parameters = nil;//@{@"authKey":key};
    
    [self.systemManager.cloud.HTTPManager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully put container link (%@ - %@) to server", self.container.name, self.container.identifier);
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to put container link (%@ - %@) to server: %@", self.container.name, self.container.identifier, error);
        
        error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (failure) {
            (failure)(error);
        }
    }];
}

- (void)deleteDeviceLinkWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"containers/%@/devices/%@", self.container.identifier, self.container.linkedDeviceSerialNumber];
    
    [ASSystemManager.shared.cloud.HTTPManager DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully deleted container link (%@ - %@) from server", self.container.name, self.container.identifier);
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to delete container link (%@ - %@) from server: %@", self.container.name, self.container.identifier, error);
        
        error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (failure) {
            failure(error);
        }
    }];
}

- (NSDictionary *)getJSONBlob {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self getEditableJSONBlob]];
    
    [parameters addEntriesFromDictionary:@{@"ownerUsername": self.systemManager.cloud.user.usernameWithTag}];
    
    return [NSDictionary dictionaryWithDictionary:parameters];
}

- (NSDictionary *)getEditableJSONBlob {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters addEntriesFromDictionary:@{@"containerId":self.container.identifier}];
    [parameters addEntriesFromDictionary:@{@"name":(self.container.name ?: @"")}];
    [parameters addEntriesFromDictionary:@{@"containerType":(self.container.type ?: @"")}];
    [parameters addEntriesFromDictionary:@{@"appName":(self.container.creator ?: @"")}];
    [parameters addEntriesFromDictionary:@{@"contents":(self.container.fullMetadata ? [NSString stringWithDictionary:self.container.fullMetadata] : @"")}];
    
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end
