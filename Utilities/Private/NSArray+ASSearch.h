//
//  NSArray+ASSearch.h
//  Blustream
//
//  Created by Michael Gordon on 2/16/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

@interface NSArray (ASSearch)

// Get index given a peripheral from list of discovered devices
// Return -1 if not found
- (NSInteger)indexOfPeripheral:(CBPeripheral *)peripheral;

// Get index given a serial number from list of discovered devices
// Return -1 if not found
- (NSInteger)indexOfSerialNumber:(NSString *)serial;

// Get index given a serial number from list of containers
- (NSInteger)indexOfIdentifer:(NSString *)identifier;

// Return a list of autoconnect devices
- (NSArray *)arrayWithAutoConnectingDevices;

// Return a list of autoconnecting and connected devices
- (NSArray *)arrayWithAutoConnectingAndConnectedDevices;

// Return a list of devices that the user owns
- (NSArray *)arrayWithLinkedDevices;

- (NSArray *)arrayWithUnlinkedDevices;

- (NSArray *)arrayWithLinkedContainers;

- (NSArray *)arrayWithUnlinkedContainers;

@end
