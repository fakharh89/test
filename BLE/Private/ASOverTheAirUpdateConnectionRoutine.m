//
//  ASOverTheAirUpdateConnectionRoutine.m
//  Blustream
//
//  Created by Michael Gordon on 10/7/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASOverTheAirUpdateConnectionRoutine.h"

#import "ASBLEDefinitions.h"
#import "ASLog.h"

@implementation ASOverTheAirUpdateConnectionRoutine

+ (NSArray<CBUUID *> *)supportedServices {
    static NSArray *services;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        services = @[[CBUUID UUIDWithString:ASOTAUBootServiceUUID]];
    });
    
    return services;
}

+ (NSArray<CBUUID *> *)supportedCharacteristicsForService:(NSString *)service {
    static NSArray *ASOTAUBootCharacteristics;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ASOTAUBootCharacteristics = @[[CBUUID UUIDWithString:ASOTAUVersionCharacteristicUUID],
                                      [CBUUID UUIDWithString:ASOTAUCurrentAppCharacteristicUUID],
                                      [CBUUID UUIDWithString:ASOTAUKeyCharacteristicUUID],
                                      [CBUUID UUIDWithString:ASOTAUControlTransferCharacteristicUUID],
                                      [CBUUID UUIDWithString:ASOTAUDataTransferCharacteristicUUID]];
    });
    
    if ([service caseInsensitiveCompare:ASOTAUBootServiceUUID] == NSOrderedSame) {
        return ASOTAUBootCharacteristics;
    }
    
    return nil;
}

+ (void)didFinishSetupForDevice:(ASDevice *)device {
    ASLog(@"did finish setup!");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OTAUModeReady" object:device userInfo:nil];
}

+ (void)device:(ASDevice *)device didFailToSetup:(NSError *)error {
    
}

@end
