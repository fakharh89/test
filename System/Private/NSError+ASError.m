//
//  NSError+ASError.m
//  Blustream
//
//  Created by Michael Gordon on 7/27/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "NSError+ASError.h"

#import "ASErrorDefinitions.h"
#import "ASLog.h"

static NSString * const ASAlamofireSerializationResponseError = @"com.alamofire.serialization.response.error.data";

@implementation NSError (ASError)

#pragma mark - Public Methods

+ (NSError *)ASErrorWithDomain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)underlyingError {
    NSDictionary *userInfo = nil;
    
    if ([domain compare:ASContainerErrorDomain] == NSOrderedSame) {
        userInfo = [self userInfoForASContainerErrorDomainWithCode:code];
    }
    else if ([domain compare:ASContainerManagerErrorDomain] == NSOrderedSame) {
        userInfo = [self userInfoForASContainerManagerErrorDomainWithCode:code];
    }
    else if ([domain compare:ASDeviceErrorDomain] == NSOrderedSame) {
        userInfo = [self userInfoForASDeviceErrorDomainWithCode:code];
    }
    else if ([domain compare:ASDeviceBLEDataErrorDomain] == NSOrderedSame) {
        userInfo = [self userInfoForASDeviceBLEDataErrorDomainWithCode:code];
    }
    else if ([domain compare:ASDeviceNotifyErrorDomain] == NSOrderedSame) {
        userInfo = [self userInfoForASDeviceNotifyErrorDomainWithCode:code];
    }
    else if ([domain compare:ASDeviceWriteErrorDomain] == NSOrderedSame) {
        userInfo = [self userInfoForASDeviceWriteErrorDomainWithCode:code];
    }
    else if ([domain compare:ASDeviceReadErrorDomain] == NSOrderedSame) {
        userInfo = [self userInfoForASDeviceReadErrorDomainWithCode:code];
    }
    else if ([domain compare:ASCloudErrorDomain] == NSOrderedSame) {
        userInfo = [self userInfoForASCloudErrorDomainWithCode:code];
    }
    else if ([domain compare:ASAccountCreationErrorDomain] == NSOrderedSame) {
        userInfo = [self userInfoForASAccountCreationErrorDomainWithCode:code];
    }
    
    NSError *error = nil;
    
    if (userInfo) {
        userInfo = [self readableUserInfoWith:userInfo];
        error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
        if (underlyingError) {
            error = [error errorWithUnderlyingError:underlyingError];
        }
    }
    else {
        ASLog(@"Nil error returned by accident. Please report this line to Acoustic Stream's developer: %@, %ld, %@", domain, (long)code, underlyingError);
    }
    
    return error;
}

+ (NSMutableDictionary *)readableUserInfoWith:(NSDictionary *)userInfo {
    NSMutableDictionary *userInfoAddition = [userInfo mutableCopy];
    NSData *errorResponseData = (NSData *)userInfo[ASAlamofireSerializationResponseError];
    if (errorResponseData) {
        NSString *errorReadableResponse = [[NSString alloc] initWithData:errorResponseData encoding:NSUTF8StringEncoding];
        userInfoAddition[ASReadableErrorDescription] = errorReadableResponse;
        userInfo = userInfoAddition;
    }
    return userInfoAddition;
}

#pragma mark - Private Methods

