//
//  ASLink.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 2/25/19.
//

#import <Foundation/Foundation.h>

@interface ASLink : NSObject

@property (nonatomic, copy, readonly) NSString *deprecation;
@property (nonatomic, copy, readonly) NSString *href;
@property (nonatomic, copy, readonly) NSString *hreflang;
@property (nonatomic, copy, readonly) NSString *media;
@property (nonatomic, copy, readonly) NSString *rel;
@property (nonatomic, assign, readonly) BOOL templated;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *type;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;


@end
