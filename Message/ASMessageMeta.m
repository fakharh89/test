//
//  ASMessageMeta.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 3/13/19.
//  Copyright © 2019 Blustream Corporation. All rights reserved.
//

#import "ASMessageMeta.h"

#import "ASDateFormatter.h"

static NSString * const ASAlertKey = @"alert";
static NSString * const ASBookmarkKey = @"bookmark";
static NSString * const ASCreatedKey = @"created";
static NSString * const ASTagsKey = @"tags";
static NSString * const ASTemplateIdKey = @"templateId";
static NSString * const ASTriggerIdKey = @"triggerId";

@implementation ASMessageMeta

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.alert forKey:ASAlertKey];
    [encoder encodeBool:self.bookmark forKey:ASBookmarkKey];
    [encoder encodeObject:self.created forKey:ASCreatedKey];
    [encoder encodeObject:self.tags forKey:ASTagsKey];
    [encoder encodeObject:self.templateId forKey:ASTemplateIdKey];
    [encoder encodeObject:self.triggerId forKey:ASTriggerIdKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        _alert = [decoder decodeBoolForKey:ASAlertKey];
        _bookmark = [decoder decodeBoolForKey:ASBookmarkKey];
        _created = [decoder decodeObjectForKey:ASCreatedKey];
        _tags = [decoder decodeObjectForKey:ASTagsKey];
        _templateId = [decoder decodeObjectForKey:ASTemplateIdKey];
        _triggerId = [decoder decodeObjectForKey:ASTriggerIdKey];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _alert = [dictionary[ASAlertKey] boolValue];
        _bookmark = [dictionary[ASBookmarkKey] boolValue];
        
        NSString *createdString = dictionary[ASCreatedKey];
        if (createdString.length) {
            _created = [[ASDateFormatter new] dateFromString:createdString];
        }
        
        NSMutableArray *tags = [NSMutableArray new];
        for (NSString *tag in dictionary[ASTagsKey]) {
            [tags addObject:tag];
        }
        
        _tags = tags.copy;
        
        _templateId = dictionary[ASTemplateIdKey];
        _triggerId = dictionary[ASTriggerIdKey];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMapTable *mapTable = [NSMapTable strongToStrongObjectsMapTable];
    
    [mapTable setObject:@(self.alert) forKey:ASAlertKey];
    [mapTable setObject:@(self.bookmark) forKey:ASBookmarkKey];
    [mapTable setObject:[[ASDateFormatter new] stringFromDate:self.created] forKey:ASCreatedKey];
    [mapTable setObject:self.tags forKey:ASTagsKey];
    [mapTable setObject:self.templateId forKey:ASTemplateIdKey];
    [mapTable setObject:self.triggerId forKey:ASTriggerIdKey];
    
    return mapTable.dictionaryRepresentation;
}

@end
