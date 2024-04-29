//
//  ASMessageDestination.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 3/13/19.
//  Copyright © 2019 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASMessageDestination : NSObject

@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSString *uri;

@property (nonatomic, strong, readonly) NSDictionary *dictionaryRepresentation;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
