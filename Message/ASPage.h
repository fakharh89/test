//
//  ASPage.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 2/25/19.
//

#import <Foundation/Foundation.h>

@interface ASPage : NSObject

@property (nonatomic, strong, readonly) NSNumber *number;
@property (nonatomic, strong, readonly) NSNumber *size;
@property (nonatomic, strong, readonly) NSNumber *totalElements;
@property (nonatomic, strong, readonly) NSNumber *totalPages;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end
