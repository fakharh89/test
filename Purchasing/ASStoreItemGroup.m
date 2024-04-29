//
//  ASStoreItemGroup.m
//  AFNetworking
//
//  Created by Oleg Ivaniv on 11/2/17.
//

#import "ASStoreItemGroup.h"

NSString * const ASStoreItemGroupIdentifierKey = @"id";
NSString * const ASStoreItemGroupTitleKey = @"title";
NSString * const ASStoreItemGroupUrlKey = @"url";
NSString * const ASStoreItemGroupDescriptionUrlKey = @"description_url";
NSString * const ASStoreItemGroupSpecsUrlKey = @"specs_url";
NSString * const ASStoreItemGroupVendorIdKey = @"vendorId";

@implementation ASStoreItemGroup

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _identifier = dictionary[ASStoreItemGroupIdentifierKey];
        _title = dictionary[ASStoreItemGroupTitleKey];
        _url = dictionary[ASStoreItemGroupUrlKey];
        _descriptionUrl = dictionary[ASStoreItemGroupDescriptionUrlKey];
        _specsUrl = dictionary[ASStoreItemGroupSpecsUrlKey];
        _vendorId = dictionary[ASStoreItemGroupVendorIdKey];
    }
    
    return self;
}

@end