+ (NSDictionary *)userInfoForASContainerErrorDomainWithCode:(ASContainerError)code {
    NSDictionary *userInfo = nil;
    
    switch ((ASContainerError) code) {
        case ASContainerErrorUnknown: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown container error.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown failure reason.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check underlying error key.", nil)};
            break;
        }
        case ASContainerErrorAlreadyLinked: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot link device to container.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Container is already linked.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Unlink container and device first.", nil)};
            break;
        }
        case ASContainerErrorDeviceAlreadyLinked: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot link device to container.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device is linked to another container.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Unlink other container and device first.", nil)};
            break;
        }
        case ASContainerErrorNotAdded: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot link device to container.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Container is not added to container list.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Add container to container manager first.", nil)};
            break;
        }
        case ASContainerErrorIsLinking: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot link device to container.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Container is in the process of linking or unlinking.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Unlink container and device first.", nil)};
            break;
        }
        case ASContainerErrorLinkTimedOut: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot link device to container.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Registration timed out.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure device is nearby and on.", nil)};
            break;
        }
        case ASContainerErrorRegistrationDataUnavailable: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot link device to container.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Registration data is unavailable from server.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again.", nil)};
            break;
        }
        case ASContainerErrorDeviceConnectionFailed: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot link device to container.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device connection failed while linking.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again.", nil)};
            break;
        }
        case ASContainerErrorDeviceInvalidBLEData: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot link device to container.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device sent invalid data.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again.", nil)};
            break;
        }
        case ASContainerErrorDeviceNotifyError: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot link device to container.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Setting notification state failed.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again later.", nil)};
            break;
        }
        case ASContainerErrorDeviceWriteError: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot link device to container.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Write command failed - battery may not be reset.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure battery is reset and try again.", nil)};
            break;
        }
        case ASContainerErrorNetworkFailed: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot link device to container.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Network failure.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again later.", nil)};
            break;
        }
        default: {
            break;
        }
    }
    
    return userInfo;
}

+ (NSDictionary *)userInfoForASContainerManagerErrorDomainWithCode:(ASContainerManagerError)code {
    NSDictionary *userInfo = nil;
    
    switch (code) {
        case ASContainerManagerErrorUnknown: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown container manager error.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown failure reason.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check underlying error key.", nil)};
            break;
        }
        case ASContainerManagerErrorContainerAlreadyAdded: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot add container to array.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Container with that UUID is already in array.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Add a different container.", nil)};
            break;
        }
        case ASContainerManagerErrorContainerNotAdded: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot remove container from array.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Container is not in array.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Remove a different container.", nil)};
            break;
        }
        default: {
            break;
        }
    }
    
    return userInfo;
}

+ (NSDictionary *)userInfoForASDeviceErrorDomainWithCode:(ASDeviceError)code {
    NSDictionary *userInfo = nil;
    
    switch (code) {
        case ASDeviceErrorUnknown: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown device error.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown failure reason.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check underlying error key.", nil)};
            break;
        }
        case ASDeviceErrorIncompatible: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot autoconnect to device.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device is incompatible with this framework or license.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Connect to another device.", nil)};
            break;
        }
        case ASDeviceErrorUnlinked: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot autoconnect to device.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device is unlinked.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Register the device.", nil)};
            break;
        }
        case ASDeviceErrorDeviceInitiatedDisconnect: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device disconnected.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device initiated disconnect.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"If Taylor unit, unplug 1/4\" jack, else contact developer.", nil)};
            break;
        }
        case ASDeviceErrorCharacteristicsMissing: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot discover characteristics.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Characteristics are missing.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure hardware is up to date and try again.", nil)};
            break;
        }
        case ASDeviceErrorCharacteristicError: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot discover characteristics.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Could not discover characteristics.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again.", nil)};
            break;
        }
        case ASDeviceErrorServicesMissing: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot discover services.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Services are missing.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure hardware is up to date and try again.", nil)};
            break;
        }
        case ASDeviceErrorServiceError: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot discover services.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Could not discover services.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again.", nil)};
            break;
        }
        case ASDeviceErrorCharacteristicDataMissing: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot process BLE data.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Characteristic data is missing.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact developer.", nil)};
            break;
        }
        case ASDeviceErrorUserInitiatedDisconnected: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device disconnected.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"User likely disconnected device.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Toggle Bluetooth, replace battery, or contact developer.", nil)};
            break;
        }
        case ASDeviceErrorCharacteristicNotYetDiscovered: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Characteristic not yet discovered.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device may be unconnected or still setting up.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check connection and wait until characteristic is discovered.", nil)};
            break;
        }
        case ASDeviceErrorUpdateAlreadyInProgress: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot start OTAU.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Another OTAU is in progress.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Wait for current OTAU to complete.", nil)};
            break;
        }
        case ASDeviceErrorNoUpdateAvailable: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"OTAU unavailable.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device is already on latest software revision.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"OTAU is unavailable.", nil)};
            break;
        }
        case ASDeviceErrorBootloaderVersionIncompatible: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"OTAU unavailable.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Bootloader version is incompatible.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact developer.", nil)};
            break;
        }
        case ASDeviceErrorBootloaderNotReady: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"OTAU failed.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Bootloader not ready.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact developer.", nil)};
            break;
        }
        case ASDeviceErrorMissingUserKey: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"OTAU failed.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"User key is not cached and cannot be read.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact Blustream support.", nil)};
            break;
        }
        case ASDeviceErrorApplicationImageInvalid: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"OTAU failed.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Application image invalid.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact developer.", nil)};
            break;
        }
        case ASDeviceErrorInvalidDeviceType: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"OTAU failed.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown device type.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact developer.", nil)};
        }
        default: {
            break;
        }
    }
    
    return userInfo;
}

