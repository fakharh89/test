//
//  ASDeviceAPIService.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 1/22/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import "ASDeviceAPIService.h"

#import "ASDevicePrivate.h"
#import "ASSystemManager.h"
#import "ASCloudPrivate.h"
#import "AFHTTPSessionManager.h"
#import "ASRESTServiceError.h"
#import "ASLog.h"
#import "ASDateFormatter.h"
#import "ASErrorDefinitions.h"

#import "NSString+ASJSONToString.h"

@interface ASDeviceAPIService()

@property (nonatomic, strong) ASSystemManager *systemManager;
@property (nonatomic, strong) ASDevice *device;

@property (nonatomic, strong, readonly) NSDictionary *JSONBlob;

@end

@implementation ASDeviceAPIService

- (instancetype)initWithDevice:(ASDevice *)device systemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _systemManager = systemManager;
        _device = device;
    }
    
    return self;
}

- (void)postWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"devices/%@/", self.device.serialNumber];
    
    [self.systemManager.cloud.HTTPManager POST:url parameters:self.JSONBlob progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully posted device (%@) to server", self.device.serialNumber);
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        self.device.lastSynced = [formatter dateFromString:responseObject[@"lastModified"]];
        
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to post device (%@) to server: %@", self.device.serialNumber, error);
        
        error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeCloud];
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)putWithSuccess:(ASSuccessBlock)success failire:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"devices/%@/", self.device.serialNumber];
    
    [self.systemManager.cloud.HTTPManager PUT:url parameters:self.JSONBlob success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully put device (%@) to server", self.device.serialNumber);
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        self.device.lastSynced = [formatter dateFromString:responseObject[@"lastModified"]];
        self.device.syncedForFirstTime = YES;
        
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to put device (%@) to server: %@", self.device.serialNumber, error);
        
        error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)deleteWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"devices/%@/", self.device.serialNumber];
    
    [self.systemManager.cloud.HTTPManager DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ASLog(@"Successfully deleted device (%@) from server", self.device.serialNumber);
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to delete device (%@) from server: %@", self.device.serialNumber, error);
        
        error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"devices/%@/", self.device.serialNumber];
    
    [self.systemManager.cloud.HTTPManager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeCloud];
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getRegistrationFromServerWithSuccess:(void (^)(NSString *registrationCode))success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"devices/%@/register/", self.device.serialNumber];
    
    [ASSystemManager.shared.cloud.HTTPManager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSString *registrationCode = responseObject[@"registrationCleartext"];
            success(registrationCode);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ASLog(@"Failed to get registration data (%@) from server: %@", self.device.serialNumber, error);
        
        error = [ASRESTServiceError errorForResponse:(NSHTTPURLResponse *)task.response type:ASRESTServiceErrorTypeGeneral];
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        
        if (failure) {
            failure(error);
        }
    }];
}

- (NSDictionary *)JSONBlob {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    NSString *typeString;
    
    switch (self.device.type) {
        case ASDeviceTypeSoftware:
        typeString = @"Software";
        break;
        
        case ASDeviceTypeTaylor:
        typeString = @"Taylor";
        break;
        
        case ASDeviceTypeDAddario:
        typeString = @"Daddario";
        break;
        
        case ASDeviceTypeTKL:
        typeString = @"TKL";
        break;
        
        case ASDeviceTypeBlustream:
        typeString = @"Blustream";
        break;
        
        case ASDeviceTypeBoveda:
        typeString = @"Boveda";
        break;
        
        default:
        break;
    }
    
    [parameters addEntriesFromDictionary:@{@"deviceType": (typeString ? : @"")}];
    [parameters addEntriesFromDictionary:@{@"serialNumber":(self.device.serialNumber ?: @"")}];
    [parameters addEntriesFromDictionary:@{@"metadata":(self.device.fullMetadata ? [NSString stringWithDictionary:self.device.fullMetadata] : @"")}];
    [parameters addEntriesFromDictionary:@{@"hardwareVersion":(self.device.hardwareRevision ?: @"")}];
    [parameters addEntriesFromDictionary:@{@"softwareVersion":(self.device.softwareRevision ?: @"")}];
    
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end
