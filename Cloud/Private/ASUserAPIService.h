//
//  ASUserAPIService.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 12/26/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASUser;
@class ASSystemManager;
@class ASHub;

typedef NS_ENUM(NSInteger, ASAccessType) {
    ASAccessTypeOwner = 0,
    ASAccessTypeShared = 1
};

typedef void (^ASSuccessBlock)(void);
typedef void (^ASFailureBlock)(NSError *error);

@interface ASUserAPIService : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithUser:(ASUser *)user
               systemManager:(ASSystemManager *)systemManager NS_DESIGNATED_INITIALIZER;

- (void)getUserDataWithSuccess:(void(^)(NSDictionary *userDictionary))success
                       failure:(ASFailureBlock)failure;

- (void)postWithSuccess:(void(^)(NSDate *lastSynced))success
                failure:(ASFailureBlock)failure;
- (void)deleteWithSuccess:(ASSuccessBlock)success
                  failure:(ASFailureBlock)failure;

- (void)postImageWithSuccess:(void(^)(NSString *imageURL, NSDate *imageLastSynced))success
                     failure:(ASFailureBlock)failure;
- (void)getImageWithSuccess:(void(^)(UIImage *image))success
                    failure:(ASFailureBlock)failure;

- (void)getHubsWithSuccess:(void(^)(NSArray<ASHub *> *hubs))success
                   failure:(ASFailureBlock)failure;
- (void)subscribeHubToSilentNotifications:(ASHub *)hub
                              withSuccess:(void(^)(ASHub * hub))success
                                  failure:(ASFailureBlock)failure;

- (void)updateAllHubsWithTitle:(NSString *)title
                       message:(NSString *)message
                     playSound:(BOOL)sound
                       success:(ASSuccessBlock)success
                       failure:(ASFailureBlock)failure;

- (void)updateAllHubsWithTitle:(NSString *)title
                       message:(NSString *)message
                     playSound:(BOOL)sound
              bundleIdentifier:(NSString *)bundleIdentifier
                       success:(ASSuccessBlock)success
                       failure:(ASFailureBlock)failure;

- (void)sendSilentNotificationToAllHubsWithPayload:(NSDictionary *)payload
                                           success:(ASSuccessBlock)success
                                           failure:(ASFailureBlock)failure;

- (void)getUpdatedContainersForType:(ASAccessType)type
                            success:(void(^)(NSArray *updatedContainer))success
                            failure:(ASFailureBlock)failure;

@end
