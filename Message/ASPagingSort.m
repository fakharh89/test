//
//  ASPagingSort.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 6/20/18.
//

#import "ASPagingSort.h"

static NSString * const ASPropertyKey = @"property";
static NSString * const ASAscendingKey = @"ascending";

@implementation ASPagingSort

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _property = dictionary[ASPropertyKey];
        _ascending = [dictionary[ASAscendingKey] boolValue];
    }
    
    return self;
}

@end
