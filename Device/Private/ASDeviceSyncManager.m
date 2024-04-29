//
//  ASDeviceSyncManager.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 1/24/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import "ASDeviceSyncManager.h"

#import "ASSystemManagerPrivate.h"
#import "ASDevicePrivate.h"
#import "ASDeviceAPIService.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASCloudPrivate.h"
#import "ASContainer.h"
#import "ASContainerManagerPrivate.h"
#import "ASDeviceManagerPrivate.h"
#import "ASDateFormatter.h"
#import "ASUtils.h"
#import "AFHTTPSessionManager.h"

#import "NSError+ASError.h"
#import "NSDictionary+ASStringToJSON.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

@interface ASDeviceSyncManager()

@property (nonatomic, strong) ASDevice *device;
@property (nonatomic, strong) ASDeviceAPIService *apiService;
@property (nonatomic, weak) ASSystemManager *systemManager;

@end

@implementation ASDeviceSyncManager

- (instancetype)initWithDevice:(ASDevice *)device systemManager:(ASSystemManager *)systemManager apiService:(ASDeviceAPIService *)apiService {
    self = [super init];
    
    if (self) {
        _device = device;
        _systemManager = systemManager;
        _apiService = apiService;
    }
    
    return self;
}

- (void)synchronizeWithSuccess:(ASSuccessBlock)success failure:(ASFailureBlock)failure {

    NSString *url = [NSString stringWithFormat:@"devices/%@/", self.device.serialNumber];
    
    if (self.device.isSyncing) {
        NSError *error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:    ASCloudErrorSyncingAlreadyInProgress underlyingError:nil];
        if (failure) {
            failure(error);
        }
        return;
    }
    
    self.device.isSyncing = YES;
    __block ASDeviceSyncManager *blockSafeSelf = self;
    [self.systemManager.cloud.HTTPManager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([blockSafeSelf syncDeviceFromDictionary:responseObject]) {
            ASLog(@"Synced device (%@)", blockSafeSelf.device.serialNumber);
            ASDeviceManager *deviceManager = [[ASDeviceManager alloc] initWithSystemManager:blockSafeSelf.systemManager];
            [deviceManager saveDevice:blockSafeSelf.device];
            // Broadcast notification
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceSyncedNotification object:blockSafeSelf.device];
        }
        else {
            ASLog(@"Device (%@) info didn't change", blockSafeSelf.device.serialNumber);
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceSyncedNoChangesNotification object:nil];
        }
        
        blockSafeSelf.device.syncedForFirstTime = YES;
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSInteger errorCode = response.statusCode;
        if (errorCode != 404) {
            ASLog(@"Failed to sync device (%@) with server", blockSafeSelf.device.serialNumber);
        }
        
        switch (errorCode) {
            case 401:
            error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorInvalidCredentials underlyingError:error];
            break;
            
            default:
            error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:ASCloudErrorUnknown underlyingError:error];
            break;
        }
        
        [ASSystemManager.shared.cloud handleUserLogoutWithError:error];
        self.device.isSyncing = NO;
        if (failure) {
            failure(error);
        }
    }];
}

- (BOOL)syncDeviceFromDictionary:(NSDictionary *)dictionary {
    BOOL changed = NO;
    
    // Check to make sure identifier is correct
    if ([((NSString *) dictionary[@"serialNumber"]) caseInsensitiveCompare:self.device.serialNumber] != NSOrderedSame) {
        self.device.isSyncing = NO;
        return NO;
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
    
    // if server is missing date, override with local
    if (!serverLastSynced) {
        if (!self.device.syncedForFirstTime && dictionary[@"metadata"]) {
            NSString *fullMetadataString = dictionary[@"metadata"];
            if (fullMetadataString) {
                self.device.fullMetadata = [NSDictionary dictionaryWithString:fullMetadataString];
            }
        }
        [self.apiService postWithSuccess:^{
            self.device.isSyncing = NO;
        } failure:^(NSError *error) {
            self.device.isSyncing = NO;
        }];
    }
    else if ([self isEqualToDictionary:dictionary]) {
        changed = NO;
        self.device.isSyncing = NO;
        self.device.lastSynced = serverLastSynced;
    }
    else {
        // if no local sync or server is newer
        if (!self.device.lastSynced || ([self.device.lastSynced timeIntervalSinceDate:serverLastSynced] <= 0)) {
            // Update local from server
            changed = YES;
            [self updateFromDictionary:dictionary];
            self.device.isSyncing = NO;
        }
        else {
            // Post local to server
            if (!self.device.syncedForFirstTime && dictionary[@"metadata"]) {
                NSString *fullMetadataString = dictionary[@"metadata"];
                if (fullMetadataString) {
                    self.device.fullMetadata = [NSDictionary dictionaryWithString:fullMetadataString];
                }
            }
            [self.apiService postWithSuccess:^{
                self.device.isSyncing = NO;
            } failure:^(NSError *error) {
                self.device.isSyncing = NO;
            }];
        }
    }
    
    return changed;
}

- (BOOL)isEqualToDictionary:(NSDictionary *)dictionary {
    // Software Revision
    NSString *newSoftwareRevision = dictionary[@"softwareVersion"];
    if ([newSoftwareRevision isKindOfClass:[NSNull class]]) {
        newSoftwareRevision = nil;
    }
    
    if ([ASUtils detectChangeBetweenString:newSoftwareRevision string:self.device.softwareRevision]) {
        return NO;
    }
    
    // Hardware Revision
    NSString *newHardwareRevision = dictionary[@"hardwareVersion"];
    if ([newHardwareRevision isKindOfClass:[NSNull class]]) {
        newHardwareRevision = nil;
    }
    
    if ([ASUtils detectChangeBetweenString:newHardwareRevision string:self.device.hardwareRevision]) {
        return NO;
    }
    
    // Metadata
    NSString *newMetadataString = dictionary[@"metadata"];
    if ([newMetadataString isKindOfClass:[NSNull class]]) {
        newMetadataString = nil;
    }
    
    NSDictionary *newMetadata = nil;
    if (newMetadataString) {
        newMetadata = [NSDictionary dictionaryWithString:newMetadataString];
    }
    
    BOOL metadataChanged = NO;
    if (newMetadata != self.device.fullMetadata) {
        if (newMetadata && self.device.fullMetadata) {
            metadataChanged = ![newMetadata isEqualToDictionary:self.device.fullMetadata];
        }
        else {
            metadataChanged = YES;
        }
    }
    
    if (metadataChanged) {
        return NO;
    }
    
    return YES;
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
    self.device.lastSynced = newLastSynced;
    
    // Software Revision
    NSString *newSoftwareRevision = dictionary[@"softwareVersion"];
    if ([newSoftwareRevision isKindOfClass:[NSNull class]]) {
        newSoftwareRevision = nil;
    }
    self.device.softwareRevision = newSoftwareRevision;
    
    // Hardware Revision
    NSString *newHardwareRevision = dictionary[@"hardwareVersion"];
    if ([newHardwareRevision isKindOfClass:[NSNull class]]) {
        newHardwareRevision = nil;
    }
    self.device.hardwareRevision = newHardwareRevision;
    
    // Metadata
    NSString *newMetadataString = dictionary[@"metadata"];
    if ([newMetadataString isKindOfClass:[NSNull class]]) {
        newMetadataString = nil;
    }
    
    NSDictionary *newMetadata = nil;
    if (newMetadataString) {
        newMetadata = [NSDictionary dictionaryWithString:newMetadataString];
    }
    self.device.fullMetadata = newMetadata;
}

@end
