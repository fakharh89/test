//
//  ASContainer.m
//  Blustream
//
//  Created by Michael Gordon on 6/25/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASContainerPrivate.h"

#import <UIKit/UIKit.h>

#import "ASActivityState.h"
#import "ASAIOMeasurement.h"
#import "ASBatteryLevel.h"
#import "ASCloud.h"
#import "ASCloudPrivate.h"
#import "ASSyncManager.h"
#import "ASConfig.h"
#import "ASContainerManager.h"
#import "ASContainerAPIService.h"
#import "ASDevicePrivate.h"
#import "ASDeviceManagerPrivate.h"
#import "ASEnvironmentalMeasurement.h"
#import "ASErrorDefinitions.h"
#import "ASErrorState.h"
#import "ASImpact.h"
#import "ASLocationManager.h"
#import "ASLog.h"
#import "ASMeasurementPrivate.h"
#import "ASPIOState.h"
#import "ASSystemManagerPrivate.h"
#import "ASTag.h"
#import "ASUserPrivate.h"
#import "ASUtils.h"
#import "ASDateFormatter.h"
#import "MSWeakTimer.h"
#import "NSDate+ASRoundDate.h"
#import "NSDictionary+ASStringToJSON.h"
#import "NSString+ASJSONToString.h"
#import "SWWTB+NSNotificationCenter+Addition.h"
#import "ASNotifications.h"
#import "NSError+ASError.h"

#define maxLocalPointsStored 1024

dispatch_queue_t container_save_queue() {
    static dispatch_queue_t as_container_save_queue;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        as_container_save_queue = dispatch_queue_create("com.acoustic-stream.container.save", DISPATCH_QUEUE_SERIAL);
    });
    
    return as_container_save_queue;
}

@interface ASContainer()

@property (nonatomic, strong) ASContainerAPIService *apiService;
@property (nonatomic, assign) BOOL isUserSyncInProgress;

@end

@implementation ASContainer {
    id _tag;
}

- (void)dealloc {
    // Remove observers when deallocating so messages don't get sent into the void
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        _ownerUsernameWithTag = ASSystemManager.shared.cloud.user.usernameWithTag;
        if (!_ownerUsernameWithTag) {
            // Don't create object if user is not logged in.
            return nil;
        }
        
        _identifier = [[NSUUID UUID] UUIDString];
        _creator = [[NSBundle mainBundle] bundleIdentifier];
        
        [self sharedInit];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _identifier = dictionary[@"containerId"];
        _ownerUsernameWithTag = dictionary[@"ownerUsername"];
        
        NSString *creator = dictionary[@"appName"];
        if ([creator isKindOfClass:[NSNull class]]) {
            creator = nil;
        }
        _creator = creator;
        
        [self updateFromDictionary:dictionary];
        
        // Don't call updateImageDataFromDictionary - we don't want the image last synced portion
//        [self updateImageDataFromDictionary:dictionary];
//        _imageLastSynced = nil;
        
        NSString *newImageURL = dictionary[@"avatarLink"];
        if ([newImageURL isKindOfClass:[NSNull class]]) {
            newImageURL = nil;
        }
        
        _imageURL = newImageURL;
        
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    _batteryLevelsInternal = [[NSMutableArray alloc] init];
    _environmentalMeasurementsInternal = [[NSMutableArray alloc] init];
    _impactsInternal = [[NSMutableArray alloc] init];
    _activityStatesInternal = [[NSMutableArray alloc] init];
    _PIOStatesInternal = [[NSMutableArray alloc] init];
    _AIOMeasurementsInternal = [[NSMutableArray alloc] init];
    _errorsInternal = [[NSMutableArray alloc] init];
    _connectionEventsInternal = [[NSMutableArray alloc] init];
    _apiService = [[ASContainerAPIService alloc] initWithContainer:self systemManager:ASSystemManager.shared];
    
    [self queueInit];
}

