//
//  ASDeviceInfoService.m
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDeviceInfoService.h"

#import "ASBLEDefinitions.h"
#import "ASHardwareRevisionCharacteristic.h"
#import "ASSerialNumberCharacteristic.h"
#import "ASSoftwareRevisionCharacteristic.h"

@implementation ASDeviceInfoService

+ (NSString *)identifier {
    return ASDevInfoServiceUUID;
}

- (ASSerialNumberCharacteristic *)serialNumberCharacteristic {
    return (ASSerialNumberCharacteristic *)self.characteristics[[ASSerialNumberCharacteristic identifier].lowercaseString];
}

- (ASHardwareRevisionCharacteristic *)hardwareRevisionCharacteristic {
    return (ASHardwareRevisionCharacteristic *)self.characteristics[[ASHardwareRevisionCharacteristic identifier].lowercaseString];
}

- (ASSoftwareRevisionCharacteristic *)softwareRevisionCharacteristic {
    return (ASSoftwareRevisionCharacteristic *)self.characteristics[[ASSoftwareRevisionCharacteristic identifier].lowercaseString];
}

@end
