//
//  ASContainerManager.h
//  Blustream
//
//  Created by Michael Gordon on 6/25/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@class ASContainer;

/**
 *  The `ASContainerManager` class contains methods for managing the list of containers.  Access it through the
 *  `ASSystemManager` instance property.
 */
@interface ASContainerManager : NSObject

/**
 *  The list of all containers associated with the user's account. (read-only)
 *
 *  The value of this property is an NSArray of containers that are owned by the user.  To add a container,
 *  initialize an ASContainer and use the `addContainer:completion:` method.  To remove a container, 
 *  use the `removeContainer:completion:` method.
 */
@property (strong, readonly, nonatomic) NSArray *containers;

/**
 *  Adds a container to the container list locally and on the server.
 *
 *  This function returns errors in the ASContainerManagerErrorDomain.
 *
 *  @param container  The container to add to the array.
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)addContainer:(ASContainer *)container completion:(void (^)(NSError *error))completion;

/**
 *  Removes a container from the container list locally and on the server.
 *
 *  This function returns errors in the ASContainerManagerErrorDomain.
 *
 *  @param container  The container to remove from the array.
 *  @param completion The block called upon completing the operation.  If successful, `error` will be nil.
 */
- (void)removeContainer:(ASContainer *)container completion:(void (^)(NSError *error))completion;

/**
 *  Exchanges a container at idx1 position with a container at idx2 position.
 *
 *  @param idx1 Position of first container.
 *  @param idx2 Position of second container.
 */
- (void)exchangeContainerAtIndex:(NSUInteger)idx1 withContainerAtIndex:(NSUInteger)idx2;

/**
 *  Returns a subset of `containers` only including containers that are linked to devices.
 *
 *  @return An NSArray of ASContainers.
 */
- (NSArray *)linkedContainers;

/**
 *  Returns a subset of `containers` only including containers that are unlinked to devices.
 *
 *  @return An NSArray of ASContainers.
 */
- (NSArray *)unlinkedContainers;
- (instancetype)init NS_UNAVAILABLE;

@end
