//
//  ASContainerManager.m
//  Blustream
//
//  Created by Michael Gordon on 6/25/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASContainerManagerPrivate.h"

#import "ASConfig.h"
#import "ASContainerPrivate.h"
#import "ASContainerAPIService.h"
#import "ASDevice.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASSystemManagerPrivate.h"
#import "NSArray+ASSearch.h"
#import "NSError+ASError.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

dispatch_queue_t container_manager_member_queue() {
    static dispatch_queue_t as_container_manager_member_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        as_container_manager_member_queue = dispatch_queue_create("com.acoustic-stream.container-manager.member", DISPATCH_QUEUE_CONCURRENT);
    });
    return as_container_manager_member_queue;
}

dispatch_queue_t container_manager_processing_queue() {
    static dispatch_queue_t as_container_manager_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        as_container_manager_processing_queue = dispatch_queue_create("com.acoustic-stream.container-manager.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    return as_container_manager_processing_queue;
}

@implementation ASContainerManager

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _containersInternal = [[NSMutableArray alloc] init];
        _systemManager = systemManager;
    }
    
    return self;
}

#pragma mark - Public Methods

- (NSArray *)containers {
    __block NSArray *array;
    dispatch_sync(container_manager_member_queue(), ^{
        array = [NSArray arrayWithArray:self->_containersInternal];
    });
    return array;
}

- (NSArray *)linkedContainers {
    return [self.containers arrayWithLinkedContainers];
}

- (NSArray *)unlinkedContainers {
    return [self.containers arrayWithUnlinkedContainers];
}

- (void)addContainer:(ASContainer *)container completion:(void (^)(NSError *error))completion {
    NSParameterAssert(container);
    
    ASContainerAPIService *containerAPIService = [[ASContainerAPIService alloc] initWithContainer:container systemManager:self.systemManager];
    
    dispatch_async(container_manager_processing_queue(), ^{
        for (ASContainer *existingContainer in self.containers) {
            if ([existingContainer.identifier compare:container.identifier] == NSOrderedSame) {
                if (completion) {
                    NSError *error = [NSError ASErrorWithDomain:ASContainerManagerErrorDomain code:ASContainerManagerErrorContainerAlreadyAdded underlyingError:nil];
                    dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                        completion(error);
                    });
                }
                return;
            }
        }
        
        [containerAPIService putWithSuccess:^{
            [self unsafeAddContainer:container];
            [self saveContainers];
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        } failure:^(NSError *error) {
            error = [NSError ASErrorWithDomain:ASContainerManagerErrorDomain code:ASContainerManagerErrorUnknown underlyingError:error];
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
        }];
    });
}

