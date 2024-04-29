//
//  ASPurchasingManagerPrivate.h
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASPurchasingManager.h"

@class AFHTTPSessionManager;

@interface ASPurchasingManager ()

@property (weak, readonly, nonatomic) AFHTTPSessionManager *manager;

- (instancetype)initWithHTTPSessionManager:(AFHTTPSessionManager *)manager;

@end