- (void)queueInit {
    // Note: These UUIDs don't match the containers because they are created before the container is loaded from the disk.
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    NSString *memberQueueName = [NSString stringWithFormat:@"com.acoustic-stream.container.member.%@", uuidString];
    NSString *processingQueueName = [NSString stringWithFormat:@"com.acoustic-stream.container.processing.%@", uuidString];
    
    _memberQueue = dispatch_queue_create([memberQueueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
    _processingQueue = dispatch_queue_create([processingQueueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
}

#pragma mark - NSCoding

#define kName                             @"Name"
#define kImage                            @"Image"
#define kSecondImage                      @"SecondImage"
#define kMetadata                         @"Metadata"
#define kIdentifier                       @"Identifier"
#define kOwnerUsernameWithTag             @"OwnerUsernameWithTag"
#define kLinkedDeviceSerialNumber         @"LinkedDeviceSerialNumber"
#define kTag                              @"Tag"
#define kCreator                          @"Creator"
#define kLastSynced                       @"LastSynced"
#define kImageLastSynced                  @"ImageLastSynced"
#define kImageURL                         @"ImageURL"
#define kType                             @"Type"
#define kBatteryLevelsInternal            @"BatteryLevelsInternal"
#define kEnviromentalMeasurementsInternal @"EnvironmentalMeasurementsInternal"
#define kImpactsInternal                  @"ImpactsInternal"
#define kActivityStatesInternal           @"ActivityStatesInternal"
#define kAIOMeasurementsInternal          @"AIOMeasurementsInternal"
#define kPIOStatesInternal                @"PIOStatesInternal"
#define kErrorsInternal                   @"ErrorsInternal"
#define kConnectionEventsInternal         @"ConnectionEventsInternal"

// Deprecated:
//#define kBatteryDates             @"BatteryDates"
//#define kBatteryData              @"BatteryData"
//#define kEnvDates                 @"EnvDates"
//#define kTempData                 @"TempData"
//#define kHumidData                @"HumidData"
//#define kAccelDates               @"AccelDates"
//#define kAccelData                @"AccelData"
//#define kActivityDates            @"ActivityDates"
//#define kActivityData             @"ActivityData"
//#define kPIODates                 @"PIODates"
//#define kPIOData                  @"PIOData"
//#define kAIODates                 @"AIODates"
//#define kAIOData                  @"AIOData"
//#define kErrorStateDates          @"ErrorStateDates"
//#define kErrorStates              @"ErrorStates"
//#define kBatteryDatesInternal     @"BatteryDatesInternal"
//#define kBatteryDataInternal      @"BatteryDataInternal"
//#define kEnvDatesInternal         @"EnvDatesInternal"
//#define kTempDataInternal         @"TempDataInternal"
//#define kHumidDataInternal        @"HumidDataInternal"
//#define kAccelDatesInternal       @"AccelDatesInternal"
//#define kAccelDataInternal        @"AccelDataInternal"
//#define kActivityDatesInternal    @"ActivityDatesInternal"
//#define kActivityDataInternal     @"ActivityDataInternal"
//#define kPIODatesInternal         @"PIODatesInternal"
//#define kPIODataInternal          @"PIODataInternal"
//#define kAIODatesInternal         @"AIODatesInternal"
//#define kAIODataInternal          @"AIODataInternal"
//#define kErrorStateDatesInternal  @"ErrorStateDatesInternal"
//#define kErrorStatesInternal      @"ErrorStatesInternal"

- (void)encodeWithCoder:(NSCoder *)encoder {
    dispatch_sync(self.memberQueue, ^{
        // Metadata
        [encoder encodeObject:self->_name forKey:kName];
        [encoder encodeObject:self->_fullMetadata forKey:kMetadata];
        [encoder encodeObject:self->_identifier forKey:kIdentifier];
        [encoder encodeObject:self->_ownerUsernameWithTag forKey:kOwnerUsernameWithTag];
        [encoder encodeObject:self->_linkedDeviceSerialNumber forKey:kLinkedDeviceSerialNumber];
        [encoder encodeObject:self->_creator forKey:kCreator];
        [encoder encodeObject:self->_lastSynced forKey:kLastSynced];
        [encoder encodeObject:self->_type forKey:kType];

        // Data
        [encoder encodeObject:self->_batteryLevelsInternal forKey:kBatteryLevelsInternal];
        [encoder encodeObject:self->_environmentalMeasurementsInternal forKey:kEnviromentalMeasurementsInternal];
        [encoder encodeObject:self->_impactsInternal forKey:kImpactsInternal];
        [encoder encodeObject:self->_activityStatesInternal forKey:kActivityStatesInternal];
        [encoder encodeObject:self->_PIOStatesInternal forKey:kPIOStatesInternal];
        [encoder encodeObject:self->_AIOMeasurementsInternal forKey:kAIOMeasurementsInternal];
        [encoder encodeObject:self->_errorsInternal forKey:kErrorsInternal];
        [encoder encodeObject:self->_connectionEventsInternal forKey:kConnectionEventsInternal];

        // Image
//        [encoder encodeObject:UIImagePNGRepresentation(_image) forKey:kImage];
//        [self saveImage];
        [encoder encodeObject:self->_imageLastSynced forKey:kImageLastSynced];
        [encoder encodeObject:self->_imageURL forKey:kImageURL];
        
        // SecondImage
        [encoder encodeObject:self->_secondImage forKey:kSecondImage];
        
        // Tag
        if (self->_tag && [[self->_tag class] conformsToProtocol:@protocol(NSCoding)]) {
            [encoder encodeObject:self->_tag forKey:kTag];
        }
    });
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    [self queueInit];
    
    if (self) {
        dispatch_barrier_sync(self.memberQueue, ^{
            // Metadata
            self->_name = [decoder decodeObjectForKey:kName];
            self->_fullMetadata = [decoder decodeObjectForKey:kMetadata];
            self->_identifier = [decoder decodeObjectForKey:kIdentifier];
            self->_ownerUsernameWithTag = [decoder decodeObjectForKey:kOwnerUsernameWithTag];
            self->_linkedDeviceSerialNumber = [decoder decodeObjectForKey:kLinkedDeviceSerialNumber];
            self->_creator = [decoder decodeObjectForKey:kCreator];
            self->_lastSynced = [decoder decodeObjectForKey:kLastSynced];
            self->_type = [decoder decodeObjectForKey:kType];
            
            // Image
            self->_imageLastSynced = [decoder decodeObjectForKey:kImageLastSynced];
            self->_imageURL = [decoder decodeObjectForKey:kImageURL];
            
            if ([self loadImage]) {
                [self saveImage];
            } else if(![self loadImageNewPNG]) {
                // This forces an image resync
                self->_imageLastSynced = nil;
            }
            
            // SecondImage
            self->_secondImage = [decoder decodeObjectForKey:kSecondImage];
            
            // Data
            self->_batteryLevelsInternal = [decoder decodeObjectForKey:kBatteryLevelsInternal];
            if (!self->_batteryLevelsInternal) {
                self->_batteryLevelsInternal = [[NSMutableArray alloc] init];
                
                // Try to restore old date format
                NSMutableArray *oldDates = [decoder decodeObjectForKey:@"BatteryDatesInternal"];
                NSMutableArray *oldData = [decoder decodeObjectForKey:@"BatteryDataInternal"];
                
                if (oldDates && oldData && (oldDates.count == oldData.count)) {
                    for (int i = 0; i < oldDates.count; i++) {
                        [self->_batteryLevelsInternal addObject:[[ASBatteryLevel alloc] initWithDate:oldDates[i] batteryLevel:oldData[i]]];
                    }
                }
            }
            
            self->_environmentalMeasurementsInternal = [decoder decodeObjectForKey:kEnviromentalMeasurementsInternal];
            if (!self->_environmentalMeasurementsInternal) {
                self->_environmentalMeasurementsInternal = [[NSMutableArray alloc] init];
                
                // Try to restore old date format
                NSMutableArray *oldDates = [decoder decodeObjectForKey:@"EnvDatesInternal"];
                NSMutableArray *oldTemps = [decoder decodeObjectForKey:@"TempDataInternal"];
                NSMutableArray *oldHumids = [decoder decodeObjectForKey:@"HumidDataInternal"];
                
                if (oldDates && oldTemps && oldHumids
                    && (oldDates.count == oldTemps.count) && (oldDates.count == oldHumids.count)) {
                    for (int i = 0; i < oldDates.count; i++) {
                        [self->_environmentalMeasurementsInternal addObject:[[ASEnvironmentalMeasurement alloc] initWithDate:oldDates[i] humidity:oldHumids[i] temperature:oldTemps[i]]];
                    }
                }
            }
            
            self->_impactsInternal = [decoder decodeObjectForKey:kImpactsInternal];
            if (!self->_impactsInternal) {
                self->_impactsInternal = [[NSMutableArray alloc] init];
                
                // Try to restore old date format
                NSMutableArray *oldDates = [decoder decodeObjectForKey:@"AccelDatesInternal"];
                NSMutableArray *oldData = [decoder decodeObjectForKey:@"AccelDataInternal"];
                
                if (oldDates && oldData && (oldDates.count == oldData.count)) {
                    for (int i = 0; i < oldDates.count; i++) {
                        [self->_impactsInternal addObject:[[ASImpact alloc] initWithDate:oldDates[i] magnitude:oldData[i]]];
                    }
                }
            }
            
            self->_activityStatesInternal = [decoder decodeObjectForKey:kActivityStatesInternal];
            if (!self->_activityStatesInternal) {
                self->_activityStatesInternal = [[NSMutableArray alloc] init];
                
                // Try to restore old date format
                NSMutableArray *oldDates = [decoder decodeObjectForKey:@"ActivityDatesInternal"];
                NSMutableArray *oldData = [decoder decodeObjectForKey:@"ActivityDataInternal"];
                
                if (oldDates && oldData && (oldDates.count == oldData.count)) {
                    for (int i = 0; i < oldDates.count; i++) {
                        [self->_activityStatesInternal addObject:[[ASActivityState alloc] initWithDate:oldDates[i] activityState:oldData[i]]];
                    }
                }
            }
            
            self->_PIOStatesInternal = [decoder decodeObjectForKey:kPIOStatesInternal];
            if (!self->_PIOStatesInternal) {
                self->_PIOStatesInternal = [[NSMutableArray alloc] init];
                
                // Try to restore old date format
                NSMutableArray *oldDates = [decoder decodeObjectForKey:@"PIODatesInternal"];
                NSMutableArray *oldData = [decoder decodeObjectForKey:@"PIODataInternal"];
                
                if (oldDates && oldData && (oldDates.count == oldData.count)) {
                    for (int i = 0; i < oldDates.count; i++) {
                        [self->_PIOStatesInternal addObject:[[ASPIOState alloc] initWithDate:oldDates[i] PIOState:oldData[i]]];
                    }
                }
            }
            
            self->_AIOMeasurementsInternal = [decoder decodeObjectForKey:kAIOMeasurementsInternal];
            if (!self->_AIOMeasurementsInternal) {
                self->_AIOMeasurementsInternal = [[NSMutableArray alloc] init];
                
                // Try to restore old date format
                NSMutableArray *oldDates = [decoder decodeObjectForKey:@"AIODatesInternal"];
                NSMutableArray *oldData = [decoder decodeObjectForKey:@"AIODataInternal"];
                
                if (oldDates && oldData && (oldDates.count == oldData.count)) {
                    for (int i = 0; i < oldDates.count; i++) {
                        [self->_AIOMeasurementsInternal addObject:[[ASAIOMeasurement alloc] initWithDate:oldDates[i] AIOVoltages:oldData[i]]];
                    }
                }
            }
            
            self->_errorsInternal = [decoder decodeObjectForKey:kErrorsInternal];
            if (!self->_errorsInternal) {
                self->_errorsInternal = [[NSMutableArray alloc] init];
                
                // Try to restore old date format
                NSMutableArray *oldDates = [decoder decodeObjectForKey:@"ErrorStateDatesInternal"];
                NSMutableArray *oldData = [decoder decodeObjectForKey:@"ErrorStatesInternal"];
                
                if (oldDates && oldData && (oldDates.count == oldData.count)) {
                    for (int i = 0; i < oldDates.count; i++) {
                        [self->_errorsInternal addObject:[[ASErrorState alloc] initWithDate:oldDates[i] errorState:oldData[i]]];
                    }
                }
            }
            
            self->_connectionEventsInternal = [decoder decodeObjectForKey:kConnectionEventsInternal];
            if (!self->_connectionEventsInternal) {
                self->_connectionEventsInternal = [NSMutableArray new];
            }
            
            [self restoreDeviceLink];
            
            // Tag
            self->_tag = [decoder decodeObjectForKey:kTag];
            // TODO Make sure this works
            if ([self->_tag respondsToSelector:@selector(setParentContainer:)]) {
                [self->_tag setParentContainer:self];
            }
            
            self->_apiService = [[ASContainerAPIService alloc] initWithContainer:self systemManager:ASSystemManager.shared];
        });
    }
    
    return self;
}

#pragma mark - Public Methods
#pragma mark Setters and Getters

- (void)setName:(NSString *)name {
    _name = [name copy];
    self.lastSynced = [[NSDate date] as_roundMillisecondsToThousands];
    [self syncUserDataIfNeeded];
}

- (void)setImage:(UIImage *)image {
    [self unsafeSetImage:image];
    self.imageLastSynced = [[NSDate date] as_roundMillisecondsToThousands];
    [self syncUserDataIfNeeded];
}

- (void)unsafeSetImage:(UIImage *)image {
    _image = [image copy];
    dispatch_barrier_async(self.memberQueue, ^{
        // Save to disk
        // TODO Handle image saving fail
        if (![self saveImage]) {
            [self saveImage];
        }
    });
}

- (void)setSecondImage:(UIImage *)image {
    [self unsafeSetSecondImage:image];
}

- (void)unsafeSetSecondImage:(UIImage *)image {
    _secondImage = [image copy];
    dispatch_barrier_async(self.memberQueue, ^{
        // Save to disk
        // TODO Handle image saving fail
        if (![self saveSecondImage]) {
            [self saveSecondImage];
        }
    });
}


- (void)setType:(NSString *)type {
    _type = [type copy];
    self.lastSynced = [[NSDate date] as_roundMillisecondsToThousands];
    [self syncUserDataIfNeeded];
}

- (NSDictionary *)metadata {
    NSDictionary *metadata = _fullMetadata[[NSBundle mainBundle].bundleIdentifier];
    
    if ([metadata isKindOfClass:[NSNull class]]) {
        metadata = nil;
    }
    
    return metadata;
}

- (void)setMetadata:(NSDictionary *)metadata {
    NSMutableDictionary *mutableFullMetadata = [NSMutableDictionary dictionaryWithDictionary:_fullMetadata];
    [mutableFullMetadata setObject:(metadata ? [metadata copy] : [NSNull null]) forKey:[NSBundle mainBundle].bundleIdentifier];
    _fullMetadata = [NSDictionary dictionaryWithDictionary:mutableFullMetadata];
    
    self.lastSynced = [[NSDate date] as_roundMillisecondsToThousands];
    [self syncUserDataIfNeeded];
}

- (NSString *)ownerUsername {
    NSString *tag = ASSystemManager.shared.config.accountTag;
    NSRange range = [self.ownerUsernameWithTag rangeOfString:tag options:NSBackwardsSearch];
    
    NSString *username = nil;
    if (range.location != NSNotFound) {
        username = [self.ownerUsernameWithTag substringToIndex:range.location];
    }
    else {
        username = self.ownerUsernameWithTag;
    }
    return username;
}

- (void)setTag:(id)tag {
    dispatch_barrier_sync(self.memberQueue, ^{
        self->_tag = tag;
    });
}

- (id)tag {
    __block id tag;
    dispatch_sync(self.memberQueue, ^{
        tag = self->_tag;
    });
    return tag;
}

- (NSArray<ASBatteryLevel *> *)batteryLevels {
    __block NSArray<ASBatteryLevel *> *array;
    dispatch_sync(self.memberQueue, ^{
        array = [NSArray arrayWithArray:self->_batteryLevelsInternal];
    });
    return array;
}

- (NSArray<ASEnvironmentalMeasurement *> *)environmentalMeasurements {
    __block NSArray<ASEnvironmentalMeasurement *> *array;
    dispatch_sync(self.memberQueue, ^{
        array = [NSArray arrayWithArray:self->_environmentalMeasurementsInternal];
    });
    return array;
}

- (NSArray<ASImpact *> *)impacts {
    __block NSArray<ASImpact *> *array;
    dispatch_sync(self.memberQueue, ^{
        array = [NSArray arrayWithArray:self->_impactsInternal];
    });
    return array;
}

- (NSArray<ASActivityState *> *)activityStates {
    __block NSArray<ASActivityState *> *array;
    dispatch_sync(self.memberQueue, ^{
        array = [NSArray arrayWithArray:self->_activityStatesInternal];
    });
    return array;
}

- (NSArray<ASPIOState *> *)PIOStates {
    __block NSArray<ASPIOState *> *array;
    dispatch_sync(self.memberQueue, ^{
        array = [NSArray arrayWithArray:self->_PIOStatesInternal];
    });
    return array;
}

- (NSArray<ASAIOMeasurement *> *)AIOStates {
    __block NSArray<ASAIOMeasurement *> *array;
    dispatch_sync(self.memberQueue, ^{
        array = [NSArray arrayWithArray:self->_AIOMeasurementsInternal];
    });
    return array;
}

- (NSArray<ASErrorState *> *)errors {
    __block NSArray<ASErrorState *> *array;
    dispatch_sync(self.memberQueue, ^{
        array = [NSArray arrayWithArray:self->_errorsInternal];
    });
    return array;
}

- (NSArray<ASConnectionEvent *> *)connectionEvents {
    __block NSArray<ASConnectionEvent *> *array;
    dispatch_sync(self.memberQueue, ^{
        array = [NSArray arrayWithArray:self->_connectionEventsInternal];
    });
    return array;
}

- (NSNumber *)battery {
    return self.batteryData.lastObject;
}

- (NSArray *)batteryDates {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_batteryLevelsInternal valueForKeyPath:@"date"];
    });
    return array;
}

- (NSArray *)batteryData {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_batteryLevelsInternal valueForKeyPath:@"level"];
    });
    return array;
}

