//
//  ASPurchaseOrder.h
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASAddress;
@class ASPaymentProfile;
@class ASShippingOption;
@class ASStoreItem;

@interface ASPurchaseOrder : NSObject

@property (strong, readonly, nonatomic) NSNumber *identifier;
@property (copy, readwrite, nonatomic) NSString *vendor;
@property (strong, readwrite, nonatomic) ASAddress *shippingAddress;
@property (strong, readwrite, nonatomic) ASAddress *billingAddress;
@property (strong, readwrite, nonatomic) ASPaymentProfile *paymentProfile;
@property (strong, readwrite, nonatomic) NSArray<ASStoreItem *> *storeItems;
@property (copy, readwrite, nonatomic) NSString *containerIdentifier;
@property (strong, readwrite, nonatomic) ASShippingOption *shippingOption;
@property (copy, readonly, nonatomic) NSString *salesTax;
@property (copy, readonly, nonatomic) NSString *total;
@property (strong, readonly, nonatomic) NSDate *creationDate;
@property (strong, readonly, nonatomic) NSDate *statusLastUpdatedDate;
@property (copy, readonly, nonatomic) NSString *status;

@end
