//
//  ASMessageOwner.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 10/16/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASMessageOwner : NSObject

@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, copy, readonly) NSString *containerId;
@property (nonatomic, copy, readonly) NSString *serialNumber;

@property (nonatomic, strong, readonly) NSDictionary *dictionaryRepresentation;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
