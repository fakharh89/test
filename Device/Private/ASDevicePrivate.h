//
//  ASDevicePrivate.h
//  Blustream
//
//  Created by Michael Gordon on 8/3/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASDevice.h"

typedef NS_ENUM(NSInteger, ASDeviceConnectionMode) {
    ASDeviceConnectionModeDefault,
    ASDeviceConnectionModeRegistration,
    ASDeviceConnectionModeOverTheAirUpdate,
    ASDeviceConnectionModeUnknown
};

@class CLBeaconRegion;
@class CBPeripheral;
@class MSWeakTimer;
@class ASWritePendingOperation;

@protocol ASService;

@interface ASDevice () <NSCoding>

@property (nonatomic, weak) ASContainer *container;

@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, strong) NSNumber *RSSI;
@property (nonatomic, strong) ASEnvironmentalMeasurement *advertisedEnvironmentalMeasurement;
@property (nonatomic, strong) ASBatteryLevel *advertisedBatteryLevel;
@property (nonatomic, strong) ASErrorState *advertisedErrorState;
@property (nonatomic, strong) NSNumber *measurementInterval;
@property (nonatomic, strong) NSNumber *alertInterval;
@property (nonatomic, strong) NSNumber *hardwareHumidAlarmMax;
@property (nonatomic, strong) NSNumber *hardwareHumidAlarmMin;
@property (nonatomic, strong) NSNumber *hardwareTempAlarmMax;
@property (nonatomic, strong) NSNumber *hardwareTempAlarmMin;
@property (nonatomic, assign) ASAccelerometerMode accelSetting;
@property (nonatomic, strong) NSNumber *accelThreshold;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *hardwareRevision;
@property (nonatomic, strong) NSString *softwareRevision;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSUUID *uuid;

@property (nonatomic, strong) NSData *registrationData;
@property (nonatomic, assign) ASDeviceConnectionMode connectionMode;

@property (nonatomic, assign) BOOL downloadCycleActive;

@property (nonatomic, strong, readonly) dispatch_queue_t memberQueue;
@property (nonatomic, strong, readonly) dispatch_queue_t processingQueue;
@property (nonatomic, strong) NSDictionary<NSString *, id<ASService>> *services;

@property (nonatomic, strong) NSDate *lastSynced;
@property (nonatomic, strong) NSDictionary *fullMetadata;
@property (nonatomic, assign) BOOL syncedForFirstTime;

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, assign) ASRegionState regionState;
@property (nonatomic, strong) NSDate *lastConnectedDate;
@property (nonatomic, strong) NSDate *lastDisconnectedDate;

@property (nonatomic, strong) MSWeakTimer *saveTimer;
@property (nonatomic, strong) MSWeakTimer *samplebatteryTimer;
@property (nonatomic, strong) NSMutableArray<ASWritePendingOperation *> *pendingOperations;
@property (nonatomic, assign) BOOL isSyncing;

- (id)initWithSerialNumber:(NSString *)serialNumber;
- (id)initWithSerialNumber:(NSString *)serialNumber peripheral:(CBPeripheral *)peripheral;
- (id)initInBootloaderModeWithPeripheral:(CBPeripheral *)peripheral;
- (void)touch;
- (void)delayedSave;
- (void)deleteLocalCache;

@end
