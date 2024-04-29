//
//  ASDeviceManager.h
//  Blustream
//
//  Created by Michael Gordon on 6/26/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

/**
 *  These constants indicate the bluetooth state of the user's phone/tablet.  They parallel
 *  CBCentralManagerState.
 */
typedef NS_ENUM(NSInteger, ASBluetoothState) {
    /**
     *  The current bluetooth state is unknown and an update is pending.
     */
    ASBluetoothStateUnknown = 0,
    /**
     *  The phone lost connection to the internal, Apple BLE service. Update is pending.
     */
    ASBluetoothStateResetting,
    /**
     *  The phone or tablet does not support BLE.
     */
    ASBluetoothStateUnsupported,
    /**
     *  The app is not authorized to use BLE.
     */
    ASBluetoothStateUnauthorized,
    /**
     *  Bluetooth is turned off on the phone.
     */
    ASBluetoothStatePoweredOff,
    /**
     *  Bluetooth is enabled on the phone.
     */
    ASBluetoothStatePoweredOn
};

@class ASDevice;

/**
 *  The `ASDeviceManager` class contains methods for managing the list of devices.  Access it through the
 *  `ASSystemManager` instance property.  Linked devices are persisted between sessions.
 */
@interface ASDeviceManager : NSObject

/**
 *  The list of all Acoustic Stream compatible devices that framework has detected. (read-only)
 *
 *  This array of devices includes all devices that the user has encountered.  All are type ASDevice.
 *  This includes any device that the user owns or is broadcasting nearby.  Any device that is owned by
 *  the user is automatically serialized and deserialized.  To remove non-owned devices nearby, use the
 *  `cleanDeviceArray` method.
 */
@property (strong, readonly, nonatomic) NSArray *devices;

@property (strong, readonly, nonatomic) NSArray *stuckDevices;

/**
 *  The state of bluetooth scanning (on or off). (read-only)
 *
 *  This boolean represents whether the bluetooth manager is scanning for hardware.  It can be changed
 *  using the functions startScanning and stopScanning.
 */
@property (assign, readonly, nonatomic) BOOL isScanning;


@property (assign, readonly, nonatomic) ASBluetoothState bluetoothState;

/**
 *  Removes all devices without containers.  These should only be devices that are advertising nearby.
 *  Each time a device advertises, it is added back to the `devices` array.
 */
- (void)cleanDeviceArray;

/**
 *  Returns a subset of `linkedDevices` only including autoconnecting devices.
 *
 *  @return An NSArray of ASDevices.
 */
- (NSArray *)autoConnectingDevices;

/**
 *  Returns a subset of `linkedDevices` only including autoconnecting devices that are currently connected.
 *
 *  @return An NSArray of ASDevices.
 */
- (NSArray *)autoConnectingAndConnectedDevices;

/**
 *  Returns a subset of `devices` only including devices that are linked to containers.
 *
 *  @return An NSArray of ASDevices.
 */
- (NSArray *)linkedDevices;

/**
 *  Returns a subset of `devices` only included devices that are unlinked to containers.
 *
 *  @return An NSArray of ASDevices.
 */
- (NSArray *)unlinkedDevices;

/**
 *  Starts scanning for ASDevices nearby.
 *
 *  Scanning starts automatically when the app starts and the CoreBluetooth central manager is restored.
 *  It is recommended to restart scanning when the app is foregrounded.
 */
- (void)startScanning;

/**
 *  Stops scanning for ASDevices nearby.
 *
 *  It is not recommended to stop scanning unless it will be restarted immediately afterwards.
 */
- (void)stopScanning;

- (instancetype)init NS_UNAVAILABLE;

@end
