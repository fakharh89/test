//
//  ASPagingResult.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 6/20/18.
//

#import <Foundation/Foundation.h>

@class ASMessage;
@class ASPage;

@interface ASPagingResult : NSObject

@property (nonatomic, strong, readonly) ASPage *page;
@property (nonatomic, strong, readonly) NSArray<ASMessage *> *messages;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end
