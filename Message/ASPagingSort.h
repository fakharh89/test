//
//  ASPagingSort.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 6/20/18.
//

#import <Foundation/Foundation.h>

@interface ASPagingSort : NSObject

@property (nonatomic, copy, readonly) NSString *property;
@property (nonatomic, assign, readonly) BOOL ascending;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end
