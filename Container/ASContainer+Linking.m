//
//  ASContainer+Linking.m
//  Blustream
//
//  Created by Michael Gordon on 7/6/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASContainer+Linking.h"

#import <objc/runtime.h>

#import "ASBLEDefinitions.h"
#import "ASBLEInterface.h"
#import "ASConfig.h"
#import "ASContainerManagerPrivate.h"
#import "ASContainerPrivate.h"
#import "ASContainerAPIService.h"
#import "ASDevicePrivate.h"
#import "ASDeviceManagerPrivate.h"
#import "ASDeviceAPIService.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASSystemManagerPrivate.h"
#import "MSWeakTimer.h"
#import "NSError+ASError.h"

#import "ASServiceV1.h"
#import "ASServiceV3.h"
#import "ASServiceV4.h"
#import "ASRegistrationCharacteristic.h"
#import "ASRegistrationCharacteristicV3.h"

typedef void (^registrationCompletionBlock)(NSError *error);

@interface RegistrationInfo : NSObject

@property (copy, readwrite, nonatomic) registrationCompletionBlock registrationBlock;
@property (weak, readwrite, nonatomic) ASDevice *deviceToLink;
@property (strong, readwrite, nonatomic) NSData *registrationDataToWrite;
@property (assign, readwrite, nonatomic) BOOL registrationWriteCompleted;
@property (assign, readwrite, nonatomic) BOOL registrationDataRead;

@end

@implementation RegistrationInfo

- (id)init {
    self = [super init];
    if (self) {
        self.registrationDataRead = NO;
        self.registrationWriteCompleted = NO;
    }
    return self;
}

@end

@interface ASContainer (_Linking)

@property (strong, readwrite, nonatomic, setter = setRegistrationInfo:) RegistrationInfo *registrationInfo;
@property (strong, readwrite, nonatomic, setter = setRegistrationTimer:) MSWeakTimer *registrationTimer;

@end

@implementation ASContainer (_Linking)

// For more info on associated objects: http://nshipster.com/associated-objects/
// These objects are used to add private properties to categories

- (RegistrationInfo *)registrationInfo {
    return (RegistrationInfo *)objc_getAssociatedObject(self, @selector(registrationInfo));
}

- (void)setRegistrationInfo:(RegistrationInfo *)newRegistrationInfo {
    objc_setAssociatedObject(self, @selector(registrationInfo), newRegistrationInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MSWeakTimer *)registrationTimer {
    return (MSWeakTimer *)objc_getAssociatedObject(self, @selector(registrationTimer));
}

- (void)setRegistrationTimer:(MSWeakTimer *)newRegistrationTimer {
    objc_setAssociatedObject(self, @selector(registrationTimer), newRegistrationTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation ASContainer (Linking)

#pragma mark Linking Methods

// TODO Cleanup all this code

- (void)linkDevice:(ASDevice *)device completion:(void (^)(NSError *error))completion {
    NSParameterAssert(device);
    
    dispatch_async(self.processingQueue, ^{
        if (self.registrationInfo) {
            // Device
            if (completion) {
                NSError *error = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorIsLinking underlyingError:nil];
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
            return;
        }
        
        if (self.device || self.linkedDeviceSerialNumber) {
            // Device is already linked
            if (completion) {
                NSError *error = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorAlreadyLinked underlyingError:nil];
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
            return;
        }
        
        if (![ASSystemManager.shared.containerManager.containers containsObject:self]) {
            // Container is not in container array
            if (completion) {
                NSError *error = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorNotAdded underlyingError:nil];
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
            return;
        }

        for (ASContainer *container in ASSystemManager.shared.containerManager.containers) {
            if ((container != self) && (container.device == device)) {
                // Device is already linked to another container
                if (completion) {
                    NSError *error = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorDeviceAlreadyLinked underlyingError:nil];
                    dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                        completion(error);
                    });
                }
                return;
            }
        }
        
        self.registrationInfo = [[RegistrationInfo alloc] init];
        self.registrationInfo.registrationBlock = completion;
        self.registrationInfo.deviceToLink = device;
        
        ASLog(@"Getting registration key from server");
        
        ASDeviceAPIService *deviceAPIService = [[ASDeviceAPIService alloc] initWithDevice:device systemManager:ASSystemManager.shared];
        [deviceAPIService getRegistrationFromServerWithSuccess:^(NSString * _Nonnull registrationCode) {
            NSData *base64Decrypted = [[NSData alloc] initWithBase64EncodedString:registrationCode options:0];
            ASLog(@"Got registration data: %@", base64Decrypted);
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationModeReady:) name:@"deviceRegistrationModeReady" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationModeFailed:) name:@"deviceRegistrationModeFailed" object:nil];
            
            self.registrationInfo.registrationDataToWrite = base64Decrypted;
            
            self.registrationTimer = [MSWeakTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(registrationTimeout:) userInfo:nil repeats:NO dispatchQueue:self.processingQueue];
            
            [ASSystemManager.shared.BLEInterface connectToDevice:device mode:ASDeviceConnectionModeRegistration];
        } failure:^(NSError * _Nonnull error) {
            NSError *ASError = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorRegistrationDataUnavailable underlyingError:error];
            [self registrationCallbackHandlerWithError:ASError];
        }];
    });
}