- (void)removeContainer:(ASContainer *)container completion:(void (^)(NSError *error))completion {
    NSParameterAssert(container);
    
    dispatch_async(container_manager_processing_queue(), ^{
        if (![self.containers containsObject:container]) {
            if (completion) {
                NSError *error = [NSError ASErrorWithDomain:ASContainerManagerErrorDomain code:ASContainerManagerErrorContainerNotAdded underlyingError:nil];
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
        }
        
        ASContainerAPIService *containerAPIService = [[ASContainerAPIService alloc] initWithContainer:container systemManager:self.systemManager];
        
        [containerAPIService deleteWithSuccess:^{
            if (container.device) {
                [container.device setAutoConnect:NO error:nil];
            }
            [self unsafeRemoveContainer:container];
            [container deleteLocalCache];
            [container unsafeSetLink:nil];
            [self saveContainers];
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        } failure:^(NSError *error) {
            error = [NSError ASErrorWithDomain:ASContainerManagerErrorDomain code:ASContainerManagerErrorUnknown underlyingError:error];
            if (completion) {
                dispatch_async(self.systemManager.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
        }];
    });
}

- (void)exchangeContainerAtIndex:(NSUInteger)idx1 withContainerAtIndex:(NSUInteger)idx2 {
    dispatch_sync(container_manager_member_queue(), ^{
        [self->_containersInternal exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    });
}

#pragma mark - Private Methods

- (void)unsafeAddContainer:(ASContainer *)container {
    NSParameterAssert(container);
    
    dispatch_barrier_sync(container_manager_member_queue(), ^{
        [self->_containersInternal addObject:container];
    });
}

- (void)unsafeRemoveContainer:(ASContainer *)container {
    NSParameterAssert(container);
    
    dispatch_barrier_sync(container_manager_member_queue(), ^{
        [self->_containersInternal removeObject:container];
    });
}

- (void)resetContainers {
    dispatch_barrier_sync(container_manager_member_queue(), ^{
        for (ASContainer *container in self->_containersInternal) {
            [container deleteLocalCache];
        }
        
        self->_containersInternal = [[NSMutableArray alloc] init];
        [self saveContainers];
    });
}

- (BOOL)syncContainersFromDictionaryArray:(NSArray *)dictionaryArray updatedContainers:(NSArray * __autoreleasing *)updatedContainers {
    BOOL changed = NO;
    
    NSMutableArray *removedContainers = [NSMutableArray arrayWithArray:self.containers];
    NSMutableArray *mutableUpdatedContainers = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dictionary in dictionaryArray) {
        NSString *identifer = dictionary[@"containerId"];
        if (!identifer || [identifer isKindOfClass:[NSNull class]]) {
            ASLog(@"Container Array Sync Error: Bad container ID from server");
            continue;
        }
        
        NSInteger index = [self.containers indexOfIdentifer:identifer];
        if (index == -1) {
            // New Container!
            ASContainer *container = [[ASContainer alloc] initWithDictionary:dictionary];
            if ([container isCompatible]) {
                [mutableUpdatedContainers addObject:container];
                [self unsafeAddContainer:container];
                changed = YES;
                [container syncContainerImageFromDictionary:dictionary imageDownloadCompletion:^(NSError *error) {
                    if (!error) {
                        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASContainerImageSyncedNotification object:container];
                    }
                }];
            }
        }
        else {
            // Container already exists
            ASContainer *container = [self.containers objectAtIndex:index];
            [removedContainers removeObject:container];
            
            if ([container syncContainerFromDictionary:dictionary]) {
                [mutableUpdatedContainers addObject:container];
                changed = YES;
            }
            
            [container syncContainerImageFromDictionary:dictionary imageDownloadCompletion:^(NSError *error) {
                if (!error) {
                    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASContainerImageSyncedNotification object:container];
                }
            }];
        }
    }
    
    for (ASContainer *container in removedContainers) {
        if (container.device) {
            [container.device setAutoConnect:NO error:nil];
            [container unsafeSetLink:nil];
        }
        [self unsafeRemoveContainer:container];
        [container deleteLocalCache];
        changed = YES;
    }
    
    if (updatedContainers) {
        *updatedContainers = [NSArray arrayWithArray:mutableUpdatedContainers];
    }
    
    return changed;
}

#pragma mark Saving Methods

// Loads devices from predetermined path
- (void)loadContainers {
    NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getDataPath]];
    
    if (data) {
        NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
        NSMutableArray *mutableContainers = [[NSMutableArray alloc] init];
        for (NSString *containerIdentifier in data) {
            NSString *filename = [docsPath stringByAppendingPathComponent:containerIdentifier];
            ASContainer *container = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
            
            if (container) {
                [mutableContainers addObject:container];
            }
            else {
                ASLog(@"Failed to load container: %@", containerIdentifier);
            }
        }
        _containersInternal = mutableContainers;
    }
    else {
        ASLog(@"Failed to load container identifiers!");
    }
}

// Saves autoconnect devices to predetermined path
- (void)saveContainers {
    dispatch_async(container_manager_member_queue(), ^{
        NSMutableArray *containerIdentifiers = [[NSMutableArray alloc] init];
        for (ASContainer *container in self->_containersInternal) {
            [containerIdentifiers addObject:container.identifier];
            [container save];
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:containerIdentifiers]];
        if (![data writeToFile:[self getDataPath] atomically:YES]) {
            ASLog(@"Failed to save container identifiers!");
        }
        
        // Set folder to not backup to iCloud.  Writing erases this attribute
        [ASSystemManager addSkipBackupAttributeToItemAtPath:[self getDataPath]];
    });
}

// Returns save path for data as an NSString
- (NSString *)getDataPath {
    NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
    NSString *filename = [docsPath stringByAppendingPathComponent:@"ContainerIdentifiers"];
    return filename;
}

@end
