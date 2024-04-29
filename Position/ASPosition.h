//
//  ASPosition.h
//  AS-iOS-Framework
//
//  Created by Michael Gordon on 5/2/21.
//  Copyright © 2021 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASPositionTypeHelper.h"

@interface ASPosition : NSObject

@property (nonatomic, assign, readonly) ASPositionType positionType;
@property (nonatomic, copy, readonly) NSString *extId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSDate *start;
@property (nonatomic, strong, readonly) NSDate *end;
@property (nonatomic, copy, readonly) NSString *sensorSerialNumber;
@property (nonatomic, copy, readonly) NSString *thingExtId;

@property (nonatomic, strong, readonly) NSDictionary *dictionaryRepresentation;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithPositionType:(ASPositionType)positionType
                  sensorSerialNumber:(NSString *)serialNumber
                          thingExtId:(NSString *)thingExtId
                               start:(NSDate *)start
                                 end:(NSDate *)end;

@end
