//
//  ASAddress.m
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASAddressPrivate.h"

#import "ASUtils.h"
#import "ASErrorDefinitions.h"

NSString * const ASAddressVendorKey = @"vendorId";
NSString * const ASAddressPrimaryKey = @"primary";
NSString * const ASAddressTypeKey = @"type";
NSString * const ASAddressCityKey = @"city";
NSString * const ASAddressGivenNameKey = @"givenName";
NSString * const ASAddressSurnameKey = @"surname";
NSString * const ASAddressStateKey = @"state";
NSString * const ASAddressAddress1Key = @"address1";
NSString * const ASAddressAddress2Key = @"address2";
NSString * const ASAddressZipCodeKey = @"zipCode";
NSString * const ASAddressCountryCodeKey = @"countrycode";
NSString * const ASAddressCompanyKey = @"company";

NSString * const ASAddressBillingTypeValue = @"billing";
NSString * const ASAddressShippingTypeValue = @"shipping";

@implementation ASAddress

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        NSString *typeString = dictionary[ASAddressTypeKey];
        if ([ASAddressBillingTypeValue compare:typeString] == NSOrderedSame) {
            _type = ASAddressTypeBilling;
        }
        else if ([ASAddressShippingTypeValue compare:typeString] == NSOrderedSame) {
            _type = ASAddressTypeShipping;
        }
        else {
            _type = ASAddressTypeUnknown;
        }
        
        _primary = ((NSNumber *)dictionary[ASAddressPrimaryKey]).boolValue;
        _vendor = dictionary[ASAddressVendorKey];
        _firstName = dictionary[ASAddressGivenNameKey];
        _lastName = dictionary[ASAddressSurnameKey];
        _address1 = dictionary[ASAddressAddress1Key];
        _address2 = dictionary[ASAddressAddress2Key];
        _city = dictionary[ASAddressCityKey];
        _stateCode = dictionary[ASAddressStateKey];
        _zipCode = dictionary[ASAddressZipCodeKey];
        _countryCode = dictionary[ASAddressCountryCodeKey];
        _company = dictionary[ASAddressCompanyKey];
    }
    
    return self;
}

- (NSDictionary *)dictionaryWithError:(NSError *__autoreleasing *)error {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if (self.type == ASAddressTypeShipping) {
        dictionary[ASAddressTypeKey] = ASAddressShippingTypeValue;
    }
    else if (self.type == ASAddressTypeBilling) {
        dictionary[ASAddressTypeKey] = ASAddressBillingTypeValue;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:ASPurchasingManagerErrorDomain code:ASPurchasingManagerErrorInvalidProperty userInfo:nil];
        }
        return nil;
    }
    
    dictionary[ASAddressPrimaryKey] = self.primary ? @YES : @NO;
    dictionary[ASAddressVendorKey] = self.vendor;
    dictionary[ASAddressGivenNameKey] = self.firstName;
    dictionary[ASAddressSurnameKey] = self.lastName;
    dictionary[ASAddressAddress1Key] = self.address1;
    dictionary[ASAddressAddress2Key] = self.address2;
    dictionary[ASAddressCityKey] = self.city;
    dictionary[ASAddressStateKey] = self.stateCode;
    dictionary[ASAddressZipCodeKey] = self.zipCode;
    dictionary[ASAddressCountryCodeKey] = self.countryCode;
    dictionary[ASAddressCompanyKey] = self.company;
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString string];
    switch (self.type) {
        case ASAddressTypeBilling:
            [string appendString:@"Type: Billing"];
            break;
        case ASAddressTypeShipping:
            [string appendString:@"Type: Shipping"];
            break;
        case ASAddressTypeUnknown:
            [string appendString:@"Type: Unknown"];
            break;
    }
    if (self.primary) {
        [string appendString:@"\n(Primary)"];
    }
    [string appendString:[NSString stringWithFormat:@"\n%@ %@", self.firstName, self.lastName]];
    if (self.company) {
        [string appendString:[NSString stringWithFormat:@"\n%@", self.company]];
    }
    [string appendString:[NSString stringWithFormat:@"\n%@", self.address1]];
    if (self.address2) {
        [string appendString:[NSString stringWithFormat:@"\n%@", self.address2]];
    }
    [string appendString:[NSString stringWithFormat:@"\n%@, %@ %@", self.city, self.stateCode, self.zipCode]];
    if (self.countryCode) {
        [string appendString:[NSString stringWithFormat:@"\n%@", self.countryCode]];
    }
    
    return [NSString stringWithString:string];
}

- (BOOL)complete {
    if (self.type == ASAddressTypeUnknown) {
        return NO;
    }
    if (!self.vendor || self.vendor.length == 0) {
        return NO;
    }
    if (!self.firstName || self.firstName.length == 0) {
        return NO;
    }
    if (!self.lastName || self.lastName.length == 0) {
        return NO;
    }
    if (!self.address1 || self.address1.length == 0) {
        return NO;
    }
    if (!self.city || self.city.length == 0) {
        return NO;
    }
    if (!self.stateCode || self.stateCode.length == 0) {
        return NO;
    }
    if (!self.zipCode || self.zipCode.length == 0) {
        return NO;
    }
    if (!self.countryCode || self.countryCode.length == 0) {
        return NO;
    }
    
    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    ASAddress *copy = [[[self class] allocWithZone:zone] init];
    
    copy->_vendor = [_vendor copyWithZone:zone];
    copy->_type = _type;
    copy->_primary = _primary;
    copy->_firstName = [_firstName copyWithZone:zone];
    copy->_lastName = [_lastName copyWithZone:zone];
    copy->_company = [_company copyWithZone:zone];
    copy->_address1 = [_address1 copyWithZone:zone];
    copy->_address2 = [_address2 copyWithZone:zone];
    copy->_city = [_city copyWithZone:zone];
    copy->_stateCode = [_stateCode copyWithZone:zone];
    copy->_zipCode = [_zipCode copyWithZone:zone];
    copy->_countryCode = [_countryCode copyWithZone:zone];
    
    return copy;
}

