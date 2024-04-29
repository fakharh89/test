//
//  ASAddress.h
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ASAddressType) {
    ASAddressTypeUnknown,
    ASAddressTypeBilling,
    ASAddressTypeShipping
};

@interface ASAddress : NSObject <NSCopying>

@property (copy, readwrite, nonatomic) NSString *vendor;
@property (assign, readwrite, nonatomic) ASAddressType type;
@property (assign, readwrite, nonatomic) BOOL primary;
@property (copy, readwrite, nonatomic) NSString *firstName;
@property (copy, readwrite, nonatomic) NSString *lastName;
@property (copy, readwrite, nonatomic) NSString *address1;
@property (copy, readwrite, nonatomic) NSString *address2;
@property (copy, readwrite, nonatomic) NSString *city;
@property (copy, readwrite, nonatomic) NSString *stateCode;
@property (copy, readwrite, nonatomic) NSString *zipCode;
@property (copy, readwrite, nonatomic) NSString *countryCode;
@property (copy, readwrite, nonatomic) NSString *company;

@property (assign, readonly, nonatomic) BOOL complete;

// If strict is YES, then it's the same as isEqual
// If strict is NO, then this only compares the following items:
// firstName, lastName, address1, address2, city, stateCode, zipCode, countryCode, company
- (BOOL)isEqual:(id)object strict:(BOOL)strict;
- (NSUInteger)hashUseStrict:(BOOL)strict;

@end
