//
//  ASMessagePayload.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 10/16/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import "ASMessagePayload.h"
#import "ASMessageDestination.h"
#import "ASDateFormatter.h"
#import "ASMessageRead.h"

static NSString * const ASLastModifiedKey = @"lastModified";
static NSString * const ASContentKey = @"content";
static NSString * const ASDestinationKey = @"destination";
static NSString * const ASReadKey = @"read";
static NSString * const ASPropertiesKey = @"properties";

@implementation ASMessagePayload

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.lastModified forKey:ASLastModifiedKey];
    [encoder encodeObject:self.content forKey:ASContentKey];
    [encoder encodeObject:self.destination forKey:ASDestinationKey];
    [encoder encodeObject:self.read forKey:ASReadKey];
    [encoder encodeObject:self.properties forKey:ASPropertiesKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        _lastModified = [decoder decodeObjectForKey:ASLastModifiedKey];
        _content = [decoder decodeObjectForKey:ASContentKey];
        _destination = [decoder decodeObjectForKey:ASDestinationKey];
        _read = [decoder decodeObjectForKey:ASReadKey];
        _properties = [decoder decodeObjectForKey:ASPropertiesKey];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        NSString *lastModifiedString = dictionary[ASLastModifiedKey];
        if (lastModifiedString.length) {
            _lastModified = [[ASDateFormatter new] dateFromString:lastModifiedString];
        }
        
        _content = dictionary[ASContentKey];
        
        NSDictionary *destinationDictionary = dictionary[ASDestinationKey];
        if (destinationDictionary) {
            _destination = [[ASMessageDestination alloc] initWithDictionary:destinationDictionary];
        }
        
        NSDictionary *readDictionary = dictionary[ASReadKey];
        if (readDictionary) {
            _read = [[ASMessageRead alloc] initWithDictionary:readDictionary];
        }
        
        NSDictionary *propertiesDictionary = dictionary[ASPropertiesKey];
        NSMutableDictionary *mutableProperties = [NSMutableDictionary new];
        for (NSString *key in propertiesDictionary.allKeys) {
            id value = propertiesDictionary[key];
            if (value) {
                mutableProperties[key] = value;
            }
        }
        
        _properties = mutableProperties.copy;
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMapTable *mapTable = [NSMapTable strongToStrongObjectsMapTable];
    
    [mapTable setObject:[[ASDateFormatter new] stringFromDate:self.lastModified] forKey:ASLastModifiedKey];
    [mapTable setObject:self.content forKey:ASContentKey];
    [mapTable setObject:self.destination forKey:ASDestinationKey];
    [mapTable setObject:self.read forKey:ASReadKey];
    [mapTable setObject:self.properties forKey:ASPropertiesKey];
    
    return mapTable.dictionaryRepresentation;
}

@end
