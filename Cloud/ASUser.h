//
//  ASUser.h
//  Blustream
//
//  Created by Michael Gordon on 3/16/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@class UIImage;
@class ASMessage;

/**
 *  This class stores the user's information.
 */
@interface ASUser : NSObject

/**
 *  The username for the currently logged-in user. (read-only)
 *
 *  The value of this property is an NSString that changes when the `loginWithUsername:` method is called.
 *  If the credentials are ever invalidated by the server, this property does not change.  It is persisted
 *  between sessions.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *username;

/**
 *  The same as username, but with the app tag.
 *
 */
@property (nonatomic, copy, readonly, nonnull) NSString *usernameWithTag;

/**
 *  The user's first name.
 *
 *  The value of this property is a human readable string containing the first name of the user.
 *  It is persisted between sessions and synced with the server.
 */
@property (nonatomic, copy, nullable) NSString *firstName;

/**
 *  The user's last name.
 *
 *  The value of this property is a human readable string containing the last name of the user.
 *  It is persisted between sessions and synced with the server.
 */
@property (nonatomic, copy, nullable) NSString *lastName;

/**
 *  The user's image.
 *
 *  The value of this property is an image that the user can set to represent this his/herself.
 *  It does not have a default.  This value is synced with the server.  It is serialized and
 *  deserialized between sessions.
 */
@property (nonatomic, strong, nullable) UIImage *image;

/**
 *  The date the user created the account. (read-only)
 *
 *  The value of this property is the date that the user originally created the account.
 *  It is persisted between sessions.
 */
@property (nonatomic, strong, readonly, nullable) NSDate *creationDate;

/**
 *  A customizable dictionary representing developer-defined properties of the user.
 *
 *  The value of this property is a dictionary that represents whatever data the developer
 *  wishes to sync with our server.  For example, if the developer wishes to sync the age of the
 *  user, they could add @{@"age":@(28)} to the dictionary.  Tested key types are NSString,
 *  NSNumber, NSArray, and NSDictionary.  This property does not have a default value.  Setting
 *  this value will update the server accordingly.
 */
@property (nonatomic, copy, nullable) NSDictionary *metadata;

/**
 *  The date the user was last synced with the server. (read-only)
 *
 *  The value of this property is a date that represents the last time the server and the app synced
 *  this user.  The server keeps track of this date so it is the same on all iOS devices.
 */
@property (nonatomic, strong, readonly, nonnull) NSDate *lastSynced;

@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, NSString *> *externalTokens;

@property (nonatomic, strong, readonly, nullable) NSDate *logginExpirationDate;

@property (nonatomic, assign) BOOL optIn;

@property (nonatomic, strong, nullable) NSArray<ASMessage *> *messagesCache;

@property (nonatomic, copy, readonly, nullable) NSString *token;

@end

