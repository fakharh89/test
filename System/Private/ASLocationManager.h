//
//  ASLocationManager.h
//  AS-iOS-Framework
//
//  Created by Michael Gordon on 4/2/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@class ASDevice;
@class ASSystemManager;

@interface ASLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) ASSystemManager *systemManager;
@property (nonatomic, strong) CLLocationManager *locationManager;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager NS_DESIGNATED_INITIALIZER;

- (void)startMonitoringDevice:(ASDevice *)device;
- (void)stopMonitoringDevice:(ASDevice *)device;

@end
