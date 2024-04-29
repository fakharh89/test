//
//  ASPaymentProfile.h
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ASPaymentType) {
    ASPaymentTypeUnknown,
    ASPaymentTypeVisa,
    ASPaymentTypeMastercard,
    ASPaymentTypeAmericanExpress,
    ASPaymentTypeDiscover
};

@interface ASPaymentProfile : NSObject <NSCopying>

@property (copy, readonly, nonatomic) NSString *identifier;
@property (assign, readwrite, nonatomic) ASPaymentType type;
@property (copy, readonly, nonatomic) NSString *maskedCreditCardNumber;
@property (copy, readwrite, nonatomic) NSString *creditCardNumber;
@property (copy, readwrite, nonatomic) NSString *CVVNumber;
@property (strong, readwrite, nonatomic) NSNumber *expirationMonth;
@property (strong, readwrite, nonatomic) NSNumber *expirationYear;
@property (copy, readwrite, nonatomic) NSString *vendor;
@property (strong, readonly, nonatomic) NSDate *lastUpdate;

@property (assign, readonly, nonatomic) BOOL complete;

@end
