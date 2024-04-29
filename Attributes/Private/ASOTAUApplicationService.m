//
//  ASOTAUApplicationService.m
//  Pods
//
//  Created by Michael Gordon on 1/12/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASOTAUApplicationService.h"

#import "ASBLEDefinitions.h"
#import "ASOTAUKeyCharacteristic.h"
#import "ASOTAUKeyBlockCharacteristic.h"

@implementation ASOTAUApplicationService

+ (NSString *)identifier {
    return ASOTAUApplicationServiceUUID;
}

- (ASOTAUKeyCharacteristic *)keyCharacteristic  {
    return (ASOTAUKeyCharacteristic *)self.characteristics[[ASOTAUKeyCharacteristic identifier].lowercaseString];
}

- (ASOTAUKeyBlockCharacteristic *)keyBlockCharacteristic  {
    return (ASOTAUKeyBlockCharacteristic *)self.characteristics[[ASOTAUKeyBlockCharacteristic identifier].lowercaseString];
}

@end
