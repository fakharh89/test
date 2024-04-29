//
//  ASMessagePayload.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 10/16/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASMessageDestination;
@class ASMessageRead;

@interface ASMessagePayload : NSObject

@property (nonatomic, strong, readonly) NSDate *lastModified;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, strong, readonly) ASMessageDestination *destination;
@property (nonatomic, strong, readonly) ASMessageRead *read;
@property (nonatomic, strong, readonly) NSDictionary *properties;

@property (nonatomic, strong, readonly) NSDictionary *dictionaryRepresentation;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
