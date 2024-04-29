//
//  ASPagingResult.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 6/20/18.
//

#import "ASPagingResult.h"

#import "ASPagingSort.h"
#import "ASMessage.h"

#import "ASLink.h"
#import "ASPage.h"

static NSString * const ASPageKey = @"page";

static NSString * const ASDataKey = @"data";
static NSString * const ASMessagesKey = @"messages";

@implementation ASPagingResult

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
        _page = [[ASPage alloc] initWithDictionary:dictionary[ASPageKey]];
        
        NSMutableArray *messages = [NSMutableArray new];
        for (NSDictionary *messageDictionary in dictionary[ASDataKey]) {
            ASMessage *message = [[ASMessage alloc] initWithDictionary:messageDictionary];
            if (message) {
                [messages addObject:message];
            }
        }

        _messages = messages.copy;
    }
    
    return self;
}

@end
