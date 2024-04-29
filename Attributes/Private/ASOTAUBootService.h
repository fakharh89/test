//
//  ASOTAUBootService.h
//  Pods
//
//  Created by Michael Gordon on 1/12/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASService.h"

#import "ASAttribute.h"

@class ASOTAUVersionCharacteristic;
@class ASOTAUCurrentAppCharacteristic;
@class ASOTAUDataTransferCharacteristic;
@class ASOTAUControlTransferCharacteristic;

@interface ASOTAUBootService : ASService <ASService>

@property (strong, readwrite, nonatomic) ASOTAUVersionCharacteristic *versionCharacterstic;
@property (strong, readwrite, nonatomic) ASOTAUCurrentAppCharacteristic *currentAppCharacteristic;
@property (strong, readwrite, nonatomic) ASOTAUDataTransferCharacteristic *dataTransferCharacteristic;
@property (strong, readwrite, nonatomic) ASOTAUControlTransferCharacteristic *controlTransferCharacteristic;

@end
