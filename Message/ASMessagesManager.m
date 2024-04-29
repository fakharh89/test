//
//  ASMessagesManager.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 6/19/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import "ASMessagesManager.h"

#import "ASSystemManager.h"
#import "ASCloudPrivate.h"
#import "ASUserPrivate.h"
#import "ASMessage.h"
#import "ASMessageOwner.h"
#import "ASPagingResult.h"
#import "AFHTTPSessionManager.h"
#import "ASDateFormatter.h"

static NSString * const ASGetMessagesURLFormat = @"messages/%@/";
static NSString * const ASBookmarkMessageURLFormat = @"messages/%@/msg/%@/bookmark";
static NSString * const ASReadMessageURLFormat = @"messages/%@/msg/%@/read";

static NSString * const ASLimitKey = @"limit";
static NSString * const ASOffsetKey = @"offset";
static NSString * const ASIsAlertKey = @"isAlert";
static NSString * const ASIsBookmarkKey = @"isBookmark";

@interface ASMessagesManager()

@property (nonatomic, strong) ASSystemManager *systemManager;

@end

@implementation ASMessagesManager

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager {
    self = [super init];
    
    if (self) {
        _systemManager = systemManager;
    }
    
    return self;
}

- (void)getMessagesWithSuccess:(ASGetSuccessBlock)success failure:(ASFailureBlock)failure {
    [self getMessagesWithLimit:nil offset:nil isAlert:NO isBookmark:NO success:success failure:failure];
}

- (void)getMessagesWithLimit:(NSNumber *)limit offset:(NSNumber *)offset isAlert:(BOOL)isAlert isBookmark:(BOOL)isBookmark success:(ASGetSuccessBlock)success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:ASGetMessagesURLFormat, self.systemManager.cloud.user.usernameWithTag];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (limit) {
        [parameters addEntriesFromDictionary:@{ASLimitKey: limit}];
    }
    if (offset) {
        [parameters addEntriesFromDictionary:@{ASOffsetKey: offset}];
    }
    
    [parameters addEntriesFromDictionary:@{ASIsAlertKey: @(isAlert)}];
    [parameters addEntriesFromDictionary:@{ASIsBookmarkKey: @(isBookmark)}];
    
    [self.systemManager.cloud.HTTPManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            ASPagingResult *result = [[ASPagingResult alloc] initWithDictionary:responseObject];
            success(result);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)bookmarkMessage:(ASMessage *)message value:(BOOL)value success:(ASUpdateSuccessBlock)success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:ASBookmarkMessageURLFormat,
                     message.owner.username, message.messageId];
    
    NSDictionary *parameters = @{@"bookmark": @(value)};
    
    [self putData:parameters toURL:url success:success failure:failure];
}

- (void)readMessage:(ASMessage *)message date:(NSDate *)date success:(ASUpdateSuccessBlock)success failure:(ASFailureBlock)failure {
    NSString *url = [NSString stringWithFormat:ASReadMessageURLFormat,
                     message.owner.username, message.messageId];
    
    NSDictionary *parameters = @{@"read": [[ASDateFormatter new] stringFromDate:date]};
    
    [self putData:parameters toURL:url success:success failure:failure];
}

- (void)putData:(NSDictionary *)data toURL:(NSString *)url success:(ASUpdateSuccessBlock)success failure:(ASFailureBlock)failure {
    [self.systemManager.cloud.HTTPManager PUT:url parameters:data success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            ASMessage *message = [[ASMessage alloc] initWithDictionary:responseObject[@"data"]];
            success(message);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
