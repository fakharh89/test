//
//  ASPurchasingManager.h
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASAddress;
@class ASContainer;
@class ASPaymentProfile;
@class ASPurchaseOrder;
@class ASReorderProfile;
@class ASShippingOption;
@class ASStoreItem;

@interface ASPurchasingManager : NSObject

- (void)getStoreItemsForVendor:(NSString *)vendor success:(void (^)(NSArray<ASStoreItem *> *storeItems))success failure:(void (^)(NSError *error))failure;

- (void)getReorderProfilesForVendor:(NSString *)vendor container:(ASContainer *)container success:(void (^)(NSArray<ASReorderProfile *> *reorderProfiles))success failure:(void (^)(NSError *error))failure;
- (void)editReorderProfile:(ASReorderProfile *)reorderProfile completion:(void (^)(NSError *error))completion;
- (void)editReorderProfile:(ASReorderProfile *)reorderProfile newReorderProfile:(ASReorderProfile *)newReorderProfile completion:(void (^)(NSError *error))completion;
- (void)createReorderProfile:(ASReorderProfile *)reorderProfile completion:(void (^)(NSError *error))completion;
- (void)deleteReorderProfile:(ASReorderProfile *)reorderProfile completion:(void (^)(NSError *error))completion;

- (void)getShippingAddressesForVendor:(NSString *)vendor success:(void (^)(NSArray<ASAddress *> *shippingAddresses))success failure:(void (^)(NSError *error))failure;
- (void)getBillingAddressesForVendor:(NSString *)vendor success:(void (^)(NSArray<ASAddress *> *billingAddresses))success failure:(void (^)(NSError *error))failure;
- (void)getPaymentProfilesForVendor:(NSString *)vendor success:(void (^)(NSArray<ASPaymentProfile *> *paymentProfiles))success failure:(void (^)(NSError *error))failure;

- (void)getShippingOptionsForVendor:(NSString *)vendor order:(ASPurchaseOrder *)purchaseOrder success:(void (^)(NSArray<ASShippingOption *> *shippingOptions))success failure:(void (^)(NSError *error))failure;
- (void)getTaxesForVendor:(NSString *)vendor order:(ASPurchaseOrder *)purchaseOrder success:(void (^)(ASPurchaseOrder *purchaseOrder))success failure:(void (^)(NSError *error))failure;

- (void)createPurchaseOrder:(ASPurchaseOrder *)order vendor:(NSString *)vendor completion:(void (^)(NSError *error))completion;

@end
