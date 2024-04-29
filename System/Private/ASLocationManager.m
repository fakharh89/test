//
//  ASLocationManager.m
//  AS-iOS-Framework
//
//  Created by Michael Gordon on 4/2/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import "ASLocationManager.h"

#import "ASCloudPrivate.h"
#import "ASConnectionEventPrivate.h"
#import "ASContainerPrivate.h"
#import "ASDevicePrivate.h"
#import "ASDeviceManagerPrivate.h"
#import "ASHub.h"
#import "ASLog.h"
#import "ASNotifications.h"
#import "ASPUTQueue.h"
#import "ASRemoteNotificationManager.h"
#import "ASSystemManagerPrivate.h"
#import "NSData+ASHexString.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

static const NSInteger BSDelayedOusideRegionCheckTimeLimit = 30;

@implementation ASLocationManager

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _systemManager = systemManager;
        
        // Initialize location manager and set ourselves as the delegate
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.allowsBackgroundLocationUpdates = YES;
        ASLog(@"%d", [CLLocationManager authorizationStatus]);
        
        for (CLRegion *region in self.locationManager.monitoredRegions) {
            ASLog(@"Cleaning up region %@", region.identifier);
            if ([region isKindOfClass:[CLRegion class]]) {
                [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
            }
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
    
    return self;
}

- (void)startMonitoringDevice:(ASDevice *)device {
    NSString *beaconUUID = @"8b719ff8-d50e-67b4-e811-0633ccaa3ae9";
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconUUID];
    
    NSString *serialNumber = device.serialNumber;
    NSString *majorString = [NSString stringWithFormat:@"%@%@", [serialNumber substringWithRange:NSMakeRange(6, 2)], [serialNumber substringWithRange:NSMakeRange(4, 2)]];
    NSString *minorString = [NSString stringWithFormat:@"%@%@", [serialNumber substringWithRange:NSMakeRange(2, 2)], [serialNumber substringWithRange:NSMakeRange(0, 2)]];
    
    NSData *majorData = [NSData as_dataWithHexString:majorString];
    NSData *minorData = [NSData as_dataWithHexString:minorString];
    
    CLBeaconMajorValue major = CFSwapInt16BigToHost(*(int *)([majorData bytes]));
    CLBeaconMinorValue minor = CFSwapInt16BigToHost(*(int *)([minorData bytes]));
    
    device.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:device.serialNumber];
    device.beaconRegion.notifyEntryStateOnDisplay = YES;
    
    [self.locationManager startMonitoringForRegion:device.beaconRegion];
}

- (void)stopMonitoringDevice:(ASDevice *)device {
    [self.locationManager stopMonitoringForRegion:device.beaconRegion];
    device.beaconRegion = nil;
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(nonnull CLRegion *)region {
    ASDevice *device = [self deviceFromSerialNumber:region.identifier];
    
    // Ignore devices without peripherals because they are likely stuck devices that are still in the bluetooth cache.
    // In the future, we can use this to infer a connection between a stuck peripheral and a device.
    if (!device || !device.peripheral) {
        return;
    }
    
    ASConnectionEventReason reason;
    if (device.regionState == ASRegionStateUnknown) {
        switch (state) {
            case CLRegionStateUnknown:
                reason = ASConnectionEventReasonStartedUnknownRegion;
                break;
            case CLRegionStateInside:
                reason = ASConnectionEventReasonStartedInsideRegion;
                break;
            case CLRegionStateOutside:
                reason = ASConnectionEventReasonStartedOutsideRegion;
                break;
        }
    }
    else {
        switch (state) {
            case CLRegionStateUnknown:
                reason = ASConnectionEventReasonTransitioningUnknownRegion;
                break;
            case CLRegionStateInside:
                reason = ASConnectionEventReasonTransitioningInsideRegion;
                break;
            case CLRegionStateOutside:
                reason = ASConnectionEventReasonTransitioningOutsideRegion;
                break;
        }
    }
    
    if (state == CLRegionStateOutside) {
        [self delayedOusideRegionCheckForDevice:device reason:reason region:region];
    }
    else {
        [self handleLocationState:state forDevice:device reason:reason region:region];
    }
}

- (void)delayedOusideRegionCheckForDevice:(ASDevice *)device reason:(ASConnectionEventReason)reason region:(nonnull CLRegion *)region {
    ASLog(@"Device %@ may have exited region - checking.", device.serialNumber);
    
    NSDate *now = [NSDate date];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(BSDelayedOusideRegionCheckTimeLimit * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ASLog(@"Device %@ current state: %@", device.serialNumber, @(device.regionState));
        
        BOOL isDeviceNotOutise = device.regionState != ASRegionStateOutside;
        BOOL isConnected = device.state == ASDeviceBLEStateConnected;
        BOOL connectedInLast30Secs = [self isDeviceConnected:device since:now];
        BOOL disconnectedInLast30Secs = [self isDeviceDisconnected:device since:now];
        
        if (isDeviceNotOutise && !isConnected && !(connectedInLast30Secs || disconnectedInLast30Secs)) {
            ASLog(@"Device %@ exited region.", device.serialNumber);
            device.regionState = ASRegionStateOutside;
            
            [self handleLocationState:CLRegionStateOutside forDevice:device reason:reason region:region];
        }
        else {
            ASLog(@"Device %@ had false positive exiting region.", device.serialNumber);
        }
    });
}

