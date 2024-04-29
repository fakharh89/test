//
//  ASMessage.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 6/19/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import "ASMessage.h"

#import "ASMessageMeta.h"
#import "ASMessageOwner.h"
#import "ASMessagePayload.h"
#import "ASMessageRead.h"

static NSString * const ASMetaKey = @"meta";
static NSString * const ASMessageIdKey = @"messageId";
static NSString * const ASOwnerKey = @"owner";
static NSString * const ASPayloadKey = @"payload";

@implementation ASMessage

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.meta forKey:ASMetaKey];
    [encoder encodeObject:self.messageId forKey:ASMessageIdKey];
    [encoder encodeObject:self.owner forKey:ASOwnerKey];
    [encoder encodeObject:self.payload forKey:ASPayloadKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        _messageId = [decoder decodeObjectForKey:ASMessageIdKey];
        _owner = [decoder decodeObjectForKey:ASOwnerKey];
        _payload = [decoder decodeObjectForKey:ASPayloadKey];
        _meta = [decoder decodeObjectForKey:ASMetaKey];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _messageId = dictionary[ASMessageIdKey];
        
        NSDictionary *metaDictionary = dictionary[ASMetaKey];
        if (metaDictionary) {
            _meta = [[ASMessageMeta alloc] initWithDictionary:metaDictionary];
        }
        
        NSDictionary *messageOwnerDictionary = dictionary[ASOwnerKey];
        if (messageOwnerDictionary) {
            _owner = [[ASMessageOwner alloc] initWithDictionary:messageOwnerDictionary];
        }
        
        NSDictionary *payloadDictionary = dictionary[ASPayloadKey];
        if (payloadDictionary) {
            _payload = [[ASMessagePayload alloc] initWithDictionary:payloadDictionary];
        }
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMapTable *mapTable = [NSMapTable strongToStrongObjectsMapTable];
    
    [mapTable setObject:self.messageId forKey:ASMessageIdKey];
    [mapTable setObject:self.owner.dictionaryRepresentation forKey:ASOwnerKey];
    [mapTable setObject:self.payload.dictionaryRepresentation forKey:ASPayloadKey];
    
    return mapTable.dictionaryRepresentation;
}

@end
