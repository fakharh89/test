//
//  ASStoreItem.h
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASStoreItemGroup;

@interface ASStoreItem : NSObject

@property (nonatomic, strong, readonly) NSNumber *identifier;
@property (nonatomic, strong, readwrite) NSNumber *quantity;
@property (nonatomic, strong, readonly) NSNumber *packSize;
@property (nonatomic, strong, readonly) NSNumber *packHumidity;
@property (nonatomic, strong, readonly) NSNumber *packQuantity;
@property (nonatomic, strong, readonly) NSString *externalId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *price;
@property (nonatomic, copy, readonly) NSString *vendor;
@property (nonatomic, assign, readonly) BOOL reorderable;
@property (nonatomic, copy, readonly) NSString *SKU;
@property (nonatomic, copy, readonly) NSString *imageURL;
@property (nonatomic, copy, readonly) NSString *itemUrl;
@property (nonatomic, copy, readonly) NSString *manufacturer;
@property (nonatomic, copy, readonly) NSString *shortDescription;
@property (nonatomic, copy, readonly) NSString *specsUrl;
@property (nonatomic, strong, readonly) NSArray <ASStoreItemGroup *> *itemGroups;

@property (nonatomic, strong, readonly) UIImage *image;

- (void)getImageWithCompletion:(void (^)(NSError *error))completion;

@end