- (NSArray *)envDates {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_environmentalMeasurementsInternal valueForKeyPath:@"date"];
    });
    return array;
}

- (NSArray *)tempData {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_environmentalMeasurementsInternal valueForKeyPath:@"temperature"];
    });
    return array;
}

- (NSArray *)humidData {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_environmentalMeasurementsInternal valueForKeyPath:@"humidity"];
    });
    return array;
}

- (NSArray *)accelDates {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_impactsInternal valueForKeyPath:@"date"];
    });
    return array;
}

- (NSArray *)accelData {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_impactsInternal valueForKeyPath:@"magnitude"];
    });
    return array;
}

- (NSArray *)activityDates {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_activityStatesInternal valueForKeyPath:@"date"];
    });
    return array;
}

- (NSArray *)activityData {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_activityStatesInternal valueForKeyPath:@"state"];
    });
    return array;
}

- (NSArray *)PIODates {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_PIOStatesInternal valueForKeyPath:@"date"];
    });
    return array;
}

- (NSArray *)PIOData {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_PIOStatesInternal valueForKeyPath:@"state"];
    });
    return array;
}

- (NSArray *)AIODates {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_AIOMeasurementsInternal valueForKeyPath:@"date"];
    });
    return array;
}

- (NSArray *)AIOData {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_AIOMeasurementsInternal valueForKeyPath:@"voltages"];
    });
    return array;
}

