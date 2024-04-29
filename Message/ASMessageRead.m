//
//  ASMessageRead.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 3/13/19.
//  Copyright © 2019 Blustream Corporation. All rights reserved.
//

#import "ASMessageRead.h"

#import "ASDateFormatter.h"

static NSString * const ASReadEventKey = @"readEvent";
static NSString * const ASTimestampKey = @"timestamp";

@implementation ASMessageRead

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.readEvent forKey:ASReadEventKey];
    [encoder encodeObject:self.timestamp forKey:ASTimestampKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        _readEvent = [decoder decodeObjectForKey:ASReadEventKey];
        _timestamp = [decoder decodeObjectForKey:ASTimestampKey];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _readEvent = dictionary[ASReadEventKey];
        
        NSString *timestampString = dictionary[ASTimestampKey];
        if (timestampString.length) {
            _timestamp = [[ASDateFormatter new] dateFromString:timestampString];
        }
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMapTable *mapTable = [NSMapTable strongToStrongObjectsMapTable];
    
    [mapTable setObject:self.readEvent forKey:ASReadEventKey];
    [mapTable setObject:[[ASDateFormatter new] stringFromDate:self.timestamp] forKey:ASTimestampKey];
    
    return mapTable.dictionaryRepresentation;
}

@end
