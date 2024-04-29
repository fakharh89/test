//
//  ASUpdateResponse.h
//  AFNetworking
//
//  Created by Michael Gordon on 3/7/19.
//  Copyright © 2019 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASContainerDataUpdateSummary;

@interface ASDataUpdateResponse : NSObject

@property (nonatomic, readonly, strong) NSDictionary<NSString *, ASContainerDataUpdateSummary *> *containerDataUpdates;

@end
