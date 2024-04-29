//
//  ASBLEInterface.m
//  Blustream
//
//  Created by Michael Gordon on 2/16/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASBLEInterface.h"

#import "ASAdvertisementData.h"
#import "ASAttribute.h"
#import "ASAttributeBuilder.h"
#import "ASBLEDefinitions.h"
#import "ASConfig.h"
#import "ASCloudPrivate.h"
#import "ASDeviceManagerPrivate.h"
#import "ASDevice+BLEUpdate.h"
#import "ASDevice+ASAttributeFromCBAttribute.h"
#import "ASLog.h"
#import "ASManufacturerData.h"
#import "ASNotifications.h"
#import "ASOverTheAirUpdateModeHandler.h"
#import "ASSystemManagerPrivate.h"
#import "ASRealtimeMode.h"
#import "ASRegistrationModeHandler.h"
#import "ASRoutineConglomerate.h"
#import "NSArray+ASSearch.h"
#import "NSDictionary+ASAdvertisementCheck.h"
#import "NSString+ASCompatibility.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#import "ASEnvironmentalBufferCharacteristic.h"
#import "ASServiceV3.h"
#import "ASServiceV4.h"

dispatch_queue_t ble_manager_processing_queue(void) {
    static dispatch_queue_t as_ble_manager_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        as_ble_manager_processing_queue = dispatch_queue_create("com.acoustic-stream.ble-manager.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    return as_ble_manager_processing_queue;
}

@interface ASBLEInterface()

@property (nonatomic, weak) ASSystemManager *systemManager;

@end

@implementation ASBLEInterface

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _isScanning = NO;
        _systemManager = systemManager;
        
        // Start BT Stuff
        NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey: @(NO),
                                  CBCentralManagerOptionRestoreIdentifierKey: @"ASCentralManagerIdentifier"};
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:ble_manager_processing_queue() options:options];
        
        if (systemManager.config.realtimeMode) {
            _realtimeMode = [[ASRealtimeMode alloc] initWithSystemManager:systemManager];
        }
        
        _defaultHandler = [[ASDefaultBLEHandler alloc] initWithSystemManager:systemManager];
        _registrationHandler = [[ASRegistrationModeHandler alloc] initWithSystemManager:systemManager];
        _overTheAirUpdateHandler = [[ASOverTheAirUpdateModeHandler alloc] initWithSystemManager:systemManager];
        _needsRestore = NO;
    }
    
    return self;
}