+ (NSDictionary *)userInfoForASDeviceBLEDataErrorDomainWithCode:(ASDeviceBLEDataError)code {
    NSDictionary *userInfo = nil;
    
    switch (code) {
        case ASDeviceBLEDataErrorUnknown: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown device BLE data error.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown failure reason.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check underlying error key.", nil)};
            break;
        }
        case ASDeviceBLEDataErrorBufferSizeInvalid: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot process BLE data.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Data buffer size is invalid.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact developer.", nil)};
            break;
        }
        case ASDeviceBLEDataErrorDataOutOfRange: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot process BLE data.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Data is out of range.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact developer.", nil)};
            break;
        }
        case ASDeviceBLEDataErrorDateInvalid: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot process BLE data.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Date is invalid.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact developer.", nil)};
            break;
        }
        case ASDeviceBLEDataErrorDateWentBackInTime: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot process BLE data.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Date went back in time.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact developer.", nil)};
            break;
        }
        case ASDeviceBLEDataErrorDateWentForwardInTime: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot process BLE data.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Date went forward in time.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact developer.", nil)};
            break;
        }
        case ASDeviceBLEDataErrorDateNotUnique: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot process BLE data.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Date is not unique.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ignore this data packet. Contact developer if this repeats.", nil)};
            break;
        }
        case ASDeviceBLEDataErrorDataIsCorrupt: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot process BLE data.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Data is corrupt.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ignore this data packet. It is likely corrupt and will be fixed in the next firmware release.", nil)};
            break;
        }
        default: {
            break;
        }
    }
    
    return userInfo;
}

+ (NSDictionary *)userInfoForASDeviceNotifyErrorDomainWithCode:(ASDeviceNotifyError)code {
    NSDictionary *userInfo = nil;
    
    switch (code) {
        case ASDeviceNotifyErrorUnknown: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown device notify error.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown failure reason.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check underlying error key.", nil)};
            break;
        }
        case ASDeviceNotifyErrorPIONotSupported: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Setting notify was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device does not have PIO capabilities.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try a different device.", nil)};
            break;
        }
        case ASDeviceNotifyErrorAIONotSupported: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Setting notify was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"AIO notification is not possible.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Use AIO read or write instead.", nil)};
            break;
        }
        case ASDeviceNotifyErrorSoftwareNotSupported: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Setting notify was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device is software device.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Set notify for hardware devices only.", nil)};
            break;
        }
        case ASDeviceNotifyErrorNotConnected: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Setting notify was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device is not connected.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again when connected to device.", nil)};
            break;
        }
        case ASDeviceNotifyErrorAlreadyPending: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Setting notify was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Another notify command is pending to that characteristic.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Wait for other notify command to complete.", nil)};
            break;
        }
        case ASDeviceNotifyErrorCharacteristicUndiscovered: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Setting notify was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"BLE characteristic isn't yet discovered.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again later.", nil)};
            break;
        }
        case ASDeviceNotifyErrorVersionUnknown: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Setting notify was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Software revision is unknown.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Set notify for different device or wait.", nil)};
            break;
        }
        case ASDeviceNotifyErrorVersionUnsupported: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Setting notify was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device version is unsupported for this type of notify.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Set notify for different device.", nil)};
            break;
        }
        default: {
            break;
        }
    }
    
    return userInfo;
}

