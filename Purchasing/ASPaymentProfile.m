//
//  ASPaymentProfile.m
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASPaymentProfilePrivate.h"

#import "ASDateFormatter.h"
#import "ASErrorDefinitions.h"

NSString * const ASPaymentProfileIdentiferKey = @"ppid";
NSString * const ASPaymentProfileTypeKey = @"type";
NSString * const ASPaymentProfileMaskedCreditCardNumberKey = @"maskedNbr";
NSString * const ASPaymentProfileCreditCardNumberKey = @"cardNbr";
NSString * const ASPaymentProfileCVVNumberKey = @"cvv";
NSString * const ASPaymentProfileExpirationMonthKey = @"expirationMonth";
NSString * const ASPaymentProfileExpirationYearKey = @"expirationYear";
NSString * const ASPaymentProfileVendorKey = @"vendorId";
NSString * const ASPaymentProfileLastUpdateKey = @"lastUpdate";

NSString * const ASPaymentProfileVisaTypeValue = @"VISA";
NSString * const ASPaymentProfileMastercardTypeValue = @"MC";
NSString * const ASPaymentProfileAmericanExpressTypeValue = @"AMEX";
NSString * const ASPaymentProfileDiscoverTypeValue = @"DISCOVER";

static const NSInteger ASCreditCardAmericanExpressLength = 15;
static const NSInteger ASCreditCardDefaultLength = 16;
static const NSInteger ASCVVAmericanExpressLength = 4;
static const NSInteger ASCVVDefaultLength = 3;

@implementation ASPaymentProfile

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];

    if (self) {
        _identifier = dictionary[ASPaymentProfileIdentiferKey];

        NSString *typeString = dictionary[ASPaymentProfileTypeKey];
        if ([ASPaymentProfileVisaTypeValue compare:typeString] == NSOrderedSame) {
            _type = ASPaymentTypeVisa;
        }
        else if ([ASPaymentProfileMastercardTypeValue compare:typeString] == NSOrderedSame) {
            _type = ASPaymentTypeMastercard;
        }
        else if ([ASPaymentProfileAmericanExpressTypeValue compare:typeString] == NSOrderedSame) {
            _type = ASPaymentTypeAmericanExpress;
        }
        else if ([ASPaymentProfileDiscoverTypeValue compare:typeString] == NSOrderedSame) {
            _type = ASPaymentTypeDiscover;
        }
        else {
            _type = ASPaymentTypeUnknown;
        }

        _maskedCreditCardNumber = dictionary[ASPaymentProfileMaskedCreditCardNumberKey];
        _creditCardNumber = dictionary[ASPaymentProfileCreditCardNumberKey];
        _CVVNumber = dictionary[ASPaymentProfileCVVNumberKey];
        _expirationMonth = dictionary[ASPaymentProfileExpirationMonthKey];
        _expirationYear = dictionary[ASPaymentProfileExpirationYearKey];
        _vendor = dictionary[ASPaymentProfileVendorKey];

        NSString *dateString = dictionary[ASPaymentProfileLastUpdateKey];

        if (dateString) {
            ASDateFormatter *dateFormatter = [[ASDateFormatter alloc] init];
            _lastUpdate = [dateFormatter dateFromString:dateString];
        }
    }

    return self;
}

- (NSDictionary *)dictionaryWithError:(NSError *__autoreleasing *)error {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    switch (self.type) {
        case ASPaymentTypeUnknown: {
            if (!self.identifier) {
                if (error) {
                    *error = [NSError errorWithDomain:ASPurchasingManagerErrorDomain code:ASPurchasingManagerErrorInvalidProperty userInfo:nil];
                }
                return nil;
            }
            break;
        }
        case ASPaymentTypeVisa: {
            dictionary[ASPaymentProfileTypeKey] = ASPaymentProfileVisaTypeValue;
            break;
        }
        case ASPaymentTypeDiscover: {
            dictionary[ASPaymentProfileTypeKey] = ASPaymentProfileDiscoverTypeValue;
            break;
        }
        case ASPaymentTypeMastercard: {
            dictionary[ASPaymentProfileTypeKey] = ASPaymentProfileMastercardTypeValue;
            break;
        }
        case ASPaymentTypeAmericanExpress: {
            dictionary[ASPaymentProfileTypeKey] = ASPaymentProfileAmericanExpressTypeValue;
            break;
        }
    }

    dictionary[ASPaymentProfileCreditCardNumberKey] = self.creditCardNumber;
    dictionary[ASPaymentProfileCVVNumberKey] = self.CVVNumber;
    dictionary[ASPaymentProfileExpirationMonthKey] = self.expirationMonth;
    dictionary[ASPaymentProfileExpirationYearKey] = self.expirationYear;
    dictionary[ASPaymentProfileVendorKey] = self.vendor;
    dictionary[ASPaymentProfileIdentiferKey] = self.identifier;

    //    if (self.lastUpdate) {
    //        ASDateFormatter *dateFormatter = [[ASDateFormatter alloc] init];
    //        dictionary[ASPaymentProfileLastUpdateKey] = [dateFormatter stringFromDate:self.lastUpdate];
    //    }

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (BOOL)complete {
    if (self.type == ASPaymentTypeUnknown) {
        return NO;
    }

    NSInteger cardLength = self.type == ASPaymentTypeAmericanExpress ? ASCreditCardAmericanExpressLength : ASCreditCardDefaultLength;
    NSInteger cvvLength = self.type == ASPaymentTypeAmericanExpress ? ASCVVAmericanExpressLength : ASCVVDefaultLength;

    if (!self.creditCardNumber || self.creditCardNumber.length != cardLength) {
        return NO;
    }
    if (!self.CVVNumber || self.CVVNumber.length != cvvLength) {
        return NO;
    }
    if (!self.expirationMonth) {
        return NO;
    }
    if (!self.expirationYear) {
        return NO;
    }
    if (!self.vendor || self.vendor.length == 0) {
        return NO;
    }

    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    ASPaymentProfile *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy->_identifier = [_identifier copyWithZone:zone];
        copy->_type = _type;
        copy->_maskedCreditCardNumber = [_maskedCreditCardNumber copyWithZone:zone];
        copy->_creditCardNumber = [_creditCardNumber copyWithZone:zone];
        copy->_CVVNumber = [_CVVNumber copyWithZone:zone];
        copy->_expirationMonth = [_expirationMonth copyWithZone:zone];
        copy->_expirationYear = [_expirationYear copyWithZone:zone];
        copy->_vendor = [_vendor copyWithZone:zone];
        copy->_lastUpdate = [_lastUpdate copyWithZone:zone];
    }

    return copy;
}

@end