#pragma mark - CBCentralManagerDelegate Implementation

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:
            ASBLELog(@"BLE Flow: Central Manager State Update to CBManagerStateUnknown");
            self.isScanning = NO;
            break;
            
        case CBManagerStateResetting:
            ASBLELog(@"BLE Flow: Central Manager State Update to CBManagerStateResetting");
            self.isScanning = NO;
            break;
            
        case CBManagerStateUnsupported:
            ASBLELog(@"BLE Flow: Central Manager State Update to CBManagerStateUnsupported");
            self.isScanning = NO;
            break;
            
        case CBManagerStateUnauthorized:
            ASBLELog(@"BLE Flow: Central Manager State Update to CBManagerStateUnauthorized");
            self.isScanning = NO;
            break;
            
        case CBManagerStatePoweredOff:
            ASBLELog(@"BLE Flow: Central Manager State Update to CBManagerStatePoweredOff");
            self.isScanning = NO;
            break;
            
        case CBManagerStatePoweredOn: {
            ASBLELog(@"BLE Flow: Central Manager State Update to CBManagerStatePoweredOn");
            
            if (self.systemManager.cloud.userStatus != ASUserLoggedIn) {
                return;
            }
            
            // TODO if a device is restored and it is already connected, disconnect and reconnect.
            // Need setup function to get called to setup notifications for connection routines
            
            // Get list existing peripherals and update ASDevice.peripherals
            if (self.systemManager.deviceManager.devices.count > 0) {
                void (^restoration)(id, NSUInteger, BOOL *) = ^(id obj, NSUInteger idx, BOOL *stop) {
                    NSInteger index = [self.systemManager.deviceManager.devices indexOfPeripheral:obj];
                    ASDevice *device = nil;
                    
                    if (index == -1) {
                        for (CBService *service in [obj services]) {
                            if ([service.UUID.data isEqualToData:[CBUUID UUIDWithString:ASServiceUUID].data]
                                || [service.UUID.data isEqualToData:[CBUUID UUIDWithString:ASServiceUUIDv3].data]
                                || [service.UUID.data isEqualToData:[CBUUID UUIDWithString:ASServiceUUIDv4].data]) {
                                for (CBCharacteristic *characteristic in service.characteristics) {
                                    if ([characteristic.UUID.data isEqualToData:[CBUUID UUIDWithString:ASSerialNoCharactUUID].data]) {
                                        index = [self.systemManager.deviceManager.devices indexOfSerialNumber:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]];
                                    }
                                }
                            }
                        }
                    }
                    
                    if (index != -1) {
                        device = [self.systemManager.deviceManager.devices objectAtIndex:index];
                        if (obj != device.peripheral) {
                            ASLog(@"Device restored %@", device.serialNumber);
                            device.peripheral = obj;
                            device.peripheral.delegate = self;
                            // Don't connect here.  Multiple connect calls while restoring can cause
                            // duplicated callbacks.
                            //                            if (device.autoconnect) {
                            //                                [self connectToDevice:device];
                            //                            }
                        }
                    }
                    else {
                        ASLog(@"Error restoring peripheral: %@", obj);
                        CBPeripheral *peripheral = obj;
                        [self.centralManager cancelPeripheralConnection:peripheral];
                    }
                };
                
                if (self.needsRestore) {
                    ASLog(@"Attempting to restore based on CBCentralManager restoration");
                    NSArray *knownPeripheralsByRestore = self.restoreDictionary[CBCentralManagerRestoredStatePeripheralsKey]; //(CBPeripheral *)
                    
                    [knownPeripheralsByRestore enumerateObjectsUsingBlock:restoration];
                }
                
                ASLog(@"Attempting to restore based on identifier");
                NSMutableArray *identifiers = [[NSMutableArray alloc] init];
                for (ASDevice *device in self.systemManager.deviceManager.devices) {
                    if (device.uuid) {
                        [identifiers addObject:device.uuid];
                    }
                }
                NSArray *knownPeripheralsByID = [self.centralManager retrievePeripheralsWithIdentifiers:identifiers];
                
                [knownPeripheralsByID enumerateObjectsUsingBlock:restoration];
                
                ASLog(@"Attempting to restore based on service");
                NSArray<NSString *> *uuidStringArray = @[ASServiceUUID, ASServiceUUIDv3, ASServiceUUIDv4];
                
                NSMutableArray<CBUUID *> *uuidArray = [NSMutableArray new];
                for (NSString *string in uuidStringArray) {
                    [uuidArray addObject:[CBUUID UUIDWithString:string]];
                }
                
                NSArray *knownPeripheralsByService = [self.centralManager retrieveConnectedPeripheralsWithServices:[NSArray arrayWithArray:uuidArray]];
                
                [knownPeripheralsByService enumerateObjectsUsingBlock:restoration];
            }
            
            // Restore or start scanning again
            if (self.needsRestore) {
                //                NSArray *serviceUUIDs = self.restoreDictionary[CBCentralManagerRestoredStateScanServicesKey]; //(CBUUID *)
                //                NSDictionary *scanOptions = self.restoreDictionary[CBCentralManagerRestoredStateScanOptionsKey];
                
                //                [self.centralManager scanForPeripheralsWithServices:serviceUUIDs options:scanOptions];
                [self startScanningForDevices];
                
                self.needsRestore = NO;
            }
            else {
                [self startScanningForDevices];
            }
            
            for (ASDevice *device in self.systemManager.deviceManager.devices) {
                // TODO The app might be starting up with the hardware connected already.  Need to
                // make sure this is the right logic.  Could need to just disconnect and then reconnect
                if (device.state == ASDeviceBLEStateConnected) {
                    [self centralManager:self.centralManager didConnectPeripheral:device.peripheral];
                }
                if (device.autoconnect) {
                    [self connectToDevice:device];
                }
            }
            
            break;
        }
            
        default:
            ASLog(@"CBCentralManager state is literally missing!");
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceManagerStateChangedNotification object:nil];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (self.systemManager.cloud.userStatus != ASUserLoggedIn) {
        return;
    }
    
    if (!peripheral) {
        //ASLog(@"Discovered nil peripheral");
        return;
    }
    
    if (!peripheral.identifier) {
        //ASLog(@"Discovered peripheral without UUID");
        return;
    }
    
    ASDeviceConnectionMode mode = [advertisementData as_deviceConnectionMode];
    ASDevice *device = nil;
    NSString *serialNumber = nil;
    ASAdvertisementData *processedAdvertisementData = nil;
    
    if (mode == ASDeviceConnectionModeUnknown) {
        return;
    }
    else if (mode == ASDeviceConnectionModeOverTheAirUpdate) {
        // Check unstuck array first
        NSInteger foundIndex = [self.systemManager.deviceManager.devices indexOfPeripheral:peripheral];
        if (foundIndex == -1) {
            // Check if it's already stuck
            foundIndex = [self.systemManager.deviceManager.stuckDevices indexOfPeripheral:peripheral];
            
            if (foundIndex == -1) {
                // Device is stuck in OTAU mode and never been found.  Need to try to recover it
                device = [[ASDevice alloc] initInBootloaderModeWithPeripheral:peripheral];
                [[self getHandlerForDevice:device] didDiscoverDevice:device];
            }
            else {
                device = [self.systemManager.deviceManager.stuckDevices objectAtIndex:foundIndex];
            }
//            return;
        }
        else {
            device = [self.systemManager.deviceManager.devices objectAtIndex:foundIndex];
        }
    }
    else {
        processedAdvertisementData = [advertisementData as_advertisementData];
        serialNumber = processedAdvertisementData.manufacturerData.serialNumber;
        
        if (!serialNumber || ![serialNumber as_serialNumberIsCompatible]) {
            //ASLog(@"Discovered peripheral with bad advertisement data");
            return;
        }
        
        // Check if we know this device or not
        NSInteger foundIndex = [self.systemManager.deviceManager.devices indexOfSerialNumber:processedAdvertisementData.manufacturerData.serialNumber];
        
        if (foundIndex == -1) {
            device = [[ASDevice alloc] initWithSerialNumber:processedAdvertisementData.manufacturerData.serialNumber peripheral:peripheral];
            [[self getHandlerForDevice:device] didDiscoverDevice:device];
        }
        else {
            device = [self.systemManager.deviceManager.devices objectAtIndex:foundIndex];
        }
    }
    
    if (device.peripheral != peripheral) {
        device.peripheral = peripheral;
    }
    
    // If device came from server it needs it's uuid set upon connect
    if (!device.uuid) {
        device.uuid = peripheral.identifier;
    }
    
    [device touch];
    
    [[self getHandlerForDevice:device] device:device advertisedWithData:processedAdvertisementData];
    [[self getHandlerForDevice:device] device:device didReadRSSI:RSSI error:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    
    ASDevice *device = [self getDeviceFromPeripheral:peripheral];
    if (!device) {
        ASLog(@"Connected to unknown peripheral: %@ (%@)", peripheral.name, peripheral.identifier.UUIDString);
        [central cancelPeripheralConnection:peripheral];
        return;
    }
    
    [device touch];
    
    [[self getHandlerForDevice:device] didConnectToDevice:device];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    ASDevice *device = [self getDeviceFromPeripheral:peripheral];
    if (!device) {
        ASLog(@"Disconnected from unknown peripheral: %@ (%@)", peripheral.name, peripheral.identifier.UUIDString);
        return;
    }
    
    if (!error) {
        [device touch];
    }
    
    [[self getHandlerForDevice:device] didDisconnectFromDevice:device error:error];
    
    device.services = nil;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    ASDevice *device = [self getDeviceFromPeripheral:peripheral];
    if (!device) {
        ASLog(@"Failed to connected to unknown peripheral: %@ (%@)", peripheral.name, peripheral.identifier.UUIDString);
        return;
    }
    
    [[self getHandlerForDevice:device] didFailToConnectToDevice:device error:error];
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    ASLog(@"Will Restore BLE State");
    
    self.needsRestore = YES;
    self.restoreDictionary = dict;
}

