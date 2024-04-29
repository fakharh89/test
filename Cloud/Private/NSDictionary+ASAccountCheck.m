//
//  NSDictionary+ASAccountCheck.m
//  Blustream
//
//  Created by Michael Gordon on 7/27/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "NSDictionary+ASAccountCheck.h"

#import "ASErrorDefinitions.h"
#import "NSError+ASError.h"

@implementation NSDictionary (ASAccountCheck)

- (BOOL)checkLoginInfoWithError:(NSError * __autoreleasing *)error tagLength:(NSInteger)tagLength {
    // Check first name
    if (self[@"firstname"]) {
        if ([self[@"firstname"] length] > 80) {
            if (error) {
                *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorInvalidFirstName underlyingError:nil];
            }
            return NO;
        }
    }
    else {
        if (error) {
            *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorMissingFirstName underlyingError:nil];
        }
        return NO;
    }
    
    // Check last name
    if (self[@"lastname"]) {
        if ([self[@"lastname"] length] > 80) {
            if (error) {
                *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorInvalidLastName underlyingError:nil];
            }
            return NO;
        }
    }
    else {
        if (error) {
            *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorMissingLastName underlyingError:nil];
        }
        return NO;
    }
    
    // Check email
    if (self[@"email"]) {
        NSString *filterString = @"^\\S+@\\S+\\.\\S+$"; // No white space, requires character, @, character, ., character
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterString];
        if (![emailTest evaluateWithObject:self[@"email"]]) {
            if (error) {
                *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorInvalidEmail underlyingError:nil];
            }
            return NO;
        }
        
        if ([self[@"email"] length] > (255 - tagLength)) {
            if (error) {
                *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorInvalidEmail underlyingError:nil];
            }
            return NO;
        }
    }
    else {
        if (error) {
            *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorMissingEmail underlyingError:nil];
        }
        return NO;
    }
    
    // Check password
    if (self[@"password"]) {
        if ([self[@"password"] length] < 8) {
            if (error) {
                *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorPasswordTooShort underlyingError:nil];
            }
            return NO;
        }
        
        NSString *filterString = @"^(?=.*[A-Z]).*$";
        NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterString];
        if (![passwordTest evaluateWithObject:self[@"password"]]) {
            if (error) {
                *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorPasswordMissingCapitalLetter underlyingError:nil];
            }
            return NO;
        }
        
        filterString = @"^(?=.*[a-z]).*$";
        passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterString];
        if (![passwordTest evaluateWithObject:self[@"password"]]) {
            if (error) {
                *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorPasswordMissingLowercaseLetter underlyingError:nil];
            }
            return NO;
        }
        
        filterString = @"^(?=.*[0-9]).*$";
        passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterString];
        if (![passwordTest evaluateWithObject:self[@"password"]]) {
            if (error) {
                *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorPasswordMissingNumber underlyingError:nil];
            }
            return NO;
        }
    }
    else {
        if (error) {
            *error = [NSError ASErrorWithDomain:ASAccountCreationErrorDomain code:ASAccountCreationErrorMissingPassword underlyingError:nil];
        }
        return NO;
    }
    
    return YES;
}

@end
