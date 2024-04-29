//
//  ASMessageMeta.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 3/13/19.
//  Copyright © 2019 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASMessageMeta : NSObject

@property (nonatomic, assign, readonly) BOOL alert;
@property (nonatomic, assign, readonly) BOOL bookmark;
@property (nonatomic, strong, readonly) NSDate *created;
@property (nonatomic, strong, readonly) NSArray<NSString *> *tags;
@property (nonatomic, copy, readonly) NSString *templateId;
@property (nonatomic, copy, readonly) NSString *triggerId;

@property (nonatomic, strong, readonly) NSDictionary *dictionaryRepresentation;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
