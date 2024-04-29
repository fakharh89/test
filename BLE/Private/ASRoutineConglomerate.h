//
//  ASRoutineConglomerate.h
//  Blustream
//
//  Created by Michael Gordon on 7/13/16.
//
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

@class ASDevice;
@protocol ASDataHandlingRoutine;

@interface ASRoutineConglomerate : NSObject

+ (NSArray<CBUUID *> *)allServices;
+ (NSArray<CBUUID *> *)allCharacteristicsForService:(NSString *)service;
+ (Class<ASDataHandlingRoutine>)connectionRoutineForDevice:(ASDevice *)device;

@end