- (NSArray *)errorStateDates {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_errorsInternal valueForKeyPath:@"date"];
    });
    return array;
}

- (NSArray *)errorStates {
    __block NSArray *array;
    dispatch_sync(self.memberQueue, ^{
        array = [self->_errorsInternal valueForKeyPath:@"state"];
    });
    return array;
}

#pragma mark Linking Methods
- (void)unsafeSetLink:(ASDevice *)device {
    if (device) {
        self.linkedDeviceSerialNumber = device.serialNumber;
        self.device = device;
        self.device.container = self;
        [ASSystemManager.shared.locationManager startMonitoringDevice:device];
    }
    else {
        [ASSystemManager.shared.locationManager stopMonitoringDevice:self.device];
        self.device.container = nil;
        self.device = nil;
        self.linkedDeviceSerialNumber = nil;
    }
}

#pragma mark - Private Methods

- (void)restoreDeviceLink {
    if (self.linkedDeviceSerialNumber) {
        for (ASDevice *device in ASSystemManager.shared.deviceManager.devices) {
            if ([device.serialNumber compare:self.linkedDeviceSerialNumber] == NSOrderedSame) {
                [self unsafeSetLink:device];
            }
        }
    }
    
    if (!self.device && self.linkedDeviceSerialNumber) {
        ASDevice *device = [[ASDevice alloc] initWithSerialNumber:self.linkedDeviceSerialNumber];
        [ASSystemManager.shared.deviceManager addDevice:device];
        [self unsafeSetLink:device];
    }
}

