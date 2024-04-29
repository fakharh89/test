//
//  ASBLEParametersCharacteristic.h
//  Pods
//
//  Created by Michael Gordon on 12/10/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

#import "ASAttribute.h"
#import "ASCharacteristic.h"

//
// Length of adv time (3s)
// Duty cycle (percentage) (30%)
// Rate of adv sent (152.5 ms)
// Connection parameters
// min
// max
// latency
// timeout

// 14 bytes

//Conn Params Packet:
//| conn_min | conn_max | conn_latency | timeout | adv_rate | adv_dur | adv_duty |
//
//conn_min = (uint16) in frames (0.8ms/frame)
//conn_max = (uint16) in frames
//conn_latency = (uint16) # conn intervals
//conn_timeout = (uint16) timeout * 10ms
//
//adv_rate = (uint32) rate * 100ms
//adv_dur = (uint8) in seconds
//adv_duty = (uint8) in %

@interface ASBLEParametersCharacteristic : ASCharacteristic <ASReadableCharacteristic, ASWriteableCharacteristic>

- (ASBLEResult<NSNumber *> *)process;
- (BOOL)updateDeviceWithData:(NSNumber *)data error:(NSError *__autoreleasing *)error;
- (void)write:(NSNumber *)threshold withCompletion:(void (^)(NSError *error))completion;

@end
