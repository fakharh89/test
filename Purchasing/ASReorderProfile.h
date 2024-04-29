//
//  ASReorderProfile.h
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASReorderProfile : NSObject

@property (strong, readwrite, nonatomic) NSNumber *storeItemIdentifier;
@property (copy, readwrite, nonatomic) NSString *vendor;
@property (strong, readwrite, nonatomic) NSNumber *quantity;
@property (copy, readwrite, nonatomic) NSString *username;
@property (copy, readwrite, nonatomic) NSString *containerIdentifier;
@property (strong, readonly, nonatomic) NSDate *expirationDate;

@end
