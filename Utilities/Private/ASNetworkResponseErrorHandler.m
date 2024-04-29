//
//  ASNetworkResponseErrorHandler.m
//  AS-iOS-Framework
//
//  Created by Luis Ramos on 6/3/21.
//  Copyright © 2021 Blustream Corporation. All rights reserved.
//

#import "ASNetworkResponseErrorHandler.h"


@implementation ASNetworkResponseErrorHandler

+ (ASCloudError)parseErrorResponse:(NSString *)stringResponse {
    NSDictionary *json = [NSDictionary dictionaryWithString:stringResponse];
    
    for (id value in (NSArray *)json[@"errors"]) {
        NSInteger e = [value[@"code"] integerValue];
        
        switch (e) {
            case 424:
                return ASCloudErrorAccountCreationTooManyAttemps;
            default:
                break;
        }
    }
    return ASCloudErrorUnknown;
}
@end

