//
//  ASReorderProfile.m
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASReorderProfilePrivate.h"

#import "ASDateFormatter.h"

NSString * const ASReorderProfileStoreItemIdentifier = @"itemId";
NSString * const ASReorderProfileVendor = @"vendorId";
NSString * const ASReorderProfileQuantity = @"qty";
NSString * const ASReorderProfileUsername = @"username";
NSString * const ASReorderProfileContainerIdentifier = @"containerId";
NSString * const ASReorderProfileExpirationDate = @"expDate";

@implementation ASReorderProfile

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _storeItemIdentifier = dictionary[ASReorderProfileStoreItemIdentifier];
        _vendor = dictionary[ASReorderProfileVendor];
        _quantity = dictionary[ASReorderProfileQuantity];
        _username = dictionary[ASReorderProfileUsername];
        _containerIdentifier = dictionary[ASReorderProfileContainerIdentifier];
        NSString *dateString = dictionary[ASReorderProfileExpirationDate];
        if (dateString) {
            ASDateFormatter *formatter = [ASDateFormatter new];
            _expirationDate = [formatter dateFromString:dateString];
        }
    }
    
    return self;
}

- (NSDictionary *)dictionaryWithError:(NSError *__autoreleasing *)error {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[ASReorderProfileStoreItemIdentifier] = self.storeItemIdentifier;
    dictionary[ASReorderProfileVendor] = self.vendor;
    dictionary[ASReorderProfileQuantity] = self.quantity;
    dictionary[ASReorderProfileUsername] = self.username;
    dictionary[ASReorderProfileContainerIdentifier] = self.containerIdentifier;
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@x %@ from %@", self.quantity, self.storeItemIdentifier, self.vendor];
}

@end
