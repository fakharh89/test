//
//  ASMessage.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 6/19/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASMessageOwner;
@class ASMessagePayload;
@class ASMessageRead;
@class ASMessageMeta;

@interface ASMessage : NSObject

@property (nonatomic, copy, readonly) NSString *messageId;

@property (nonatomic, strong, readonly) ASMessageMeta *meta;
@property (nonatomic, strong, readonly) ASMessageOwner *owner;
@property (nonatomic, strong, readonly) ASMessagePayload *payload;

@property (nonatomic, strong, readonly) NSDictionary *dictionaryRepresentation;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
