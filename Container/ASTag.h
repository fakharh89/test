//
//  ASTag.h
//  Blustream
//
//  Created by Michael Gordon on 11/16/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@class ASContainer;

/**
 *  The `ASTag` protocol should be adopted by any object put in the ASContainer `tag` property if
 *  the developer wishes to store a reference to the parentContainer.  This property can be set
 *  manually when the ASContainer is first initialized, but it must be set by the framework 
 *  when the tag object is deserialized.
 */
@protocol ASTag <NSObject>

@optional
/**
 *  A weak reference to the parent `ASContainer`.
 *  
 *  This optional property is set immediately after an `ASContainer` object is deserialized.
 */
@property (weak, readwrite, nonatomic) ASContainer *parentContainer;

@end
