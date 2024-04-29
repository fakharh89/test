//
//  ASNetworkResponseErrorHandler.h
//  Pods
//
//  Created by Luis Ramos on 6/3/21.
//  Copyright © 2021 Blustream Corporation. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NSDictionary+ASStringToJSON.h"
#import "ASErrorDefinitions.h"

@interface ASNetworkResponseErrorHandler : NSObject

+ (ASCloudError)parseErrorResponse:(NSString *)stringResponse;
@end