+ (NSDictionary *)userInfoForASDeviceWriteErrorDomainWithCode:(ASDeviceWriteError)code {
    NSDictionary *userInfo = nil;
    
    switch (code) {
        case ASDeviceWriteErrorUnknown: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown device write error.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown failure reason.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check underlying error key.", nil)};
            break;
        }
        case ASDeviceWriteErrorPIONotSupported: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device does not have PIO capabilities.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Write to different device.", nil)};
            break;
        }
        case ASDeviceWriteErrorAIOLengthInvalid: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"AIO array length invalid.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Write 3 simultaneous AIO values to device.", nil)};
            break;
        }
        case ASDeviceWriteErrorAIOValueInvalid: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"AIO value invalid.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Write AIO values in range [0, 1350] mV", nil)};
            break;
        }
        case ASDeviceWriteErrorAIONotSupported: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device does not have AIO capabilities.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Write to different device.", nil)};
            break;
        }
        case ASDeviceWriteErrorBlinkNotSupported: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device cannot blink.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Write to different device.", nil)};
            break;
        }
        case ASDeviceWriteErrorSoftwareNotSupported: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device is software device.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Write to hardware devices only.", nil)};
            break;
        }
        case ASDeviceWriteErrorNotConnected: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device is not connected.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again when connected to device.", nil)};
            break;
        }
        case ASDeviceWriteErrorAlreadyPending: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Another write command is pending to that characteristic.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Wait for other write command to complete.", nil)};
            break;
        }
        case ASDeviceWriteErrorCharacteristicUndiscovered: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"BLE characteristic isn't yet discovered.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again later.", nil)};
            break;
        }
        case ASDeviceWriteErrorVersionUnknown: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Software revision is unknown.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Write to different device or wait.", nil)};
            break;
        }
        case ASDeviceWriteErrorVersionUnsupported: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device version is unsupported for this type of write.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Write to different device.", nil)};
            break;
        }
        case ASDeviceWriteErrorDataOutOfRange: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Device write was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Data is out of range.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Write data within a valid range.", nil)};
            break;
        }
        default: {
            break;
        }
    }
    
    return userInfo;
}

+ (NSDictionary *)userInfoForASDeviceReadErrorDomainWithCode:(ASDeviceReadError)code {
    NSDictionary *userInfo = nil;
    
    switch (code) {
        case ASDeviceReadErrorUnknown: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown device read error.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown failure reason.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check underlying error key.", nil)};
            break;
        }
        case ASDeviceReadErrorSoftwareNotSupported: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Reading was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device is software device.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Read hardware devices only.", nil)};
            break;
        }
        case ASDeviceReadErrorNotConnected: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Reading was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device is not connected.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again when connected to device.", nil)};
            break;
        }
        case ASDeviceReadErrorAlreadyPending: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Reading was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Another read command is pending to that characteristic.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Wait for other read command to complete.", nil)};
            break;
        }
        case ASDeviceReadErrorCharacteristicUndiscovered: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Reading was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"BLE characteristic isn't yet discovered.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again later.", nil)};
            break;
        }
        case ASDeviceReadErrorVersionUnknown: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Reading was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Software revision is unknown.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Read different device or wait.", nil)};
            break;
        }
        case ASDeviceReadErrorVersionUnsupported: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Reading was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device version is unsupported for this type of read.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Read different device.", nil)};
            break;
        }
        default: {
            break;
        }
    }
    return userInfo;
}