- (BOOL)syncContainerFromDictionary:(NSDictionary *)dictionary {
    BOOL changed = NO;
    
    if (self.isSyncing) {
        return NO;
    }
    
    self.isSyncing = YES;
    
    // Check to make sure identifier is correct
    if ([((NSString *) dictionary[@"identifier"]) compare:self.identifier] != NSOrderedSame) {
        self.isSyncing = NO;
        return NO;
    }
    
    // Last Sync Date
    NSString *serverLastSyncedString = dictionary[@"lastModified"];
    if ([serverLastSyncedString isKindOfClass:[NSNull class]]) {
        serverLastSyncedString = nil;
    }
    
    NSDate *serverLastSynced = nil;
    if (serverLastSyncedString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        serverLastSynced = [formatter dateFromString:serverLastSyncedString];
    }
    
    if ([self isEqualToDictionary:dictionary]) {
        changed = NO;
        self.lastSynced = serverLastSynced;
        self.isSyncing = NO;
    }
    else {
        // if no local sync or server is newer
        if (!self.lastSynced || !serverLastSynced || ([self.lastSynced timeIntervalSinceDate:serverLastSynced] <= 0)) {
            // Update local from server
            changed = YES;
            [self updateFromDictionary:dictionary];
            self.isSyncing = NO;
        }
        else {
            // Post local to server
            [self.apiService postWithSuccess:^{
                self.isSyncing = NO;
            } failure:^(NSError *error) {
                self.isSyncing = NO;
            }];
        }
    }
    
    return changed;
}