#pragma mark - CBPeripheralDelegate Implementation
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    ASDevice *device = [self getDeviceFromPeripheral:peripheral];
    if (!device) {
        ASLog(@"Discovered services of unknown peripheral: %@ (%@)", peripheral.name, peripheral.identifier.UUIDString);
        [self.centralManager cancelPeripheralConnection:peripheral];
        return;
    }
    
    if (!error) {
        [device touch];
    }
    
    NSArray<id<ASService>> *services = [ASAttributeBuilder servicesForDevice:device];
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (id<ASService> service in services) {
        [mutableDictionary addEntriesFromDictionary:@{[[service class] identifier].lowercaseString : service}];
    }
    
    device.services = [NSDictionary dictionaryWithDictionary:mutableDictionary];;
    
    if (device.peripheral.services) {
        BOOL isOTAUMode = NO;
        for (CBService *service in device.peripheral.services) {
            if ([ASOTAUBootServiceUUID caseInsensitiveCompare:service.UUID.UUIDString] == NSOrderedSame) {
                isOTAUMode = YES;
                break;
            }
        }
        if (isOTAUMode) {
            device.connectionMode = ASDeviceConnectionModeOverTheAirUpdate;
        }
    }
    
    [[self getHandlerForDevice:device] device:device didDiscoverServicesWithError:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    ASDevice *device = [self getDeviceFromPeripheral:peripheral];
    if (!device) {
        ASLog(@"Discovered characteristics of unknown peripheral: %@ (%@)", peripheral.name, peripheral.identifier.UUIDString);
        [self.centralManager cancelPeripheralConnection:peripheral];
        return;
    }
    
    if (!error) {
        [device touch];
    }
    
    id<ASService> thisService = [device as_serviceFromService:service];
    
    if (!thisService) {
        ASLog(@"Couldn't find service!");
    }
    
    NSArray<id<ASCharacteristic>> *characteristics = [ASAttributeBuilder characteristicsForService:thisService device:device];
    
    for (id<ASCharacteristic> deviceCharacteristic in characteristics) {
        [thisService addCharacteristic:deviceCharacteristic];
    }
    
    [[self getHandlerForDevice:device] device:device didDiscoverCharacteristicsForService:thisService error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    ASDevice *device = [self getDeviceFromPeripheral:peripheral];
    if (!device) {
        ASLog(@"Updated value of unknown peripheral: %@ (%@)", peripheral.name, peripheral.identifier.UUIDString);
        [self.centralManager cancelPeripheralConnection:peripheral];
        return;
    }
    
    if (!error) {
        [device touch];
    }
    
    id<ASCharacteristic> thisCharacteristic = [device as_characteristicFromCharacteristic:characteristic];
    
    NSAssert([thisCharacteristic conformsToProtocol:@protocol(ASUpdatableCharacteristic)], @"Characteristic doesn't conform to ASReadableCharacteristic or ASNotifiableCharacteristic");
    
//    if (!thisCharacteristic) {
//        ASLog(@"Couldn't find characteristic! %@", characteristic);
//    }
//    
//    if (![thisCharacteristic conformsToProtocol:@protocol(ASUpdatableCharacteristic)]) {
//        ASLog(@"%@ doesn't conform to ASReadableCharacteristic or ASNotifiableCharacteristic", [[thisCharacteristic class] identifier]);
//    }
    
    NSString *name = [ASBLECharacteristicHelper characteristicNameFromIdentifier:characteristic.UUID.UUIDString];
    
    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, Read: %@, Data: %@.", device.serialNumber, name, characteristic.value]);
    
    [[self getHandlerForDevice:device] device:device didUpdateValueForCharacteristic:(id<ASUpdatableCharacteristic>)thisCharacteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    ASDevice *device = [self getDeviceFromPeripheral:peripheral];
    if (!device) {
        ASLog(@"Wrote to unknown peripheral: %@ (%@)", peripheral.name, peripheral.identifier.UUIDString);
        [self.centralManager cancelPeripheralConnection:peripheral];
        return;
    }
    
    ASBLELog([NSString stringWithFormat:@"BLE Flow: Serial Number: %@, Write to %@, Data: %@", device.serialNumber, [characteristic class], characteristic.value]);
    
    if (!error) {
        [device touch];
    }
    
    id<ASCharacteristic> thisCharacteristic = [device as_characteristicFromCharacteristic:characteristic];
    
    NSAssert([thisCharacteristic conformsToProtocol:@protocol(ASWriteableCharacteristic)], @"Characteristic doesn't conform to ASWriteableCharacteristic");
    
    [[self getHandlerForDevice:device] device:device didWriteValueForCharacteristic:(id<ASWriteableCharacteristic>)thisCharacteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    ASDevice *device = [self getDeviceFromPeripheral:peripheral];
    if (!device) {
        ASLog(@"Set notify for unknown peripheral: %@ (%@)", peripheral.name, peripheral.identifier.UUIDString);
        [self.centralManager cancelPeripheralConnection:peripheral];
        return;
    }
    
    if (!error) {
        [device touch];
    }
    
    id<ASCharacteristic> thisCharacteristic = [device as_characteristicFromCharacteristic:characteristic];
    
    NSAssert([thisCharacteristic conformsToProtocol:@protocol(ASNotifiableCharacteristic)], @"Characteristic doesn't conform to ASNotifiableCharacteristic");
    
    [[self getHandlerForDevice:device] device:device didUpdateNotificationStateForCharacteristic:(id<ASNotifiableCharacteristic>)thisCharacteristic error:error];
}

//- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
//    ASDevice *device = [self getDeviceFromPeripheral:peripheral];
//    if (!device) {
//        ASLog(@"Read RSSI of unknown peripheral: %@ (%@)", peripheral.name, peripheral.identifier.UUIDString);
//        [self.centralManager cancelPeripheralConnection:peripheral];
//        return;
//    }
//
//    [[self getHandlerForDevice:device] device:device didReadRSSI:peripheral.RSSI error:error];
//}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    ASDevice *device = [self getDeviceFromPeripheral:peripheral];
    if (!device) {
        ASLog(@"Read RSSI of unknown peripheral: %@ (%@)", peripheral.name, peripheral.identifier.UUIDString);
        [self.centralManager cancelPeripheralConnection:peripheral];
        return;
    }
    
    if (!error) {
        [device touch];
    }
    
    [[self getHandlerForDevice:device] device:device didReadRSSI:RSSI error:error];
}

#pragma mark - Device Discovery

- (void)startScanningForDevices {
    if (self.centralManager.state != CBManagerStatePoweredOn) {
        return;
    }
    ASLog(@"Starting scan");
    self.isScanning = YES;
    
    // Service option must be in advertising data
    // Don't use [ASRoutineConglomerate allServices] for scanning.  We only want
    // devices with our services (current v1 and v3)
//    NSArray *services = @[[CBUUID UUIDWithString:ASServiceUUID],
//                          [CBUUID UUIDWithString:ASServiceUUIDv3],
//                          [CBUUID UUIDWithString:ASServiceUUIDv4],
//                          [CBUUID UUIDWithString:ASOTAUBootServiceUUID],
//                          [CBUUID UUIDWithString:ASBatteryServiceUUID]];
    
    // This is nil in order to pick up devices in boot mode
    [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

- (void)stopScanningForDevices {
    if (self.centralManager.state != CBManagerStatePoweredOn) {
        return;
    }
    ASLog(@"Stopping scan");
    self.isScanning = NO;
    
    // Stop scanning for peripherals
    [self.centralManager stopScan];
}

#pragma mark - Device Connections

// Attempt to connect to a specified device peripheral
- (void)connectToDevice:(ASDevice *)device {
    if (device.serialNumber) {
        [self connectToDevice:device mode:ASDeviceConnectionModeDefault];
    }
    else {
        [self connectToDevice:device mode:ASDeviceConnectionModeOverTheAirUpdate];
    }
}

- (void)connectToDevice:(ASDevice *)device mode:(ASDeviceConnectionMode)mode {
    if (!device.peripheral) {
        return;
    }
    
    if (device.peripheral.state == CBPeripheralStateConnected) {
        ASLog(@"Already connected to %@", device.serialNumber);
        if (device.connectionMode != mode) {
            ASLog(@"ERROR - Connection mode mismatch!");
        }
        return;
    }
    
    if (device.peripheral.state == CBPeripheralStateConnecting) {
        ASLog(@"Already connecting to %@", device.serialNumber);
        if (device.connectionMode != mode) {
            ASLog(@"ERROR - Connection mode mismatch!");
        }
        return;
    }
    
    ASLog(@"Connecting to %@", device.serialNumber);
    
    device.connectionMode = mode;
    
    // Initiate the connection - we don't need any of the optional parameters, so that param is just nil
    [self.centralManager connectPeripheral:device.peripheral options:nil];
}

// Disconnect or cancel connection with a device
- (void)disconnectFromDevice:(ASDevice *)device {
    if (!device.peripheral) {
        return;
    }
    
    if (device.peripheral.state == CBPeripheralStateDisconnected) {
        ASLog(@"Already disconnected from %@", device.serialNumber);
        return;
    }
    
    if (device.peripheral.state == CBPeripheralStateDisconnecting) {
        ASLog(@"Already disconnecting from %@", device.serialNumber);
        return;
    }
    
    ASLog(@"Disconnecting from %@", device.serialNumber);
    
    // Shut down the connection
    [self.centralManager cancelPeripheralConnection:device.peripheral];
}

#pragma mark - Private Methods
- (ASDevice *)getDeviceFromPeripheral:(CBPeripheral *)peripheral {
    ASDevice *device = nil;
    NSInteger peripheralIndex = [self.systemManager.deviceManager.devices indexOfPeripheral:peripheral];
    if (peripheralIndex != -1) {
        device = [self.systemManager.deviceManager.devices objectAtIndex:peripheralIndex];
    }
    if (!device) {
        peripheralIndex = [self.systemManager.deviceManager.stuckDevices indexOfPeripheral:peripheral];
        if (peripheralIndex != -1) {
            device = [self.systemManager.deviceManager.stuckDevices objectAtIndex:peripheralIndex];
        }
    }
    return device;
}

- (id<ASBLEInterfaceDelegate>)getHandlerForDevice:(ASDevice *)device {
    if (device.connectionMode == ASDeviceConnectionModeRegistration) {
        return self.registrationHandler;
    }

    if (device.connectionMode == ASDeviceConnectionModeOverTheAirUpdate) {
        return self.overTheAirUpdateHandler;
    }
    
    return self.defaultHandler;
}

@end
