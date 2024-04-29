//
//  ASPUTQueue.m
//  Blustream
//
//  Created by Michael Gordon on 3/3/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASPUTQueue.h"

#import "AFHTTPSessionManager.h"
#import "ASCloudPrivate.h"
#import "ASConfig.h"
#import "ASContainer.h"
#import "ASContainerManager.h"
#import "ASErrorDefinitions.h"
#import "ASLog.h"
#import "ASMeasurementPrivate.h"
#import "ASPendingPUT.h"
#import "ASSystemManagerPrivate.h"
#import "ASDateFormatter.h"
#import "MSWeakTimer.h"
#import "NSArray+ASSearch.h"
#import "NSError+ASError.h"

#import "ASEnvironmentalMeasurement.h"
#import "ASAIOMeasurement.h"
#import "ASConnectionEventPrivate.h"
#import "ASPIOState.h"
#import "ASBatteryLevel.h"
#import "ASErrorState.h"
#import "ASActivityState.h"
#import "ASImpact.h"

dispatch_queue_t cloud_PUT_processing_queue() {
    static dispatch_queue_t as_cloud_PUT_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        as_cloud_PUT_processing_queue = dispatch_queue_create("com.acoustic-stream.cloudPUTs.processing", DISPATCH_QUEUE_SERIAL);
    });
    
    return as_cloud_PUT_processing_queue;
}

@interface ASPUTQueue()

@property (nonatomic, weak) ASSystemManager *systemManager;

@end

@implementation ASPUTQueue

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _systemManager = systemManager;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    // Remove observers when deallocating so messages don't get sent into the void
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

#pragma mark Notification Handlers

- (void)willEnterForeground:(NSNotification *)notification {
    [self start];
}

// TODO Some app had multiple connection events going on simultaneously

- (void)willEnterBackground:(NSNotification *)notification {
    // Stop timer
    if (self.PUTTimer) {
        [self.PUTTimer fire];
        [self stop];
    }
}

#pragma mark JSON Handler