- (BOOL)syncContainerImageFromDictionary:(NSDictionary *)dictionary imageDownloadCompletion:(void (^)(NSError *error))completion {
    BOOL changed = NO;
    
    if (self.isSyncingImage) {
        NSError *error = [NSError ASErrorWithDomain:ASCloudErrorDomain code:    ASCloudErrorSyncingAlreadyInProgress underlyingError:nil];
        if (completion) {
            completion(error);
        }
        return NO;
    }
    
    self.isSyncingImage = YES;
    // Check to make sure identifier is correct
    if ([((NSString *) dictionary[@"identifier"]) compare:self.identifier] != NSOrderedSame) {
        self.isSyncingImage = NO;
        return NO;
    }
    
    NSString *newImageLastSyncedString = dictionary[@"avatarLastModified"];
    if ([newImageLastSyncedString isKindOfClass:[NSNull class]]) {
        newImageLastSyncedString = nil;
    }
    
    if (!newImageLastSyncedString) {
        ASLog(@"Container (%@) image missing on server - posting now", self.name);
        
        [self.apiService postImageWithSuccess:^{
            self.isSyncingImage = NO;
            ASLog(@"Posted container (%@) image", self.name);
        } failure:^(NSError *error) {
            self.isSyncingImage = NO;
            ASLog(@"Failed to post container (%@) image: %@", self.name, error);
        }];
        
        return YES;
    }
    
    NSDate *serverImageLastSynced = nil;
    if (newImageLastSyncedString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        serverImageLastSynced = [formatter dateFromString:dictionary[@"avatarLastModified"]];
    }
    
    if ([self isImageDataEqualToDictionary:dictionary]) {
        ASLog(@"Container (%@) image didn't change", self.name);
        changed = NO;
        self.imageLastSynced = serverImageLastSynced;
        self.isSyncingImage = NO;
    }
    else {
        // if no local sync or server is newer
        if (!self.imageLastSynced || !serverImageLastSynced || ([self.imageLastSynced timeIntervalSinceDate:serverImageLastSynced] <= 0)) {
            // Update local from server
            changed = YES;
            [self updateImageDataFromDictionary:dictionary];
            ASLog(@"Getting container (%@) image from server", self.name);
            
            [self.apiService getImageWithSuccess:^{
                ASLog(@"Got container (%@) image data", self.name);
                self.isSyncingImage = NO;
                if (completion) {
                    completion(nil);
                }
            } failure:^(NSError *error) {
                ASLog(@"Problem getting container (%@) image data: %@", self.name, error);
                self.imageLastSynced = nil;
                self.isSyncingImage = NO;
                if (completion) {
                    completion(error);
                }
            }];
        }
        else {
            // Post local to server
            ASLog(@"Server container (%@) image needs update", self.name);
            
            [self.apiService postImageWithSuccess:^{
                ASLog(@"Posted container (%@) image", self.name);
                self.isSyncingImage = NO;
            } failure:^(NSError *error) {
                ASLog(@"Failed to post container (%@) image: %@", self.name, error);
                self.isSyncingImage = NO;
            }];
        }
    }
    
    return changed;
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    // Last Sync Date
    NSString *newLastSyncedString = dictionary[@"lastModified"];
    if ([newLastSyncedString isKindOfClass:[NSNull class]]) {
        newLastSyncedString = nil;
    }
    
    NSDate *newLastSynced = nil;
    if (newLastSyncedString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        newLastSynced = [formatter dateFromString:newLastSyncedString];
    }
    _lastSynced = newLastSynced;
    
    // Name
    NSString *newName = dictionary[@"name"];
    if ([newName isKindOfClass:[NSNull class]]) {
        newName = nil;
    }
    _name = newName;
    
    // Type
    NSString *newType = dictionary[@"containerType"];
    if ([newType isKindOfClass:[NSNull class]]) {
        newType = nil;
    }
    _type = newType;
    
    // Metadata
    NSString *newMetadataString = dictionary[@"contents"];
    if ([newMetadataString isKindOfClass:[NSNull class]]) {
        newMetadataString = nil;
    }
    
    NSDictionary *newMetadata = nil;
    if (newMetadataString) {
        newMetadata = [NSDictionary dictionaryWithString:newMetadataString];
    }
    _fullMetadata = newMetadata;
    
    // Linked Devices
    NSArray *newLinkedDevices = dictionary[@"linkedDevices"];
    if ([newLinkedDevices isKindOfClass:[NSNull class]]) {
        newLinkedDevices = nil;
    }
    
    if (!newLinkedDevices || (newLinkedDevices.count == 0)) {
        // No devices should be linked
        if (self.device || self.linkedDeviceSerialNumber) {
            [self unsafeSetLink:nil];
        }
    }
    else {
        // Some device should be linked
        if (newLinkedDevices.count == 1) {
            NSString *newLinkedDeviceSerialNumber = [newLinkedDevices firstObject];
            if ([ASUtils detectChangeBetweenString:newLinkedDeviceSerialNumber string:self.linkedDeviceSerialNumber]) {
                _linkedDeviceSerialNumber = newLinkedDeviceSerialNumber;
                [self restoreDeviceLink];
            }
        }
        else {
            ASLog(@"CRITICAL ERROR: Container %@ has multiple devices linked", self.identifier);
        }
    }
}

- (void)updateImageDataFromDictionary:(NSDictionary *)dictionary {
    // Image Last Modified
    NSString *newImageLastSyncedString = dictionary[@"avatarLastModified"];
    if ([newImageLastSyncedString isKindOfClass:[NSNull class]]) {
        newImageLastSyncedString = nil;
    }
    
    NSDate *newImageLastSynced = nil;
    if (newImageLastSyncedString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        newImageLastSynced = [formatter dateFromString:dictionary[@"avatarLastModified"]];
    }
    _imageLastSynced = newImageLastSynced;
    
    // Image URL
    NSString *newImageURL = dictionary[@"avatarLink"];
    if ([newImageURL isKindOfClass:[NSNull class]]) {
        newImageURL = nil;
    }
    
    _imageURL = newImageURL;
}

