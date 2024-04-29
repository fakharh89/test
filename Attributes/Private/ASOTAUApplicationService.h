//
//  ASOTAUApplicationService.h
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

@class ASOTAUKeyCharacteristic;
@class ASOTAUKeyBlockCharacteristic;

@interface ASOTAUApplicationService : ASService <ASService>

@property (strong, readwrite, nonatomic) ASOTAUKeyCharacteristic *keyCharacteristic;
@property (strong, readwrite, nonatomic) ASOTAUKeyBlockCharacteristic *keyBlockCharacteristic;

@end
