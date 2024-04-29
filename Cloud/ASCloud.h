//
//  ASCloud.h
//  Blustream
//
//  Created by Michael Gordon on 11/19/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

/**
 *  These constants indicate the login state of the user's credentials stored within the `ASCloud` class.
 */
typedef NS_ENUM(NSInteger, ASUserState) {
    /**
     *  Indicates that the user is logged out and the developer should offer the user the opportunity
     *  to login again.
     */
            ASUserLoggedOut = 0,
    /**
     *  Indicates that a login request is pending.
     */
            ASUserLoggingIn = 1,
    /**
     *  Indicates that the user is logged in and that the credentials are valid.
     */
            ASUserLoggedIn = 2
};

@class ASUser;
@class ASPurchasingManager;
@class ASSystemManager;
@class ASDataUpdateResponse;

/**
 *  The `ASCloud` class contains methods for managing the user's login state.  Access it through the `ASSystemManager` instance property.
 *  User data is persisted through sessions.
 */
@interface ASCloud : NSObject

/**
 *  The current login state for the user. (read-only)
 *
 *  This property changes as the credentials are validated.  It will also change if communication with the server fails and the user
 *  should be prompted to re-enter their credentials.
 *  @see ASUserState
 */
@property (assign, readonly, nonatomic) ASUserState userStatus;

/**
 *  The user account information for the logged-in user. (read-only)
 *
 *  The value of this property stores all of the relevant user information while the user is logged-in.  @See ASUser.
 */
@property (strong, readonly, nonatomic) ASUser *user;

@property (strong, readonly, nonatomic) ASPurchasingManager *purchasingManager;

/**
 *  Creates a new user account with the server.
 *
 *  This function returns errors in the ASCloudErrorDomain and ASAccountCreationErrorDomain.
 *
 *  @param userInfo   A dictionary which holds the following key-value pairs (all values must be of NSString type):
 *  | Key          | Value                     |
 *  | ------------ | ------------------------- |
 *  | @"email"     | The user's email address. |
 *  | @"password"  | The user's password.      |
 *  | @"firstname" | The user's first name.    |
 *  | @"lastname"  | The user's last name.     |
 *  | @"optIn"     | Email marketing flag.     |
 *
 *  Last name and first names must be less than 40 characters.  Email address must have an at symbol (@), a period, and no
 *  white space.  (we are implementing email verification later).  Password must be 8 characters or more, have at least 
 *  one uppercase letter, one lowercase letter, and one number.  User's email and username are equivalent.  The optIn
 *  flag is a boolean NSNumber.
 *  @param completion A block that is called upon finishing creating a new user account. (`error` is nil if successful)
 */
- (void)registerNewUser:(NSDictionary *)userInfo completion:(void (^)(NSError *error))completion;

/**
 *  Logs in a user with the server.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param username   The username in string form of the user that would like to log in.
 *  @param password   The password of mentioned user in string form.
 *  @param completion A block that is called upon finishing logging in with the server. (`error` is nil if successful)
 */
- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(NSError *error))completion;

/**
 *  Logs the user out.  Clears all server tokens, disconnects from all devices, resets username property, and resets device list.
 */
- (void)logout;

/**
 *  Sends a password reset email to the given user's email address.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param username   The username in string form of the user that would like to reset their password.
 *  @param completion A block that is called upon finishing sending the password reset email. (`error` is nil if successful)
 */
- (void)sendPasswordResetEmailForUsername:(NSString *)username completion:(void (^)(NSError *error))completion;

/**
 *  Sends a remote notification to all phones/tablets (iOS and Android) that user is currently logged into.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param title      The title of the push notification.  This is an optional parameter.
 *  @param message    The message in the push notification.
 *  @param sound      A toggle indicating if the push notification should make sound or not.
 *  @param completion A block that is called upon finishing sending the remote notification to our server (not APNS).  (`error` is nil if successful)
 */
- (void)sendRemoteNotificationToAllDevicesWithTitle:(NSString *)title message:(NSString *)message playSound:(BOOL)sound completion:(void (^)(NSError *error))completion;

/**
 *  Sends a silent notification to all phones/tablets (iOS and Android) that user is currently logged into.
 *
 *  This function returns errors in the ASCloudErrorDomain.
 *
 *  @param payload    Payload data for silent notification.
 *  @param success    A block that is called upon successfully finishing sending the silent notification.
 *  @param failure    A block that is called upon finishing sending the silent notification with error.
 */
- (void)sendSilentNotificationToAllDevicesWithPayload:(NSDictionary *)payload
                                              success:(void (^)(void))success
                                              failure:(void (^)(NSError *error))failure;

/**
 *  Authentificates user into wordress-based web views.
 */
- (void)wordPressLoginWithRedirectURL:(NSString *)redirectUrl
                              success:(void (^)(NSString *redirectUri))success
                              failure:(void (^)(NSError *error))failure;

- (void)saveUser;

- (instancetype)init NS_UNAVAILABLE;

- (void)checkForNewDataWithSuccess:(void (^)(ASDataUpdateResponse *response))success
                           failure:(void (^)(NSError *error))failure;

@end
