//
//  ASMessageOwner.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 10/16/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import "ASMessageOwner.h"

static NSString * const ASUsernameKey = @"username";
static NSString * const ASContainerIdKey = @"thingId";
static NSString * const ASSerialNumberKey = @"serialNumber";

@implementation ASMessageOwner

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.username forKey:ASUsernameKey];
    [encoder encodeObject:self.containerId forKey:ASContainerIdKey];
    [encoder encodeObject:self.serialNumber forKey:ASSerialNumberKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        _username = [decoder decodeObjectForKey:ASUsernameKey];
        _containerId = [decoder decodeObjectForKey:ASContainerIdKey];
        _serialNumber = [decoder decodeObjectForKey:ASSerialNumberKey];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _username = dictionary[ASUsernameKey];
        _containerId = dictionary[ASContainerIdKey];
        _serialNumber = dictionary[ASSerialNumberKey];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMapTable *mapTable = [NSMapTable strongToStrongObjectsMapTable];
    
    [mapTable setObject:self.username forKey:ASUsernameKey];
    [mapTable setObject:self.containerId forKey:ASContainerIdKey];
    [mapTable setObject:self.serialNumber forKey:ASSerialNumberKey];
    
    return mapTable.dictionaryRepresentation;
}

@end
