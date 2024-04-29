//
//  ASRealtimeMode.m
//  Blustream
//
//  Created by Michael Gordon on 3/4/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASRealtimeMode.h"

#import "ASBLEDefinitions.h"
#import "ASBLEInterface.h"
#import "ASDevicePrivate.h"
#import "ASDeviceManager.h"
#import "ASDevice+BLEUpdate.h"
#import "ASEnvironmentalBufferCharacteristic.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASEnvironmentalRealtimeModeCharacteristic.h"
#import "ASServiceV1.h"
#import "ASServiceV3.h"
#import "ASSystemManager.h"
#import "MSWeakTimer.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

dispatch_queue_t realtime_mode_queue() {
    static dispatch_queue_t as_realtime_mode_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        as_realtime_mode_queue = dispatch_queue_create("com.acoustic-stream.realtime-mode", DISPATCH_QUEUE_CONCURRENT);
    });
    return as_realtime_mode_queue;
}

@interface ASRealtimeMode()

@property (nonatomic, weak) ASSystemManager *systemManager;

@end

@implementation ASRealtimeMode

- (void)dealloc {
    // Remove observers when deallocating so messages don't get sent into the void
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        // Subscribe to relevant notifications if using realtime mode
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        _systemManager = systemManager;
        
        [self start];
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)start {
    dispatch_async(realtime_mode_queue(), ^{
        ASLog(@"Starting realtime mode");
        self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES dispatchQueue:realtime_mode_queue()];
        [self.timer fire];
        self.v3Timer = [MSWeakTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerCallbackV3:) userInfo:nil repeats:YES dispatchQueue:realtime_mode_queue()];
        [self.v3Timer fire];
    });
}

- (void)stop {
    dispatch_async(realtime_mode_queue(), ^{
        ASLog(@"Stopping realtime mode");
        [self.timer invalidate];
        [self.v3Timer invalidate];
    });
}

- (void)writeRealtimeMode:(ASDevice *)device {
    if (device.connectionMode != ASDeviceConnectionModeDefault) {
        return;
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    
    if ([@"4.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        return;
    }
    
    ASLog(@"Setting realtime mode for %@", device.serialNumber);
    if ([@"3.0.1" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        if (!device.downloadCycleActive) {
            ASServiceV3 *service = device.services[[ASServiceV3 identifier].lowercaseString];
            [service.environmentalBufferCharacteristic write:@(0) withCompletion:^(NSError *error) {
                if (error) {
                    ASLog(@"Failed to update realtime mode");
                }
                else {
                    ASLog(@"Successfully read data from hardware for realtime mode");
                }
            }];
        }
        else {
            ASLog(@"Blocked");
        }
    }
    else if ([@"3.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        ASLog(@"3.0.0 realtime mode isn't supported - update your device (%@)", device);
    }
    else {
        ASServiceV1 *service = device.services[[ASServiceV1 identifier].lowercaseString];
        [service.environmentalRealtimeModeCharacteristic write:nil withCompletion:^(NSError *error) {
            if (!error) {
                ASLog(@"Successfully updated realtime mode");
            }
            else {
                ASLog(@"Failed to update realtime mode");
            }
        }];
    }
}

#pragma mark - Private Methods

- (void)timerCallback:(MSWeakTimer *)timer {
    dispatch_async(realtime_mode_queue(), ^{
        for (ASDevice *device in [self.systemManager.deviceManager autoConnectingAndConnectedDevices]) {
            if ([@"4.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
                return;
            }
            
            // Write realtime mode
            if ([@"3.0.0" compare:device.softwareRevision options:NSNumericSearch] == NSOrderedDescending) {
                [self writeRealtimeMode:device];
            }
        }
    });
}

- (void)timerCallbackV3:(MSWeakTimer *)timer {
    dispatch_async(realtime_mode_queue(), ^{
        for (ASDevice *device in [self.systemManager.deviceManager autoConnectingAndConnectedDevices]) {
            if ([@"4.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
                return;
            }
            
            // Write realtime mode
            if ([@"3.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
                [self writeRealtimeMode:device];
            }
        }
    });
}

- (void)writeRealtimeModeAllDevices {
    for (ASDevice *device in [self.systemManager.deviceManager autoConnectingAndConnectedDevices]) {
        if ([@"4.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
            return;
        }
        
        // Write realtime mode
        [self writeRealtimeMode:device];
    }
}

#pragma mark Notification Handlers

- (void)willEnterForeground:(NSNotification *)notification {
    // Start timer and write realtime mode to all devices
    [self start];
}

- (void)willEnterBackground:(NSNotification *)notification {
    // Stop timer
    [self stop];
}

@end
