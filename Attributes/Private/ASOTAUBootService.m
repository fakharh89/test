//
//  ASOTAUBootService.m
//  Pods
//
//  Created by Michael Gordon on 1/12/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASOTAUBootService.h"

#import "ASBLEDefinitions.h"
#import "ASOTAUVersionCharacteristic.h"
#import "ASOTAUCurrentAppCharacteristic.h"
#import "ASOTAUDataTransferCharacteristic.h"
#import "ASOTAUControlTransferCharacteristic.h"

@implementation ASOTAUBootService

+ (NSString *)identifier {
    return ASOTAUBootServiceUUID;
}

- (ASOTAUVersionCharacteristic *)versionCharacterstic  {
    return (ASOTAUVersionCharacteristic *)self.characteristics[[ASOTAUVersionCharacteristic identifier].lowercaseString];
}

- (ASOTAUCurrentAppCharacteristic *)currentAppCharacteristic  {
    return (ASOTAUCurrentAppCharacteristic *)self.characteristics[[ASOTAUCurrentAppCharacteristic identifier].lowercaseString];
}

- (ASOTAUDataTransferCharacteristic *)dataTransferCharacteristic  {
    return (ASOTAUDataTransferCharacteristic *)self.characteristics[[ASOTAUDataTransferCharacteristic identifier].lowercaseString];
}

- (ASOTAUControlTransferCharacteristic *)controlTransferCharacteristic  {
    return (ASOTAUControlTransferCharacteristic *)self.characteristics[[ASOTAUControlTransferCharacteristic identifier].lowercaseString];
}

@end
