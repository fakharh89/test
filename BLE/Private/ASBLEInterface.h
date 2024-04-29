//
//  ASBLEInterface.h
//  Blustream
//
//  Created by Michael Gordon on 2/16/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import "ASDevicePrivate.h"

dispatch_queue_t ble_manager_processing_queue(void);
@protocol ASSevice, ASUpdatableCharacteristic, ASWriteableCharacteristic, ASNotifiableCharacteristic;

@class ASSystemManager, ASDevice, ASRealtimeMode, ASDefaultBLEHandler, ASRegistrationModeHandler, ASAdvertisementData, ASOverTheAirUpdateModeHandler;

@interface ASBLEInterface : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSDictionary *restoreDictionary;
@property (nonatomic, strong) ASRealtimeMode *realtimeMode;
@property (nonatomic, strong) ASDefaultBLEHandler *defaultHandler;
@property (nonatomic, strong) ASRegistrationModeHandler *registrationHandler;
@property (nonatomic, strong) ASOverTheAirUpdateModeHandler *overTheAirUpdateHandler;
@property (nonatomic, assign) BOOL isScanning;
@property (nonatomic, assign) BOOL needsRestore;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager NS_DESIGNATED_INITIALIZER;

- (void)connectToDevice:(ASDevice *)device;
- (void)connectToDevice:(ASDevice *)device mode:(ASDeviceConnectionMode)mode;
- (void)disconnectFromDevice:(ASDevice *)device;
- (void)startScanningForDevices;
- (void)stopScanningForDevices;

@end

@protocol ASBLEInterfaceDelegate <NSObject>

@required

- (void)didDiscoverDevice:(ASDevice *)device;
- (void)device:(ASDevice *)device advertisedWithData:(ASAdvertisementData *)advertisementData;
- (void)didConnectToDevice:(ASDevice *)device;
- (void)didDisconnectFromDevice:(ASDevice *)device error:(NSError *)error;
- (void)didFailToConnectToDevice:(ASDevice *)device error:(NSError *)error;
- (void)device:(ASDevice *)device didDiscoverServicesWithError:(NSError *)error;
- (void)device:(ASDevice *)device didDiscoverCharacteristicsForService:(id<ASService>)service error:(NSError *)error;
- (void)device:(ASDevice *)device didUpdateValueForCharacteristic:(id<ASUpdatableCharacteristic>)characteristic error:(NSError *)error;
- (void)device:(ASDevice *)device didWriteValueForCharacteristic:(id<ASWriteableCharacteristic>)characteristic error:(NSError *)error;
- (void)device:(ASDevice *)device didUpdateNotificationStateForCharacteristic:(id<ASNotifiableCharacteristic>)characteristic error:(NSError *)error;
- (void)device:(ASDevice *)device didReadRSSI:(NSNumber *)RSSI error:(NSError *)error;

@end

@protocol ASDataHandlingRoutine <NSObject>

@optional

@required

+ (NSArray<CBUUID *> *)supportedServices;
+ (NSArray<CBUUID *> *)supportedCharacteristicsForService:(NSString *)service;
+ (void)didFinishSetupForDevice:(ASDevice *)device;
+ (void)device:(ASDevice *)device didFailToSetup:(NSError *)error;

@end