- (void)unlinkDeviceWithCompletion:(void (^)(NSError *error))completion {
    dispatch_async(self.processingQueue, ^{
        ASContainerAPIService *apiService = [[ASContainerAPIService alloc] initWithContainer:self systemManager:ASSystemManager.shared];
        [apiService deleteDeviceLinkWithSuccess:^{
            [self unsafeSetLink:nil];
            [self save];
            ASLog(@"Successfully unlinked %@", self.identifier);
            if (completion) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        } failure:^(NSError *error) {
            error = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorNetworkFailed underlyingError:error];
            ASLog(@"Failed to unlink device: %@ from %@", self.device.serialNumber, self.identifier);
            if (completion) {
                dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
        }];
    });
}

- (void)linkDeviceNetworkOnly:(ASDevice *)device completion:(void (^)(NSError *error))completion {
    
    ASContainerAPIService *apiService = [[ASContainerAPIService alloc] initWithContainer:self systemManager:ASSystemManager.shared];
    
    [apiService putDeviceLink:device authenticationKey:device.registrationData success:^{
        [self unsafeSetLink:device];
        [self save];
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    } failure:^(NSError *error) {
        error = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorNetworkFailed underlyingError:error];
        if (completion) {
            dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    }];
}

- (void)linkDeviceLocalOnly:(ASDevice *)device completion:(void (^)(NSError *error))completion {
    [self unsafeSetLink:device];
    
    [self save];
    
    if (completion) {
        dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
            completion(nil);
        });
    }
}

- (void)unlinkDeviceLocalOnlyWithCompletion:(void (^)(NSError *error))completion {
    [self unsafeSetLink:nil];
    
    [self save];
    
    if (completion) {
        dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
            completion(nil);
        });
    }
}

#pragma mark - Internal Methods

#pragma mark Notification Handlers