- (BOOL)isEqualToDictionary:(NSDictionary *)dictionary {
    // Name
    NSString *newName = dictionary[@"name"];
    if ([newName isKindOfClass:[NSNull class]]) {
        newName = nil;
    }
    
    if ([ASUtils detectChangeBetweenString:newName string:self.name]) {
        return NO;
    }
    
    // Type
    NSString *newType = dictionary[@"containerType"];
    if ([newType isKindOfClass:[NSNull class]]) {
        newType = nil;
    }
    
    if ([ASUtils detectChangeBetweenString:newType string:self.type]) {
        return NO;
    }
    
    // Metadata
    NSString *newMetadataString = dictionary[@"contents"];
    if ([newMetadataString isKindOfClass:[NSNull class]]) {
        newMetadataString = nil;
    }
    
    NSDictionary *newMetadata = nil;
    if (newMetadataString) {
        newMetadata = [NSDictionary dictionaryWithString:newMetadataString];
    }
    
    BOOL metadataChanged = NO;
    if (newMetadata != self.fullMetadata) {
        if (newMetadata && self.fullMetadata) {
            metadataChanged = ![newMetadata isEqualToDictionary:self.fullMetadata];
        }
        else {
            metadataChanged = YES;
        }
    }
    
    if (metadataChanged) {
        return NO;
    }
    
    // Linked Devices
    NSArray *newLinkedDevices = dictionary[@"linkedDevices"];
    if ([newLinkedDevices isKindOfClass:[NSNull class]]) {
        newLinkedDevices = nil;
    }
    
    if (!newLinkedDevices || (newLinkedDevices.count == 0)) {
        // No devices should be linked
        if (self.device || self.linkedDeviceSerialNumber) {
            return NO;
        }
    }
    else {
        // Some device should be linked
        if (newLinkedDevices.count == 1) {
            NSString *newLinkedDeviceSerialNumber = [newLinkedDevices firstObject];
            if ([ASUtils detectChangeBetweenString:newLinkedDeviceSerialNumber string:self.linkedDeviceSerialNumber]) {
                return NO;
            }
        }
        else {
            ASLog(@"CRITICAL ERROR: Container %@ has multiple devices linked", self.identifier);
        }
    }
    
    return YES;
}

- (BOOL)isImageDataEqualToDictionary:(NSDictionary *)dictionary {
    // Image Last Modified
    NSString *newImageLastSyncedString = dictionary[@"avatarLastModified"];
    if ([newImageLastSyncedString isKindOfClass:[NSNull class]]) {
        newImageLastSyncedString = nil;
    }
    
    NSDate *newImageLastSynced = nil;
    if (newImageLastSyncedString) {
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        newImageLastSynced = [formatter dateFromString:dictionary[@"avatarLastModified"]];
    }
    
    BOOL imageDateChanged = NO;
    if (newImageLastSynced != self.imageLastSynced) {
        if (newImageLastSynced && self.imageLastSynced) {
            imageDateChanged = !([newImageLastSynced compare:self.imageLastSynced] == NSOrderedSame);
        }
        else {
            imageDateChanged = YES;
        }
    }
    
    if (imageDateChanged) {
        return NO;
    }
    
    return YES;
}

// Devices are compatible if creator is nil
- (BOOL)isCompatible {
    if (self.creator && ([self.creator compare:[[NSBundle mainBundle] bundleIdentifier]] != NSOrderedSame)) {
        return NO;
    }
    return YES;
}

#pragma mark Array Rotators

- (void)addNewBatteryMeasurement:(ASBatteryLevel *)batteryMeasurement {
    NSParameterAssert(batteryMeasurement);
    
    dispatch_barrier_async(self.memberQueue, ^{
        [self->_batteryLevelsInternal addObject:batteryMeasurement];
        [self trimArray:((NSMutableArray<ASMeasurement *> *) self->_batteryLevelsInternal) withoutRemovingUnsentToMinimumLength:maxLocalPointsStored];
    });
}

- (void)addNewEnvironmentalMeasurement:(ASEnvironmentalMeasurement *)environmentalMeasurement {
    NSParameterAssert(environmentalMeasurement);
    
    dispatch_barrier_async(self.memberQueue, ^{
        [self->_environmentalMeasurementsInternal addObject:environmentalMeasurement];
        [self trimArray:((NSMutableArray<ASMeasurement *> *) self->_environmentalMeasurementsInternal) withoutRemovingUnsentToMinimumLength:maxLocalPointsStored];
    });
}

- (void)addNewImpactMeasurement:(ASImpact *)impactMeasurement {
    NSParameterAssert(impactMeasurement);
    
    dispatch_barrier_sync(self.memberQueue, ^{
        [self->_impactsInternal addObject:impactMeasurement];
        [self trimArray:((NSMutableArray<ASMeasurement *> *) self->_impactsInternal) withoutRemovingUnsentToMinimumLength:maxLocalPointsStored];
    });
}

- (void)addNewActivityMeasurement:(ASActivityState *)activityMeasurement {
    NSParameterAssert(activityMeasurement);
    
    dispatch_barrier_async(self.memberQueue, ^{
        [self->_activityStatesInternal addObject:activityMeasurement];
        [self trimArray:((NSMutableArray<ASMeasurement *> *) self->_activityStatesInternal) withoutRemovingUnsentToMinimumLength:maxLocalPointsStored];
    });
}

- (void)addNewPIOMeasurement:(ASPIOState *)PIOMeasurement {
    NSParameterAssert(PIOMeasurement);
    
    dispatch_barrier_async(self.memberQueue, ^{
        [self->_PIOStatesInternal addObject:PIOMeasurement];
        [self trimArray:((NSMutableArray<ASMeasurement *> *) self->_PIOStatesInternal) withoutRemovingUnsentToMinimumLength:maxLocalPointsStored];
    });
}

- (void)addNewAIOMeasurement:(ASAIOMeasurement *)AIOMeasurement {
    NSParameterAssert(AIOMeasurement);
    
    dispatch_barrier_async(self.memberQueue, ^{
        [self->_AIOMeasurementsInternal addObject:AIOMeasurement];
        [self trimArray:((NSMutableArray<ASMeasurement *> *) self->_AIOMeasurementsInternal) withoutRemovingUnsentToMinimumLength:maxLocalPointsStored];
    });
}

