//
//  ASRegistrationConnectionRoutine.m
//  Blustream
//
//  Created by Michael Gordon on 7/14/16.
//
//

#import "ASRegistrationConnectionRoutine.h"

#import "ASBLEDefinitions.h"
#import "ASConfig.h"
#import "ASDevice.h"
#import "ASLog.h"
#import "ASSystemManagerPrivate.h"
#import "ASRealtimeMode.h"
#import "ASAttribute.h"
#import "ASServiceV1.h"
#import "ASServiceV3.h"
#import "ASServiceV4.h"
#import "ASRegistrationCharacteristic.h"
#import "ASRegistrationCharacteristicV3.h"

@implementation ASRegistrationConnectionRoutine

+ (NSArray<CBUUID *> *)supportedServices {
    static NSArray *services;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        services = @[[CBUUID UUIDWithString:ASServiceUUID],
                     [CBUUID UUIDWithString:ASServiceUUIDv3],
                     [CBUUID UUIDWithString:ASServiceUUIDv4],
                     [CBUUID UUIDWithString:ASDevInfoServiceUUID]];
    });
    
    return services;
}

+ (NSArray<CBUUID *> *)supportedCharacteristicsForService:(NSString *)service {
    static NSArray *ASCharacteristics, *ASCharacteristicsV3, *ASCharacteristicsV4, *ASDevInfoCharacteristics;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ASCharacteristics = @[[CBUUID UUIDWithString:ASRegistrationCharactUUID]];
        ASCharacteristicsV3 = @[[CBUUID UUIDWithString:ASRegistrationCharacteristicUUIDv3]];
        ASCharacteristicsV4 = @[[CBUUID UUIDWithString:ASRegistrationCharacteristicUUIDv3]];
        ASDevInfoCharacteristics = @[[CBUUID UUIDWithString:ASSoftwareRevCharactUUID]];
    });
    
    if ([service caseInsensitiveCompare:ASServiceUUID] == NSOrderedSame) {
        return ASCharacteristics;
    }
    else if ([service caseInsensitiveCompare:ASServiceUUIDv3] == NSOrderedSame) {
        return ASCharacteristicsV3;
    }
    else if ([service caseInsensitiveCompare:ASServiceUUIDv4] == NSOrderedSame) {
        return ASCharacteristicsV4;
    }
    else if ([service caseInsensitiveCompare:ASDevInfoServiceUUID] == NSOrderedSame) {
        return ASDevInfoCharacteristics;
    }
    
    return nil;
}

+ (void)didFinishSetupForDevice:(ASDevice *)device {
    ASLog(@"Setting registration notify for device %@ in registration mode", device.serialNumber);
    __block ASDevice *blockSafeDevice = device;
    id<ASNotifiableCharacteristic> characteristic = nil;
    
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
    
    characteristic = (id<ASNotifiableCharacteristic>)device.services[serviceString.lowercaseString].characteristics[characteristicString.lowercaseString];
    
    [characteristic setNotify:YES withCompletion:^(NSError *error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceRegistrationModeFailed" object:blockSafeDevice userInfo:error ? @{@"error":error} : nil];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceRegistrationModeReady" object:blockSafeDevice userInfo:nil];
        }
    }];
}

+ (void)device:(ASDevice *)device didFailToSetup:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceRegistrationModeFailed" object:device userInfo:error ? @{@"error":error} : nil];
}

@end
