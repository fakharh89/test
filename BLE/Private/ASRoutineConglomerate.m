//
//  ASRoutineConglomerate.m
//  Blustream
//
//  Created by Michael Gordon on 7/13/16.
//
//

#import "ASRoutineConglomerate.h"

#import "ASBLEInterface.h"
#import "ASV1ConnectionRoutine.h"
#import "ASV2ConnectionRoutine.h"
#import "ASV3ConnectionRoutine.h"
#import "ASV4ConnectionRoutine.h"
#import "ASOverTheAirUpdateConnectionRoutine.h"

@implementation ASRoutineConglomerate

#pragma Private Methods

+ (NSArray<Class<ASDataHandlingRoutine>> *)allConnectionRoutineClasses {
    static NSArray<Class> *classes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = @[[ASV1ConnectionRoutine class],
                    [ASV2ConnectionRoutine class],
                    [ASV3ConnectionRoutine class],
                    [ASV4ConnectionRoutine class],
                    [ASOverTheAirUpdateConnectionRoutine class]];
    });
    return classes;
}

#pragma Public Methods

+ (Class<ASDataHandlingRoutine>)connectionRoutineForDevice:(ASDevice *)device {
    if (!device.softwareRevision) {
        return nil;
    }
    
    if ([@"4.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        return [ASV4ConnectionRoutine class];
    }
    else if ([@"3.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        return [ASV3ConnectionRoutine class];
    }
    else if ([@"2.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        return [ASV2ConnectionRoutine class];
    }
    else if ([@"1.0.0" compare:device.softwareRevision options:NSNumericSearch] != NSOrderedDescending) {
        return [ASV1ConnectionRoutine class];
    }
    
    return nil;
}

+ (NSArray<CBUUID *> *)allServices {
    static NSArray<CBUUID *> *services;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *mutableServices = [[NSMutableArray alloc] init];
        for (Class<ASDataHandlingRoutine> class in [[self class] allConnectionRoutineClasses]) {
            [mutableServices addObjectsFromArray:[class supportedServices]];
        }
        services = [NSSet setWithArray:mutableServices].allObjects;
    });
    return services;
}

+ (NSArray<CBUUID *> *)allCharacteristicsForService:(NSString *)service {
    static NSDictionary<NSString *, NSArray<CBUUID *> *> *characteristicDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Get all services
        // For each service, get all characteristics
        // Put into dictionary
        
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
        
        for (CBUUID *knownService in [[self class] allServices]) {
            NSMutableArray *mutableCharacteristics = [[NSMutableArray alloc] init];
            
            for (Class<ASDataHandlingRoutine> class in [[self class] allConnectionRoutineClasses]) {
                [mutableCharacteristics addObjectsFromArray:[class supportedCharacteristicsForService:knownService.UUIDString]];
            }
            
            [mutableDictionary setObject:[NSSet setWithArray:mutableCharacteristics].allObjects forKey:knownService.UUIDString];
        }
        
        characteristicDictionary = [[NSDictionary alloc] initWithDictionary:mutableDictionary];
    });
    
    return characteristicDictionary[service];
}

@end