- (void)addNewErrorStateMeasurement:(ASErrorState *)errorStateMeasurement {
    NSParameterAssert(errorStateMeasurement);
    
    dispatch_barrier_async(self.memberQueue, ^{
        [self->_errorsInternal addObject:errorStateMeasurement];
        [self trimArray:((NSMutableArray<ASMeasurement *> *) self->_errorsInternal) withoutRemovingUnsentToMinimumLength:maxLocalPointsStored];
    });
}

- (void)addNewConnectionEvent:(ASConnectionEvent *)connectionEvent {
    NSParameterAssert(connectionEvent);
    dispatch_barrier_async(self.memberQueue, ^{
        [self->_connectionEventsInternal addObject:connectionEvent];
        [self trimArray:((NSMutableArray<ASMeasurement *> *) self->_connectionEventsInternal) withoutRemovingUnsentToMinimumLength:maxLocalPointsStored];
    });
}

- (void)trimArray:(NSMutableArray<ASMeasurement *> *)array withoutRemovingUnsentToMinimumLength:(NSUInteger)length {
    if (array.count <= length) {
        return;
    }
    
    NSRange removeableRange = {
        .length = array.count - length,
        .location = 0
    };
    
    NSArray<ASMeasurement *> *leftovers = [array subarrayWithRange:removeableRange];
    NSMutableArray<ASMeasurement *> *toRemove = [[NSMutableArray alloc] init];
    
    for (ASMeasurement *leftover in leftovers) {
        if (leftover.syncStatus == ASSyncStatusSent) {
            [toRemove addObject:leftover];
        }
    }
    
    [array removeObjectsInArray:toRemove];
}

- (NSString *)description {
    NSString *text = [NSString stringWithFormat:@"Name: %@, Identifier: %@, Device: %@, ", self.name, self.identifier, self.device ? self.device.serialNumber : @"Not Linked"];
    return text;
}

- (void)delayedSave {
    [self.saveTimer invalidate];
    self.saveTimer = [MSWeakTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(save) userInfo:nil repeats:NO dispatchQueue:self.processingQueue];
}

- (void)save {
    dispatch_sync(container_save_queue(), ^{
        if (!self) {
            return;
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
        if (![data writeToFile:[self getDataPath] atomically:YES]) {
            ASLog(@"Failed to save container %@!", self.identifier);
        }
        
        // Set folder to not backup to iCloud.  Writing erases this attribute
        [ASSystemManager addSkipBackupAttributeToItemAtPath:[self getDataPath]];
    });
}

- (BOOL)saveImage {
    NSData *data = UIImagePNGRepresentation(_image);
    if (![data writeToFile:[self getImagePath] atomically:YES]) {
        ASLog(@"Failed to save container image %@!", self.identifier);
        return NO;
    }
    
    // Set folder to not backup to iCloud.  Writing erases this attribute
    [ASSystemManager addSkipBackupAttributeToItemAtPath:[self getImagePath]];
    return YES;
}

- (BOOL)loadImage {
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self getImagePath]];
    if (!exists) {
        return NO;
    }
    
    NSData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getImagePath]];
    if (!data) {
        return NO;
    }
    
    UIImage *image = [UIImage imageWithData:data];
    if (!image) {
        return NO;
    }
    
    _image = image;
    return YES;
}

- (BOOL)loadImageNewPNG {

    if (!UIImagePNGRepresentation([UIImage imageNamed:[self getImagePath]])) {
        return NO;
    }
    
    _image = [UIImage imageNamed:[self getImagePath]];
    return YES;
}

- (BOOL)deleteImage {
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self getImagePath]];
    if (!exists) {
        return NO;
    }

    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self getImagePath] error:&error];
    if (!success) {
        ASLog(@"Error deleting container image (%@): %@", self.identifier, error);
        return NO;
    }
    return YES;
}

- (BOOL)saveSecondImage {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:UIImagePNGRepresentation(_secondImage)];
    if (![data writeToFile:[self getSecondImagePath] atomically:YES]) {
        ASLog(@"Failed to save container image %@!", self.identifier);
        return NO;
    }
    
    // Set folder to not backup to iCloud.  Writing erases this attribute
    [ASSystemManager addSkipBackupAttributeToItemAtPath:[self getSecondImagePath]];
    return YES;
}

- (BOOL)deleteSecondImage {
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self getSecondImagePath]];
    if (!exists) {
        return NO;
    }
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self getSecondImagePath] error:&error];
    if (!success) {
        ASLog(@"Error deleting container image (%@): %@", self.identifier, error);
        return NO;
    }
    return YES;
}

- (void)deleteLocalCache {
    dispatch_barrier_sync(self.memberQueue, ^{
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self getDataPath]];
        if (exists) {
            NSError *error;
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self getDataPath] error:&error];
            if (!success) {
                ASLog(@"Error deleting container (%@): %@", self.identifier, error);
            }
        }
        
        [self deleteImage];
        [self deleteSecondImage];
    });
}

// Returns save path for data as an NSString
- (NSString *)getDataPath {
    NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
    NSString *filename = [docsPath stringByAppendingPathComponent:self.identifier];
    return filename;
}

- (NSString *)getImagePath {
    return [[self getDataPath] stringByAppendingString:@".png"];
}

- (NSString *)getSecondImagePath {
    return [[self getDataPath] stringByAppendingString:@"Second.png"];
}

- (void)syncUserDataIfNeeded {
    if (self.isUserSyncInProgress) {
        return;
    }
    
    self.isUserSyncInProgress = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ASSystemManager.shared.cloud.syncManager.syncTimer fire];
        self.isUserSyncInProgress = NO;
    });
}

@end
