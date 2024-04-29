//
//  ASHub+RESTAPI.m
//  Pods
//
//  Created by Michael Gordon on 11/21/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASHub+RESTAPI.h"

#import "AFHTTPSessionManager.h"
#import "ASCloudPrivate.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASSystemManager.h"
#import "ASUserPrivate.h"
#import "NSError+ASError.h"

@implementation ASHub (RESTAPI)

- (void)putWithCompletion:(void (^)(NSError *error))completion {
    NSString *url = [NSString stringWithFormat:@"users/%@/hubs/", ASSystemManager.shared.cloud.user.usernameWithTag];
    
    [ASSystemManager.shared.cloud.HTTPManager PUT:url parameters:[self dictionary] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully put hub (%@) to server", self.notificationTokenID);
        self.identifier = responseObject[@"hubId"];
        if (completion) {
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to put hub (%@) to server: %@", self.notificationTokenID, error);
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSInteger errorCode = response.statusCode;
        
        switch (errorCode) {
            case 401:
                error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorInvalidCredentials underlyingError:error];
                break;
                
            default:
                error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
                break;
        }
        
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (completion) {
            completion(error);
        }
    }];
}

- (void)deleteWithCompletion:(void (^)(NSError *error))completion {
    NSParameterAssert(self.identifier);
    
    NSString *url = [NSString stringWithFormat:@"users/%@/hubs/%@", ASSystemManager.shared.cloud.user.usernameWithTag, self.identifier];
    
    [ASSystemManager.shared.cloud.HTTPManager DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Deleted hub (%@) from server", self.notificationTokenID);
        if (completion) {
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to delete hub (%@) from server: %@", self.identifier, error);
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSInteger errorCode = response.statusCode;
        
        switch (errorCode) {
            case 401:
                error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorInvalidCredentials underlyingError:error];
                break;
                
            default:
                error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
                break;
        }
        
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (completion) {
            completion(error);
        }
    }];
}

@end
