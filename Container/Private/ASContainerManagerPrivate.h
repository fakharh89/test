//
//  ASContainerManagerPrivate.h
//  Blustream
//
//  Created by Michael Gordon on 6/25/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASContainerManager.h"

@class ASSystemManager;

@interface ASContainerManager ()

@property (nonatomic, strong) NSMutableArray *containersInternal;
@property (nonatomic, weak) ASSystemManager *systemManager;

- (instancetype)initWithSystemManager:(ASSystemManager *)systemManager NS_DESIGNATED_INITIALIZER;

- (BOOL)syncContainersFromDictionaryArray:(NSArray *)dictionaryArray updatedContainers:(NSArray * __autoreleasing *)updatedContainers;
- (void)loadContainers;
- (void)resetContainers;
- (void)saveContainers;

@end
