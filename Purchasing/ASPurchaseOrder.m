//
//  ASPurchaseOrder.m
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASPurchaseOrderPrivate.h"

#import "ASAddressPrivate.h"
#import "ASDateFormatter.h"
#import "ASPaymentProfilePrivate.h"
#import "ASShippingOptionPrivate.h"
#import "ASStoreItemPrivate.h"

NSString * const ASPurchaseOrderIdentiferKey = @"id";
NSString * const ASPurchaseOrderVendorKey = @"vendorId";
NSString * const ASPurchaseOrderShippingAddressKey = @"shipping";
NSString * const ASPurchaseOrderBillingAddressKey = @"billing";
NSString * const ASPurchaseOrderPaymentProfileKey = @"payment";
NSString * const ASPurchaseOrderStoreItemsKey = @"items";
NSString * const ASPurchaseOrderContainerIdentifierKey = @"containerId";
NSString * const ASPurchaseOrderShippingOptionKey = @"shippingMethod";
NSString * const ASPurchaseOrderSalesTaxKey = @"salesTax";
NSString * const ASPurchaseOrderTotalKey = @"total";
NSString * const ASPurchaseOrderCreationDateKey = @"creationDate";
NSString * const ASPurchaseOrderStatusLastUpdatedDateKey = @"lastUpdated";
NSString * const ASPurchaseOrderStatusKey = @"orderStatus";

@implementation ASPurchaseOrder

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _identifier = dictionary[ASPurchaseOrderIdentiferKey];
        _vendor = dictionary[ASPurchaseOrderVendorKey];
        _shippingAddress = [[ASAddress alloc] initWithDictionary:dictionary[ASPurchaseOrderShippingAddressKey]];
        _billingAddress = [[ASAddress alloc] initWithDictionary:dictionary[ASPurchaseOrderBillingAddressKey]];
        _paymentProfile = [[ASPaymentProfile alloc] initWithDictionary:dictionary[ASPurchaseOrderPaymentProfileKey]];
        
        NSMutableArray<ASStoreItem *> *items = [NSMutableArray array];
        for (NSDictionary *itemDictionary in dictionary[ASPurchaseOrderStoreItemsKey]) {
            ASStoreItem *item = [[ASStoreItem alloc] initWithDictionary:itemDictionary];
            [items addObject:item];
        }
        _storeItems = [NSArray arrayWithArray:items];
        
        _containerIdentifier = dictionary[ASPurchaseOrderContainerIdentifierKey];
        _shippingOption = [[ASShippingOption alloc] initWithDictionary:dictionary[ASPurchaseOrderShippingOptionKey]];
        _salesTax = dictionary[ASPurchaseOrderSalesTaxKey];
        _total = dictionary[ASPurchaseOrderTotalKey];
        
        ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
        _creationDate = [formatter dateFromString:dictionary[ASPurchaseOrderCreationDateKey]];
        _statusLastUpdatedDate = [formatter dateFromString:dictionary[ASPurchaseOrderStatusLastUpdatedDateKey]];
        _status = dictionary[ASPurchaseOrderStatusKey];
    }
    
    return self;
}

- (NSDictionary *)dictionaryWithError:(NSError *__autoreleasing *)error {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[ASPurchaseOrderIdentiferKey] = self.identifier;
    dictionary[ASPurchaseOrderVendorKey] = self.vendor;
    
    NSError *localError = nil;
    NSDictionary *shippingAddressDictionary = [self.shippingAddress dictionaryWithError:&localError];
    
    if (localError) {
        if (error) {
            *error = localError;
        }
        return nil;
    }
    
    dictionary[ASPurchaseOrderShippingAddressKey] = shippingAddressDictionary;
    
    NSDictionary *billingAddressDictionary = [self.billingAddress dictionaryWithError:&localError];
    
    if (localError) {
        if (error) {
            *error = localError;
        }
        return nil;
    }
    
    dictionary[ASPurchaseOrderBillingAddressKey] = billingAddressDictionary;
    
    NSDictionary *paymentProfileDictionary = [self.paymentProfile dictionaryWithError:&localError];
    
    if (localError) {
        if (error) {
            *error = localError;
        }
        return nil;
    }
    
    dictionary[ASPurchaseOrderPaymentProfileKey] = paymentProfileDictionary;
    
    NSMutableArray<NSDictionary *> *itemDictionaries = [NSMutableArray array];
    for (ASStoreItem *item in self.storeItems) {
        NSDictionary *itemDictionary = [item dictionaryWithError:&localError];
        if (localError) {
            if (error) {
                *error = localError;
            }
            return nil;
        }
        [itemDictionaries addObject:itemDictionary];
    }
    
    dictionary[ASPurchaseOrderStoreItemsKey] = [NSArray arrayWithArray:itemDictionaries];
    dictionary[ASPurchaseOrderContainerIdentifierKey] = self.containerIdentifier;
    
    NSDictionary *shippingOptionDictionary = [self.shippingOption dictionaryWithError:&localError];
    
    if (localError) {
        if (error) {
            *error = localError;
        }
        return nil;
    }
    
    dictionary[ASPurchaseOrderShippingOptionKey] = shippingOptionDictionary;

    dictionary[ASPurchaseOrderSalesTaxKey] = self.salesTax;
    dictionary[ASPurchaseOrderTotalKey] = self.total;

    ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
    dictionary[ASPurchaseOrderCreationDateKey] = [formatter stringFromDate:self.creationDate];
    dictionary[ASPurchaseOrderStatusLastUpdatedDateKey] = [formatter stringFromDate:self.statusLastUpdatedDate];
    dictionary[ASPurchaseOrderStatusKey] = self.status;
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end
