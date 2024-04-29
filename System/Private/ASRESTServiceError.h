//
//  ASRESTServiceError.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 12/26/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ASRESTServiceErrorType) {
    ASRESTServiceErrorTypeGeneral = 0,
    ASRESTServiceErrorTypeSyncContainers = 1,
    ASRESTServiceErrorTypeCloud = 2
};

@interface ASRESTServiceError : NSError

+ (NSError *)errorForResponse:(NSHTTPURLResponse *)response type:(ASRESTServiceErrorType)type;

@end
