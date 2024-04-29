//
//  ASContainerUpdateResponse.h
//  AFNetworking
//
//  Created by Michael Gordon on 3/8/19.
//  Copyright © 2019 Blustream Corporation. All rights reserved.
//

#import "ASContainerDataUpdateSummary.h"

@interface ASContainerDataUpdateSummary ()

- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier;

- (BOOL)setDate:(NSDate *)date forDataTypeString:(NSString *)string;

@end
