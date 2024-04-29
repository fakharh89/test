//
//  ASMessagesManager.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 6/19/18.
//  Copyright © 2018 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASSystemManager;
@class ASPagingResult;
@class ASMessage;

typedef void (^ASGetSuccessBlock)(ASPagingResult *pagingResult);
typedef void (^ASUpdateSuccessBlock)(ASMessage *message);
typedef void (^ASFailureBlock)(NSError *error);

@interface ASMessagesManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager NS_DESIGNATED_INITIALIZER;

- (void)getMessagesWithSuccess:(ASGetSuccessBlock)success
                       failure:(ASFailureBlock)failure;

- (void)getMessagesWithLimit:(NSNumber *)limit
                      offset:(NSNumber *)offset
                     isAlert:(BOOL)isAlert
                  isBookmark:(BOOL)isBookmark
                     success:(ASGetSuccessBlock)success
                     failure:(ASFailureBlock)failure;

- (void)bookmarkMessage:(ASMessage *)message
                  value:(BOOL)value
                success:(ASUpdateSuccessBlock)success
                failure:(ASFailureBlock)failure;

- (void)readMessage:(ASMessage *)message
              date:(NSDate *)date
            success:(ASUpdateSuccessBlock)success
            failure:(ASFailureBlock)failure;

@end
