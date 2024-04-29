//
//  ASRESTServiceError.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 12/26/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASRESTServiceError.h"
#import "NSError+ASError.h"
#import "ASErrorDefinitions.h"

@implementation ASRESTServiceError

+ (NSError *)errorForResponse:(NSHTTPURLResponse *)response type:(ASRESTServiceErrorType)type {
    switch (type) {
        case ASRESTServiceErrorTypeGeneral:
            return [self generalErrorForResponse:response];
            
        case ASRESTServiceErrorTypeSyncContainers:
            return [self syncContainersErrorForResponse:response];
            
        case ASRESTServiceErrorTypeCloud:
            return [self cloudErrorForResponse:response];
    }
}

+ (NSError *)generalErrorForResponse:(NSHTTPURLResponse *)response {
    NSInteger errorCode = response.statusCode;
    NSError *error = nil;
    
    switch (errorCode) {
        case 401:
            return [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorInvalidCredentials underlyingError:error];
            
        default:
            return [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
    }
}

+ (NSError *)syncContainersErrorForResponse:(NSHTTPURLResponse *)response {
    NSInteger errorCode = response.statusCode;
    NSError *error = nil;
    
    switch (errorCode) {
        case 404: {
            return [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorContainerNotFound underlyingError:error];
        }
            
        default:
            return [self generalErrorForResponse:response];
    }
}

+ (NSError *)cloudErrorForResponse:(NSHTTPURLResponse *)response {
    NSInteger errorCode = response.statusCode;
    NSError *error = nil;
    
    switch (errorCode) {
        case 400: {
            return [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorServerError underlyingError:error];
        }
            
        case 404: {
            return [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorDeviceNotFound underlyingError:error];
        }
            
        default:
            return [self generalErrorForResponse:response];
    }
}

@end
