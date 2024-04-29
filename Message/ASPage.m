//
//  ASPage.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 2/25/19.
//

#import "ASPage.h"

static NSString * const ASNumberKey = @"number";
static NSString * const ASSizeKey = @"size";
static NSString * const ASTotalElementsKey = @"totalElements";
static NSString * const ASTotalPagesKey = @"totalPages";

@implementation ASPage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _number = dictionary[ASNumberKey];
        _size = dictionary[ASSizeKey];
        _totalElements = dictionary[ASTotalElementsKey];
        _totalPages = dictionary[ASTotalPagesKey];
    }
    
    return self;
}

@end
