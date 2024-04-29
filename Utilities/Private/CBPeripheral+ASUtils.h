//
//  CBPeripheral+ASUtils.h
//  Blustream
//
//  Created by Michael Gordon on 6/30/16.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (ASUtils)

- (CBCharacteristic *)getCharacteristic:(NSString *)characteristicUUIDString;
- (CBService *)getService:(NSString *)serviceUUIDString;

@end
