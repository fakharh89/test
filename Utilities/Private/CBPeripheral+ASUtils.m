//
//  CBPeripheral+ASUtils.m
//  Blustream
//
//  Created by Michael Gordon on 6/30/16.
//
//

#import "CBPeripheral+ASUtils.h"

@implementation CBPeripheral (ASUtils)

- (CBCharacteristic *)getCharacteristic:(NSString *)characteristicUUIDString {
    CBCharacteristic *characteristic = nil;
    
    for (CBService *knownService in self.services) {
        for (CBCharacteristic *knownCharacteristic in knownService.characteristics) {
            if ([knownCharacteristic.UUID.data isEqualToData:[CBUUID UUIDWithString:characteristicUUIDString].data]) {
                characteristic = knownCharacteristic;
                break;
            }
        }
        
        if (characteristic) {
            break;
        }
    }
    
    return characteristic;
}

- (CBService *)getService:(NSString *)serviceUUIDString {
    CBService *service = nil;
    for (CBService *knownService in self.services) {
        if ([knownService.UUID.data isEqualToData:[CBUUID UUIDWithString:serviceUUIDString].data]) {
            service = knownService;
            break;
        }
    }
    return service;
}

@end
