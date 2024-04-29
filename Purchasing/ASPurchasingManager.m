//
//  ASPurchasingManager.m
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASPurchasingManagerPrivate.h"

#import "AFHTTPSessionManager.h"
#import "ASAddressPrivate.h"
#import "ASContainer.h"
#import "ASPaymentProfilePrivate.h"
#import "ASPurchaseOrderPrivate.h"
#import "ASReorderProfilePrivate.h"
#import "ASShippingOptionPrivate.h"
#import "ASStoreItemPrivate.h"

@implementation ASPurchasingManager

- (instancetype)initWithHTTPSessionManager:(AFHTTPSessionManager *)manager {
    self = [super init];
    
    if (self) {
        _manager = manager;
    }
    
    return self;
}

- (void)getStoreItemsForVendor:(NSString *)vendor success:(void (^)(NSArray<ASStoreItem *> *storeItems))success failure:(void (^)(NSError *error))failure {
    NSString *url = @"shop/items/";
    if (vendor) {
        url = [NSString stringWithFormat:@"%@%@/", url, vendor];
    }
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!success) {
            return;
        }
        
        NSMutableArray<ASStoreItem *> *mutableItems = [NSMutableArray array];
        for (NSDictionary *dictionary in responseObject) {
            ASStoreItem *item = [[ASStoreItem alloc] initWithDictionary:dictionary];
            [mutableItems addObject:item];
        }
        
        success([NSArray arrayWithArray:mutableItems]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getReorderProfilesForVendor:(NSString *)vendor container:(ASContainer *)container success:(void (^)(NSArray<ASReorderProfile *> *reorderProfiles))success failure:(void (^)(NSError *error))failure {
    NSParameterAssert(container);
    
    NSString *url = [NSString stringWithFormat:@"shop/reorders/%@/", container.identifier];
    if (vendor) {
        url = [NSString stringWithFormat:@"%@%@/", url, vendor];
    }
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!success) {
            return;
        }
        
        NSMutableArray<ASReorderProfile *> *profiles = [NSMutableArray array];
        for (NSDictionary *dictionary in responseObject) {
            ASReorderProfile *profile = [[ASReorderProfile alloc] initWithDictionary:dictionary];
            [profiles addObject:profile];
        }
        
        success([NSArray arrayWithArray:profiles]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

// TODO: Cleanup the names of these functions
- (void)editReorderProfile:(ASReorderProfile *)reorderProfile completion:(void (^)(NSError *error))completion {
    [self editReorderProfile:reorderProfile newReorderProfile:reorderProfile completion:completion];
}

- (void)editReorderProfile:(ASReorderProfile *)reorderProfile newReorderProfile:(ASReorderProfile *)newReorderProfile completion:(void (^)(NSError *error))completion {
    NSParameterAssert(reorderProfile);
    NSParameterAssert(newReorderProfile);
    
    NSError *error = nil;
    NSDictionary *parameters = [newReorderProfile dictionaryWithError:&error];
    
    if (error) {
        if (completion) {
            completion(error);
        }
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"shop/reorders/%@/%@/%@/", reorderProfile.containerIdentifier, reorderProfile.vendor, reorderProfile.storeItemIdentifier];
    
    [self.manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)createReorderProfile:(ASReorderProfile *)reorderProfile completion:(void (^)(NSError *error))completion {
    NSParameterAssert(reorderProfile);
    
    NSError *error = nil;
    NSDictionary *parameters = [reorderProfile dictionaryWithError:&error];
    
    if (error) {
        if (completion) {
            completion(error);
        }
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"shop/reorders/%@/%@/%@/", reorderProfile.containerIdentifier, reorderProfile.vendor, reorderProfile.storeItemIdentifier];
    
    [self.manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)deleteReorderProfile:(ASReorderProfile *)reorderProfile completion:(void (^)(NSError *error))completion {
    NSParameterAssert(reorderProfile);
    
    NSString *url = [NSString stringWithFormat:@"shop/reorders/%@/%@/%@/", reorderProfile.containerIdentifier, reorderProfile.vendor, reorderProfile.storeItemIdentifier];
    
    [self.manager DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            completion(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)getShippingAddressesForVendor:(NSString *)vendor success:(void (^)(NSArray<ASAddress *> *shippingAddresses))success failure:(void (^)(NSError *error))failure {
    NSParameterAssert(vendor);
    
    NSString *url = [NSString stringWithFormat:@"shop/address/%@/", vendor];
    
    [self.manager GET:url parameters:@{@"type":@"shipping"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!success) {
            return;
        }
        
        NSMutableArray<ASAddress *> *addresses = [NSMutableArray array];
        for (NSDictionary *dictionary in responseObject) {
            ASAddress *address = [[ASAddress alloc] initWithDictionary:dictionary];
            [addresses addObject:address];
        }
        
        success([NSArray arrayWithArray:addresses]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getBillingAddressesForVendor:(NSString *)vendor success:(void (^)(NSArray<ASAddress *> *billingAddresses))success failure:(void (^)(NSError *error))failure {
    NSParameterAssert(vendor);
    
    NSString *url = [NSString stringWithFormat:@"shop/address/%@/", vendor];
    
    [self.manager GET:url parameters:@{@"type":@"billing"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!success) {
            return;
        }
        
        NSMutableArray<ASAddress *> *addresses = [NSMutableArray array];
        for (NSDictionary *dictionary in responseObject) {
            ASAddress *address = [[ASAddress alloc] initWithDictionary:dictionary];
            [addresses addObject:address];
        }
        
        success([NSArray arrayWithArray:addresses]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getPaymentProfilesForVendor:(NSString *)vendor success:(void (^)(NSArray<ASPaymentProfile *> *paymentProfiles))success failure:(void (^)(NSError *error))failure {
    NSParameterAssert(vendor);
    
    NSString *url = [NSString stringWithFormat:@"shop/payment/%@/", vendor];
    
    [self.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!success) {
            return;
        }
        
        NSMutableArray<ASPaymentProfile *> *addresses = [NSMutableArray array];
        for (NSDictionary *dictionary in responseObject) {
            ASPaymentProfile *address = [[ASPaymentProfile alloc] initWithDictionary:dictionary];
            [addresses addObject:address];
        }
        
        success([NSArray arrayWithArray:addresses]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getShippingOptionsForVendor:(NSString *)vendor order:(ASPurchaseOrder *)purchaseOrder success:(void (^)(NSArray<ASShippingOption *> *shippingOptions))success failure:(void (^)(NSError *error))failure {
    NSParameterAssert(vendor);
    NSParameterAssert(purchaseOrder);
    
    NSString *url = [NSString stringWithFormat:@"shop/shipping/options/%@/", vendor];
    
    NSError *error = nil;
    NSDictionary *parameters = [purchaseOrder dictionaryWithError:&error];
    if (error) {
        if (failure) {
            failure(error);
        }
        return;
    }
    
    [self.manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!success) {
            return;
        }
        
        NSMutableArray<ASShippingOption *> *options = [NSMutableArray array];
        for (NSDictionary *dictionary in responseObject) {
            ASShippingOption *option = [[ASShippingOption alloc] initWithDictionary:dictionary];
            [options addObject:option];
        }
        success([NSArray arrayWithArray:options]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getTaxesForVendor:(NSString *)vendor order:(ASPurchaseOrder *)purchaseOrder success:(void (^)(ASPurchaseOrder *purchaseOrder))success failure:(void (^)(NSError *error))failure {
    NSParameterAssert(vendor);
    NSParameterAssert(purchaseOrder);
    
    NSString *url = [NSString stringWithFormat:@"shop/taxes/calculate/%@/", vendor];
    
    NSError *error = nil;
    NSDictionary *parameters = [purchaseOrder dictionaryWithError:&error];
    if (error) {
        if (failure) {
            failure(error);
        }
        return;
    }
    
    [self.manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success([[ASPurchaseOrder alloc] initWithDictionary:responseObject]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)createPurchaseOrder:(ASPurchaseOrder *)purchaseOrder vendor:(NSString *)vendor completion:(void (^)(NSError *error))completion {
    NSParameterAssert(purchaseOrder);
    NSParameterAssert(vendor);
    
    NSString *url = [NSString stringWithFormat:@"shop/orders/%@/", vendor];
    
    NSError *error = nil;
    NSDictionary *parameters = [purchaseOrder dictionaryWithError:&error];
    if (error) {
        if (completion) {
            completion(error);
        }
        return;
    }
    
    [self.manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