- (BOOL)isDeviceConnected:(ASDevice *)device since:(NSDate *)date {
    if (!device.lastConnectedDate) {
        return NO;
    }
    
    return [date compare:device.lastConnectedDate] == NSOrderedAscending;
}

- (BOOL)isDeviceDisconnected:(ASDevice *)device since:(NSDate *)date {
    if (!device.lastDisconnectedDate) {
        return NO;
    }
    
    return [date compare:device.lastDisconnectedDate] == NSOrderedAscending;
}

- (void)handleLocationState:(CLRegionState)state forDevice:(ASDevice *)device reason:(ASConnectionEventReason *)reason region:(nonnull CLRegion *)region {
    ASLog(@"Did determine state (%@) for device %@", [ASConnectionEvent stringForReason:reason], region.identifier);
    
    device.regionState = [self ASRegionStateForCoreLocationRegionState:state];
    [self handleEventForDevice:device type:ASConnectionEventTypeProximity reason:reason];
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceRegionStateDeterminedNotification object:device];
    
    [self.systemManager.cloud.PUTQueue delayedFire];
}

- (ASDevice *)deviceFromSerialNumber:(NSString *)serialNumber {
    ASDevice *device = nil;
    for (ASDevice *searchDevice in self.systemManager.deviceManager.devices) {
        if ([searchDevice.serialNumber compare:serialNumber] == NSOrderedSame) {
            device = searchDevice;
            break;
        }
    }
    
    return device;
}

- (void)handleEventForDevice:(ASDevice *)device type:(ASConnectionEventType)type reason:(ASConnectionEventReason)reason {
    ASHub *hub = self.systemManager.cloud.remoteNotificationManager.currentHub;
    ASConnectionEvent *connectionEvent = [[ASConnectionEvent alloc] initWithDate:[NSDate date] ingestionDate:nil hubIdentifier:hub.identifier type:type reason:reason];
    [device.container addNewConnectionEvent:connectionEvent];
}

- (CLRegionState)coreLocationRegionStateForASRegionState:(ASRegionState)regionState {
    switch (regionState) {
        case ASRegionStateInside:
            return CLRegionStateInside;
        case ASRegionStateOutside:
            return CLRegionStateOutside;
        case ASRegionStateUnknown:
            return CLRegionStateUnknown;
    }
}

- (ASRegionState)ASRegionStateForCoreLocationRegionState:(CLRegionState)regionState {
    switch (regionState) {
        case CLRegionStateInside:
            return ASRegionStateInside;
        case CLRegionStateOutside:
            return ASRegionStateOutside;
        case CLRegionStateUnknown:
            return ASRegionStateUnknown;
    }
}

@end
