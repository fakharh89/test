//
//  ASMessageDestination.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 3/13/19.
//  Copyright © 2019 Blustream Corporation. All rights reserved.
//

#import "ASMessageDestination.h"

static NSString * const ASTypeKey = @"type";
static NSString * const ASURIKey = @"uri";

@implementation ASMessageDestination

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.type forKey:ASTypeKey];
    [encoder encodeObject:self.uri forKey:ASURIKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        _type = [decoder decodeObjectForKey:ASTypeKey];
        _uri = [decoder decodeObjectForKey:ASURIKey];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _type = dictionary[ASTypeKey];
        _uri = dictionary[ASURIKey];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMapTable *mapTable = [NSMapTable strongToStrongObjectsMapTable];
    
    [mapTable setObject:self.type forKey:ASTypeKey];
    [mapTable setObject:self.uri forKey:ASURIKey];
    
    return mapTable.dictionaryRepresentation;
}

@end