- (void)PUTAllData:(MSWeakTimer *)timer {
    dispatch_async(cloud_PUT_processing_queue(), ^{
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        
        for (ASContainer *container in self.systemManager.containerManager.containers) {
            NSMutableArray<ASMeasurement *> *measurementsToSend = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *mutableParameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"containerId" : container.identifier}];
            
            if (container.environmentalMeasurements.count > 0) {
                NSMutableArray<NSDictionary *> *JSONs = [[NSMutableArray alloc] init];
                
                for (ASEnvironmentalMeasurement *measurement in container.environmentalMeasurements) {
                    if (measurement.syncStatus == ASSyncStatusUnsent) {
                        measurement.syncStatus = ASSyncStatusSending;
                        [measurementsToSend addObject:measurement];
                        
                        NSDictionary *JSON = @{@"timestamp" : [formatter stringFromDate:measurement.date],
                                               @"temperatureC" : measurement.temperature,
                                               @"humidityRH" : measurement.humidity};
                        
                        [JSONs addObject:JSON];
                    }
                }
                
                if (JSONs.count > 0) {
                    [mutableParameters setValue:JSONs forKey:@"ambientSamples"];
                }
            }
            
            if (container.batteryLevels.count > 0) {
                NSMutableArray<NSDictionary *> *JSONs = [[NSMutableArray alloc] init];
                
                for (ASBatteryLevel *measurement in container.batteryLevels) {
                    if (measurement.syncStatus == ASSyncStatusUnsent) {
                        measurement.syncStatus = ASSyncStatusSending;
                        [measurementsToSend addObject:measurement];
                        
                        NSDictionary *JSON = @{@"timestamp" : [formatter stringFromDate:measurement.date],
                                               @"level" : measurement.level};
                        
                        [JSONs addObject:JSON];
                    }
                }
                
                if (JSONs.count > 0) {
                    [mutableParameters setValue:JSONs forKey:@"batterySamples"];
                }
            }
            
            if (container.errors.count > 0) {
                NSMutableArray<NSDictionary *> *JSONs = [[NSMutableArray alloc] init];
                
                for (ASErrorState *measurement in container.errors) {
                    if (measurement.syncStatus == ASSyncStatusUnsent) {
                        measurement.syncStatus = ASSyncStatusSending;
                        [measurementsToSend addObject:measurement];
                        
                        NSDictionary *JSON = @{@"timestamp" : [formatter stringFromDate:measurement.date],
                                               @"errorState" : measurement.state};
                        
                        [JSONs addObject:JSON];
                    }
                }
                
                if (JSONs.count > 0) {
                    [mutableParameters setValue:JSONs forKey:@"errorStateSamples"];
                }
            }
            
            if (container.connectionEvents.count > 0) {
                NSMutableArray<NSDictionary *> *JSONs = [[NSMutableArray alloc] init];
                
                for (ASConnectionEvent *measurement in container.connectionEvents) {
                    if (measurement.syncStatus == ASSyncStatusUnsent) {
                        measurement.syncStatus = ASSyncStatusSending;
                        [measurementsToSend addObject:measurement];
                        
                        NSDictionary *JSON = @{@"timestamp" : [formatter stringFromDate:measurement.date],
                                               @"state" : [ASConnectionEvent stringForType:measurement.type],
                                               @"reason" : [ASConnectionEvent stringForReason:measurement.reason]};
                        
                        if (measurement.hubIdentifier) {
                            NSMutableDictionary *mutableJSON = [NSMutableDictionary dictionaryWithDictionary:JSON];
                            [mutableJSON addEntriesFromDictionary:@{@"hubId": measurement.hubIdentifier}];
                            JSON = [NSDictionary dictionaryWithDictionary:mutableJSON];
                        }
                        
                        [JSONs addObject:JSON];
                    }
                }
                
                if (JSONs.count > 0) {
                    [mutableParameters setValue:JSONs forKey:@"connectionSamples"];
                }
            }
            
            if (container.activityStates.count > 0) {
                NSMutableArray<NSDictionary *> *JSONs = [[NSMutableArray alloc] init];
                
                for (ASActivityState *measurement in container.activityStates) {
                    if (measurement.syncStatus == ASSyncStatusUnsent) {
                        measurement.syncStatus = ASSyncStatusSending;
                        [measurementsToSend addObject:measurement];
                        
                        NSDictionary *JSON = @{@"timestamp" : [formatter stringFromDate:measurement.date],
                                               @"state" : measurement.state};
                        
                        [JSONs addObject:JSON];
                    }
                }
                
                if (JSONs.count > 0) {
                    [mutableParameters setValue:JSONs forKey:@"activitySamples"];
                }
            }
            
            if (container.impacts.count > 0) {
                NSMutableArray<NSDictionary *> *JSONs = [[NSMutableArray alloc] init];
                
                for (ASImpact *measurement in container.impacts) {
                    if (measurement.syncStatus == ASSyncStatusUnsent) {
                        measurement.syncStatus = ASSyncStatusSending;
                        [measurementsToSend addObject:measurement];
                        
                        NSDictionary *JSON = @{@"timestamp" : [formatter stringFromDate:measurement.date],
                                               @"magnitudeG" : measurement.magnitude};
                        
                        [JSONs addObject:JSON];
                    }
                }
                
                if (JSONs.count > 0) {
                    [mutableParameters setValue:JSONs forKey:@"accelerometerSamples"];
                }
            }
            
            if (measurementsToSend.count == 0) {
                continue;
            }
            
            NSString *URLString = [NSString stringWithFormat:@"containers/%@/data/", container.identifier];
            
            NSDictionary *parameters = [[NSDictionary alloc] initWithDictionary:mutableParameters];
            
            [self.systemManager.cloud.HTTPManager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                dispatch_async(cloud_PUT_processing_queue(), ^{
                    for (ASMeasurement *measurement in measurementsToSend) {
                        measurement.syncStatus = ASSyncStatusSent;
                    }
                    ASLog(@"Put all data for %@", container.name ?: container.identifier);
                });
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                NSString *errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                dispatch_async(cloud_PUT_processing_queue(), ^{
                    for (ASMeasurement *measurement in measurementsToSend) {
                        measurement.syncStatus = ASSyncStatusUnsent;
                    }
                    ASLog(@"Failed to put all data for %@!", container.name ?: container.identifier);
                });
            }];
        }
    });
}

#pragma mark - Public Methods

- (void)start {
    dispatch_async(cloud_PUT_processing_queue(), ^{
        self.PUTTimer = [MSWeakTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(PUTAllData:) userInfo:nil repeats:YES dispatchQueue:cloud_PUT_processing_queue()];
        [self.PUTTimer fire];
    });
}

- (void)stop {
    dispatch_async(cloud_PUT_processing_queue(), ^{
        [self.PUTTimer invalidate];
        self.PUTTimer = nil;
    });
}

- (void)fire {
    [self PUTAllData:nil];
}

- (void)delayedFire {
    [self.delayedFireTimer invalidate];
    self.delayedFireTimer = [MSWeakTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(fire) userInfo:nil repeats:NO dispatchQueue:cloud_PUT_processing_queue()];
}

@end
