//
//  ASPosition.m
//  AS-iOS-Framework
//
//  Created by Michael Gordon on 5/2/21.
//  Copyright © 2021 Blustream Corporation. All rights reserved.
//

#import "ASPosition.h"

#import "ASPositionTypeHelper.h"
#import "ASDateFormatter.h"

static NSString * const ASExternalIdKey = @"extId";
static NSString * const ASNameKey = @"name";
static NSString * const ASStartKey = @"start";
static NSString * const ASEndKey = @"end";
static NSString * const ASSensorSerialNumberKey = @"serialNumber";
static NSString * const ASThingExtIdKey = @"thingExtId";

@implementation ASPosition

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _extId = dictionary[ASExternalIdKey];
        _positionType = [ASPositionTypeHelper positionTypeForExtId:_extId];
        _name = dictionary[ASNameKey];
        _start = dictionary[ASStartKey];
        _end = dictionary[ASEndKey];
        _sensorSerialNumber = dictionary[ASSensorSerialNumberKey];
        _thingExtId = dictionary[ASThingExtIdKey];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        _extId = [decoder decodeObjectForKey:ASExternalIdKey];
        _positionType = [ASPositionTypeHelper positionTypeForExtId:_extId];
        _name = [decoder decodeObjectForKey:ASNameKey];
        _start = [decoder decodeObjectForKey:ASStartKey];
        _end = [decoder decodeObjectForKey:ASEndKey];
        _sensorSerialNumber = [decoder decodeObjectForKey:ASSensorSerialNumberKey];
        _thingExtId = [decoder decodeObjectForKey:ASThingExtIdKey];
    }
    
    return self;
}

- (instancetype)initWithPositionType:(ASPositionType)positionType
                  sensorSerialNumber:(NSString *)serialNumber
                          thingExtId:(NSString *)thingExtId
                               start:(NSDate *)start
                                 end:(NSDate *)end {
    self = [super init];
    
    if (self) {
        _positionType = positionType;
        _extId = [ASPositionTypeHelper extIdForPositionType:positionType];
        _start = start;
        _end = end;
        _sensorSerialNumber = serialNumber;
        _thingExtId = thingExtId;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.extId forKey:ASExternalIdKey];
    [encoder encodeObject:self.name forKey:ASNameKey];
    [encoder encodeObject:self.start forKey:ASStartKey];
    [encoder encodeObject:self.end forKey:ASEndKey];
    [encoder encodeObject:self.sensorSerialNumber forKey:ASSensorSerialNumberKey];
    [encoder encodeObject:self.thingExtId forKey:ASThingExtIdKey];
}

- (NSDictionary *)dictionaryRepresentation {
    NSMapTable *mapTable = [NSMapTable strongToStrongObjectsMapTable];
    
    [mapTable setObject:self.extId forKey:ASExternalIdKey];
    [mapTable setObject:self.name forKey:ASNameKey];
    
    if (self.start) {
        NSString *startString = [[ASDateFormatter new] stringFromDate:self.start];
        [mapTable setObject:startString forKey:ASStartKey];
    }
    
    if (self.end) {
        NSString *endString = [[ASDateFormatter new] stringFromDate:self.end];
        [mapTable setObject:endString forKey:ASEndKey];
    }
    
    [mapTable setObject:self.sensorSerialNumber forKey:ASSensorSerialNumberKey];
    [mapTable setObject:self.thingExtId forKey:ASThingExtIdKey];
    
    return mapTable.dictionaryRepresentation;
}

@end