+ (NSDictionary *)userInfoForASCloudErrorDomainWithCode:(ASCloudError)code {
    NSDictionary *userInfo = nil;
    
    switch (code) {
        case ASCloudErrorUnknown: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unknown cloud error.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown failure reason.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check underlying error key.", nil)};
            break;
        }
        case ASCloudErrorAccountAlreadyExists: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Account already exists.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Use a different email address.", nil)};
            break;
        }
        case ASCloudErrorAccountCreationTooManyAttemps: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Creating Customer Limit exceeded. Please try again later.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try using a different email address.", nil)};
            break;
        }
        case ASCloudErrorServerError: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Server communication error.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device DTO serial number did not match path.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Contact developer.  Internal error.", nil)};
            break;
        }
        case ASCloudErrorInvalidCredentials: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Server communication error.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"User is logged out.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try logging in again.", nil)};
            break;
        }
        case ASCloudErrorDeviceNotFound: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Server communication error.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Device not found.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try linking device first.", nil)};
            break;
        }
        case ASCloudErrorContainerNotFound: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Server communication error.", nil),
                          NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Container(s) not found.", nil),
                          NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try adding a container first.", nil)};
            break;
        }
        case ASCloudErrorImageURLMissing: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Server communication error.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Image URL is missing.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try setting user/container image first.", nil)};
            break;
        }
        case ASCloudErrorNoDataAvailable: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Server communication error.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No data available.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try changing the date range.", nil)};
            break;
        }
        case     ASCloudErrorSyncingAlreadyInProgress: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Syncing already in progress.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Two syncing object cannot happen at the same time.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Wait for the asynchronous task to be done and try again.", nil)};
            break;
        }
        default: {
            break;
        }
    }
    
    return userInfo;
}

+ (NSDictionary *)userInfoForASAccountCreationErrorDomainWithCode:(ASAccountCreationError)code {
    NSDictionary *userInfo = nil;
    
    switch (code) {
        case ASAccountCreationErrorInvalidFirstName: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"First name too long.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a valid first name.", nil)};
            break;
        }
        case ASAccountCreationErrorMissingFirstName: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Missing first name.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a first name.", nil)};
            break;
        }
        case ASAccountCreationErrorInvalidLastName: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Last name too long.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a valid last name.", nil)};
            break;
        }
        case ASAccountCreationErrorMissingLastName: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Missing last name.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a last name.", nil)};
            break;
        }
        case ASAccountCreationErrorInvalidEmail: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Invalid email address.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a valid email address.", nil)};
            break;
        }
        case ASAccountCreationErrorMissingEmail: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Missing email address.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter an email address.", nil)};
            break;
        }
        case ASAccountCreationErrorPasswordTooShort: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Password is less than 8 characters.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a valid password.", nil)};
            break;
        }
        case ASAccountCreationErrorPasswordMissingCapitalLetter: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Password requires at least one capital letter.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a valid password.", nil)};
            break;
        }
        case ASAccountCreationErrorPasswordMissingLowercaseLetter: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Password requires at least one lowercase letter.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a valid password.", nil)};
            break;
        }
        case ASAccountCreationErrorPasswordMissingNumber: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Password requires at least one number.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a valid password.", nil)};
            break;
        }
        case ASAccountCreationErrorMissingPassword: {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account creation was unsuccessful.", nil),
                         NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Missing password.", nil),
                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Enter a password.", nil)};
            break;
        }
        default: {
            break;
        }
    }
    
    return userInfo;
}

- (NSError *)errorWithUnderlyingError:(NSError *)underlyingError {
    if (!underlyingError || (self == underlyingError)) {
        return self;
    }
    
    if (self.userInfo[NSUnderlyingErrorKey]) {
        ASLog(@"Error already has underlying error:\nSelf: %@\nUnderlyingError: %@", self, self.userInfo[NSUnderlyingErrorKey]);
        return self;
    }
    
    NSMutableDictionary *mutableUserInfo = [self.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    
    return [NSError errorWithDomain:self.domain code:self.code userInfo:mutableUserInfo];
}

@end