- (BOOL)isEqual:(id)object strict:(BOOL)strict {
    if (self == object) {
        return YES;
    }
    
    ASAddress *inputObject = (ASAddress *)object;
    
    BOOL isVendorEqual = ![ASUtils detectChangeBetweenString:[self fixSpaces:self.vendor] string:[self fixSpaces:inputObject.vendor]];
    BOOL isTypeEqual = self.type == inputObject.type;
    BOOL isPrimaryEqual = self.primary == inputObject.primary;
    BOOL isFirstNameEqual = ![ASUtils detectChangeBetweenString:[self fixSpaces:self.firstName] string:[self fixSpaces:inputObject.firstName]];
    BOOL isLastNameEqual = ![ASUtils detectChangeBetweenString:[self fixSpaces:self.lastName] string:[self fixSpaces:inputObject.lastName]];
    BOOL isAddress1Equal = ![ASUtils detectChangeBetweenString:[self fixSpaces:self.address1] string:[self fixSpaces:inputObject.address1]];
    BOOL isAddress2Equal = ![ASUtils detectChangeBetweenString:[self fixSpaces:self.address2] string:[self fixSpaces:inputObject.address2]];
    BOOL isCityEqual = ![ASUtils detectChangeBetweenString:[self fixSpaces:self.city] string:[self fixSpaces:inputObject.city]];
    BOOL isStateCodeEqual = ![ASUtils detectChangeBetweenString:[self fixSpaces:self.stateCode] string:[self fixSpaces:inputObject.stateCode]];
    BOOL isZipCodeEqual = ![ASUtils detectChangeBetweenString:[self fixSpaces:self.zipCode] string:[self fixSpaces:inputObject.zipCode]];
    BOOL isCountryCodeEqual = ![ASUtils detectChangeBetweenString:[self fixSpaces:self.countryCode] string:[self fixSpaces:inputObject.countryCode]];
    BOOL isCompanyEqual = ![ASUtils detectChangeBetweenString:[self fixSpaces:self.company] string:[self fixSpaces:inputObject.company]];
    
    BOOL isEqualNonStrict = isVendorEqual && isFirstNameEqual && isLastNameEqual && isAddress1Equal && isAddress2Equal && isCityEqual && isStateCodeEqual && isZipCodeEqual && isCountryCodeEqual && isCompanyEqual;
    
    BOOL isEqual = strict ? (isEqualNonStrict && isTypeEqual && isPrimaryEqual) : isEqualNonStrict;
    
    return isEqual;
}

- (BOOL)isEqual:(id)object {
    return [self isEqual:object strict:YES];
}

- (NSUInteger)hash {
    return [self hashUseStrict:YES];
}

- (NSUInteger)hashUseStrict:(BOOL)strict {
    NSMutableString *string = [NSMutableString string];
    
    if (strict) {
        switch (self.type) {
            case ASAddressTypeBilling:
                [string appendString:@"t:B"];
                break;
            case ASAddressTypeShipping:
                [string appendString:@"t:S"];
                break;
            case ASAddressTypeUnknown:
                [string appendString:@"t:U"];
                break;
        }
        [string appendString:[NSString stringWithFormat:@" p:%@", self.primary ? @"y" : @"n"]];
    }
    
    [string appendString:[NSString stringWithFormat:@" fn:%@", [self fixSpaces:self.firstName] ?: @""]];
    [string appendString:[NSString stringWithFormat:@" ln:%@", [self fixSpaces:self.lastName] ?: @""]];
    [string appendString:[NSString stringWithFormat:@" co:%@", [self fixSpaces:self.company] ?: @""]];
    [string appendString:[NSString stringWithFormat:@" a1:%@", [self fixSpaces:self.address1] ?: @""]];
    [string appendString:[NSString stringWithFormat:@" a2:%@", [self fixSpaces:self.address2] ?: @""]];
    [string appendString:[NSString stringWithFormat:@" ci:%@", [self fixSpaces:self.city] ?: @""]];
    [string appendString:[NSString stringWithFormat:@" st:%@", [self fixSpaces:self.stateCode] ?: @""]];
    [string appendString:[NSString stringWithFormat:@" zc:%@", [self fixSpaces:self.zipCode] ?: @""]];
    [string appendString:[NSString stringWithFormat:@" cc:%@", [self fixSpaces:self.countryCode] ?: @""]];
    
    NSLog(@"%@\n%lu", string, (unsigned long)string.hash);
    return [NSString stringWithString:string].hash;
}

- (NSString *)fixSpaces:(NSString *)string {
    if (!string) {
        return nil;
    }
    
    NSString *fixedString = [string stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "];
    fixedString = [fixedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return fixedString;
}

@end
