//
//  NSArray+ASSearch.m
//  Blustream
//
//  Created by Michael Gordon on 2/16/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "NSArray+ASSearch.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "ASCloud.h"
#import "ASContainer.h"
#import "ASDevicePrivate.h"
#import "ASSystemManager.h"

@implementation NSArray (ASSearch)

// Get index given a peripheral from list of discovered peripherals
// Return -1 if not found
- (NSInteger)indexOfPeripheral:(CBPeripheral *)peripheral {
    NSInteger index = -1;
    for (NSInteger i = 0; i < self.count; i++) {
        ASDevice *knownDevice = [self objectAtIndex:i];
        if ([peripheral.identifier.UUIDString compare:knownDevice.uuid.UUIDString] == NSOrderedSame) {
            index = i;
            break;
        }
    }
    return index;
}

// Get index given a serial number from list of discovered peripherals
// Return -1 if not found
- (NSInteger)indexOfSerialNumber:(NSString *)serial {
    NSInteger index = -1;
    for (NSInteger i = 0; i < self.count; i++) {
        ASDevice *knownDevice = [self objectAtIndex:i];
        if ([serial compare:knownDevice.serialNumber] == NSOrderedSame) {
            index = i;
            break;
        }
    }
    return index;
}

- (NSInteger)indexOfIdentifer:(NSString *)identifier {
    NSInteger index = -1;
    for (NSInteger i = 0; i < self.count; i++) {
        ASContainer *knownContainer = [self objectAtIndex:i];
        if ([identifier compare:knownContainer.identifier] == NSOrderedSame) {
            index = i;
            break;
        }
    }
    return index;
}

- (NSArray *)arrayWithAutoConnectingDevices {
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    for (ASDevice *device in self) {
        if (device.autoconnect) {
            [devices addObject:device];
        }
    }
    
    return [NSArray arrayWithArray:devices];
}

- (NSArray *)arrayWithAutoConnectingAndConnectedDevices {
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    for (ASDevice *device in self) {
        if (device.autoconnect && (device.state == ASDeviceBLEStateConnected)) {
            [devices addObject:device];
        }
    }
    
    return [NSArray arrayWithArray:devices];
}

- (NSArray *)arrayWithLinkedDevices {
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    for (ASDevice *device in self) {
        if (device.container) {
            [devices addObject:device];
        }
    }
    
    return [NSArray arrayWithArray:devices];
}

- (NSArray *)arrayWithUnlinkedDevices {
    NSMutableArray *devices = [[NSMutableArray alloc] init];
    for (ASDevice *device in self) {
        if (!device.container) {
            [devices addObject:device];
        }
    }
    
    return [NSArray arrayWithArray:devices];
}

- (NSArray *)arrayWithLinkedContainers {
    NSMutableArray *containers = [[NSMutableArray alloc] init];
    for (ASContainer *container in self) {
        if (container.device) {
            [containers addObject:container];
        }
    }
    
    return [NSArray arrayWithArray:containers];
}

- (NSArray *)arrayWithUnlinkedContainers {
    NSMutableArray *containers = [[NSMutableArray alloc] init];
    for (ASContainer *container in self) {
        if (!container.device) {
            [containers addObject:container];
        }
    }
    
    return [NSArray arrayWithArray:containers];
}

@end
