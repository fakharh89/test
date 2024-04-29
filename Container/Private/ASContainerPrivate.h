//
//  ASContainerPrivate.h
//  Blustream
//
//  Created by Michael Gordon on 6/25/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASContainer.h"

@class ASBatteryLevel;
@class ASEnvironmentalMeasurement;
@class ASImpact;
@class ASActivityState;
@class ASPIOState;
@class ASAIOMeasurement;
@class ASErrorState;
@class ASConnectionEvent;
@class MSWeakTimer;

@interface ASContainer () <NSCoding>

@property (strong, readwrite, nonatomic) NSString *imageURL;
@property (strong, readwrite, nonatomic) NSMutableArray<ASBatteryLevel *> *batteryLevelsInternal;
@property (strong, readwrite, nonatomic) NSMutableArray<ASEnvironmentalMeasurement *> *environmentalMeasurementsInternal;
@property (strong, readwrite, nonatomic) NSMutableArray<ASImpact *> *impactsInternal;
@property (strong, readwrite, nonatomic) NSMutableArray<ASActivityState *> *activityStatesInternal;
@property (strong, readwrite, nonatomic) NSMutableArray<ASPIOState *> *PIOStatesInternal;
@property (strong, readwrite, nonatomic) NSMutableArray<ASAIOMeasurement *> *AIOMeasurementsInternal;
@property (strong, readwrite, nonatomic) NSMutableArray<ASErrorState *> *errorsInternal;
@property (strong, readwrite, nonatomic) NSMutableArray<ASConnectionEvent *> *connectionEventsInternal;
@property (weak, readwrite, nonatomic) ASDevice *device;
@property (strong, readwrite, nonatomic) NSString *linkedDeviceSerialNumber;
@property (strong, readwrite, nonatomic) NSString *creator;
@property (strong, readwrite, nonatomic) NSDate *lastSynced;
@property (strong, readwrite, nonatomic) NSDate *imageLastSynced;
@property (strong, readwrite, nonatomic) NSDictionary *fullMetadata;
@property (strong, readwrite, nonatomic) NSString *ownerUsernameWithTag;
@property (strong, readonly, nonatomic) dispatch_queue_t memberQueue;
@property (strong, readonly, nonatomic) dispatch_queue_t processingQueue;
@property (strong, readwrite, nonatomic) MSWeakTimer *saveTimer;
@property (nonatomic, assign) BOOL isSyncingImage;
@property (nonatomic, assign) BOOL isSyncing;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)addNewBatteryMeasurement:(ASBatteryLevel *)batteryMeasurement;
- (void)addNewEnvironmentalMeasurement:(ASEnvironmentalMeasurement *)environmentalMeasurement;
- (void)addNewImpactMeasurement:(ASImpact *)impactMeasurement;
- (void)addNewActivityMeasurement:(ASActivityState *)activityMeasurement;
- (void)addNewPIOMeasurement:(ASPIOState *)PIOMeasurement;
- (void)addNewAIOMeasurement:(ASAIOMeasurement *)AIOMeasurement;
- (void)addNewErrorStateMeasurement:(ASErrorState *)errorStateMeasurement;
- (void)addNewConnectionEvent:(ASConnectionEvent *)connectionEvent;
- (BOOL)syncContainerFromDictionary:(NSDictionary *)dictionary;
- (BOOL)syncContainerImageFromDictionary:(NSDictionary *)dictionary imageDownloadCompletion:(void (^)(NSError *error))completion;
- (void)unsafeSetLink:(ASDevice *)device;
- (void)restoreDeviceLink;
- (BOOL)isCompatible;
- (void)unsafeSetImage:(UIImage *)image;
- (void)delayedSave;
- (void)save;
- (void)deleteLocalCache;

@end