- (void)registrationModeReady:(NSNotification *)notification {
    ASDevice *device = notification.object;
    
    if (device == self.registrationInfo.deviceToLink) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deviceRegistrationModeReady" object:nil];
        
        __block ASDevice *blockSafeDevice = self.registrationInfo.deviceToLink;
        ASLog(@"Writing registration data");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationDataRead:) name:@"registrationDataRead" object:nil];
        
        id<ASWriteableCharacteristic> characteristic = nil;
        
        NSString *characteristicString = nil;
        NSString *serviceString = nil;
        
        if ([@"4.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
            serviceString = [ASServiceV4 identifier];
            characteristicString = [ASRegistrationCharacteristicV3 identifier];
        }
        else if ([@"3.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
            serviceString = [ASServiceV3 identifier];
            characteristicString = [ASRegistrationCharacteristicV3 identifier];
        }
        else {
            serviceString = [ASServiceV1 identifier];
            characteristicString = [ASRegistrationCharacteristic identifier];
        }
        
        characteristic = (id<ASWriteableCharacteristic>)device.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];

        if (!characteristic) {
            NSError *error = [NSError ASErrorWithDomain:ASDeviceErrorDomain code:ASDeviceErrorCharacteristicNotYetDiscovered underlyingError:nil];
            [self registrationCallbackHandlerWithError:error];
            return;
        }

        [characteristic write:self.registrationInfo.registrationDataToWrite withCompletion:^(NSError *error) {
            if (error) {
                if (([error.domain compare:CBATTErrorDomain] == NSOrderedSame) && (error.code == CBATTErrorInvalidPdu)) {
                    error = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorDeviceWriteError underlyingError:error];
                }
                else {
                    error = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorUnknown underlyingError:error];
                }
                
                ASLog(@"Couldn't write registration data for %@: %@", blockSafeDevice.serialNumber, error);
                [self registrationCallbackHandlerWithError:error];
            }
            else {
                [self.registrationTimer invalidate];
                self.registrationTimer = nil;
                self.registrationInfo.registrationWriteCompleted = YES;
                if (self.registrationInfo.registrationDataRead) {
                    [self finishLinkForDevice:blockSafeDevice];
                }
            }
        }];
    }
}

- (void)registrationModeFailed:(NSNotification *)notification {
    ASDevice *device = notification.object;
    if (device == self.registrationInfo.deviceToLink) {
        [self registrationCallbackHandlerWithError:notification.userInfo[@"error"]];
    }
}

- (void)registrationDataRead:(NSNotification *)notification {
    ASDevice *device = notification.object;
    if (device == self.registrationInfo.deviceToLink) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"registrationDataRead" object:nil];
        self.registrationInfo.registrationDataRead = YES;
        if (self.registrationInfo.registrationWriteCompleted) {
            [self finishLinkForDevice:device];
        }
    }
}

#pragma mark Other Methods

- (void)registrationTimeout:(NSTimer *)timer {
    dispatch_async(self.processingQueue, ^{
        ASLog(@"Registration Mode Timed Out!");
        NSError *error = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorLinkTimedOut underlyingError:nil];
        [self registrationCallbackHandlerWithError:error];
    });
}

- (void)finishLinkForDevice:(ASDevice *)device {
    ASContainerAPIService *apiService = [[ASContainerAPIService alloc] initWithContainer:self systemManager:ASSystemManager.shared];
    [apiService putDeviceLink:device authenticationKey:device.registrationData success:^{
        [self unsafeSetLink:device];
        [device.container save];
        ASDeviceManager *deviceManager = [[ASDeviceManager alloc] initWithSystemManager:ASSystemManager.shared];
        [deviceManager saveDevice:device];
        [self registrationCallbackHandlerWithError:nil];
    } failure:^(NSError *error) {
        error = [NSError ASErrorWithDomain:ASContainerErrorDomain code:ASContainerErrorNetworkFailed underlyingError:error];
        [self registrationCallbackHandlerWithError:error];
    }];
}

- (void)registrationCallbackHandlerWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deviceRegistrationModeReady" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deviceRegistrationModeFailed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"registrationDataRead" object:nil];
    [ASSystemManager.shared.BLEInterface disconnectFromDevice:self.registrationInfo.deviceToLink];
    [self.registrationTimer invalidate];
    self.registrationTimer = nil;
    
    if (error) {
        ASLog(@"Registration completed with error %@", error);
    }
    else {
        ASLog(@"Registration completed successfully");
    }
    
    if (self.registrationInfo.registrationBlock) {
        dispatch_async(ASSystemManager.shared.config.completionQueue ?: dispatch_get_main_queue(), ^{
            registrationCompletionBlock block = self.registrationInfo.registrationBlock;
            self.registrationInfo = nil;
            block(error);
        });
    }
}

@end
