//
//  ASStoreItem.m
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASStoreItemPrivate.h"

#import "AFHTTPSessionManager.h"
#import "ASStoreItemGroupPrivate.h"

NSString * const ASStoreItemIdentifierKey = @"id";
NSString * const ASStoreItemQuantityKey = @"qty";
NSString * const ASStoreItemPackSizeKey = @"packSize";
NSString * const ASStoreItemPackHumidityKey = @"packHumidity";
NSString * const ASStoreItemPackQuantityKey = @"packQuantity";
NSString * const ASStoreItemExternalIdKey = @"ext_id";
NSString * const ASStoreItemNameKey = @"name";
NSString * const ASStoreItemPriceKey = @"price";
NSString * const ASStoreItemVendorKey = @"vendorId";
NSString * const ASStoreItemReorderableKey = @"reorderable";
NSString * const ASStoreItemSKUKey = @"sku";
NSString * const ASStoreItemImageURLKey = @"url";
NSString * const ASStoreItemShortDescriptionKey = @"description_url";
NSString * const ASStoreItemGroupKey = @"itemGroup";
NSString * const ASStoreItemItemUrl = @"item_url";
NSString * const ASStoreItemManufacturer = @"manufacturer";
NSString * const ASStoreItemSpecsUrlKey = @"specs_url";

@implementation ASStoreItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _identifier = dictionary[ASStoreItemIdentifierKey];
        _quantity = dictionary[ASStoreItemQuantityKey];
        _packSize = dictionary[ASStoreItemPackSizeKey];
        _packHumidity = dictionary[ASStoreItemPackHumidityKey];
        _packQuantity = dictionary[ASStoreItemPackQuantityKey];
        _externalId = dictionary[ASStoreItemExternalIdKey];
        _name = dictionary[ASStoreItemNameKey];
        _price = dictionary[ASStoreItemPriceKey];
        _vendor = dictionary[ASStoreItemVendorKey];
        _reorderable = ((NSNumber *)dictionary[ASStoreItemReorderableKey]).boolValue;
        _SKU = dictionary[ASStoreItemSKUKey];
        _imageURL = dictionary[ASStoreItemImageURLKey];
        _shortDescription = dictionary[ASStoreItemShortDescriptionKey];
        _itemUrl = dictionary[ASStoreItemItemUrl];
        _manufacturer = dictionary[ASStoreItemManufacturer];
        _specsUrl = dictionary[ASStoreItemSpecsUrlKey];
        
        NSMutableArray <ASStoreItemGroup *> *mutableItems = [NSMutableArray new];
        
        for (NSDictionary *itemGroupDictionary in dictionary[ASStoreItemGroupKey]) {
            ASStoreItemGroup *itemGroup = [[ASStoreItemGroup alloc] initWithDictionary:itemGroupDictionary];
            [mutableItems addObject:itemGroup];
        }
        
        if (mutableItems.count) {
            _itemGroups = mutableItems.copy;
        }
    }
    
    return self;
}

- (NSDictionary *)dictionaryWithError:(NSError *__autoreleasing *)error {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[ASStoreItemIdentifierKey] = self.identifier;
    dictionary[ASStoreItemQuantityKey] = self.quantity;
    dictionary[ASStoreItemPackSizeKey] = self.packSize;
    dictionary[ASStoreItemPackHumidityKey] = self.packHumidity;
    dictionary[ASStoreItemPackQuantityKey] = self.packQuantity;
    dictionary[ASStoreItemExternalIdKey] = self.externalId;
    dictionary[ASStoreItemNameKey] = self.name;
    dictionary[ASStoreItemPriceKey] = self.price;
    dictionary[ASStoreItemVendorKey] = self.vendor;
    dictionary[ASStoreItemReorderableKey] = self.reorderable ? @YES : @NO;
    dictionary[ASStoreItemSKUKey] = self.SKU;
    dictionary[ASStoreItemImageURLKey] = self.imageURL;
    dictionary[ASStoreItemShortDescriptionKey] = self.shortDescription;
    dictionary[ASStoreItemItemUrl] = self.itemUrl;
    dictionary[ASStoreItemManufacturer] = self.manufacturer;
    dictionary[ASStoreItemSpecsUrlKey] = self.specsUrl;
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSString *)description {
    NSString *quantityString = @"";
    if (self.quantity) {
        quantityString = [NSString stringWithFormat:@"%@x ", self.quantity];
    }
    
    return [NSString stringWithFormat:@"%@%@ - $%@", quantityString, self.name, self.price];
}

- (void)getImageWithCompletion:(void (^)(NSError *error))completion {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    NSString *URL = self.imageURL;
    
    if (![self.imageURL hasPrefix:@"https://"] && ![self.imageURL hasPrefix:@"http://"]) {
        URL = [NSString stringWithFormat:@"https://%@", URL];
    }
    
    [manager GET:URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        _image = responseObject;
        if (completion) {
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(error);
        }
    }];
}

@end

