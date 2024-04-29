//
//  ASLink.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 2/25/19.
//

#import "ASLink.h"

static NSString * const ASDeprecationKey = @"deprecation";
static NSString * const ASHrefKey = @"href";
static NSString * const ASHreflangKey = @"hreflang";
static NSString * const ASMediaKey = @"media";
static NSString * const ASRelKey = @"rel";
static NSString * const ASTemplatedKey = @"templated";
static NSString * const ASTitleKey = @"title";
static NSString * const ASTypeKey = @"type";

@implementation ASLink

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _deprecation = dictionary[ASDeprecationKey];
        _href = dictionary[ASHrefKey];
        _hreflang = dictionary[ASHreflangKey];
        _media = dictionary[ASMediaKey];
        _rel = dictionary[ASRelKey];
        _templated = [dictionary[ASTemplatedKey] boolValue];
        _title = dictionary[ASTitleKey];
        _type = dictionary[ASTypeKey];
    }
    
    return self;
}

@end
