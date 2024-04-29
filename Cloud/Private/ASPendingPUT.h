//
//  ASPendingPUT.h
//  Blustream
//
//  Created by Michael Gordon on 7/24/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

@interface ASPendingPUT : NSObject <NSCoding, NSCopying>

@property (strong, readwrite, nonatomic) NSString *containerID;
@property (strong, readwrite, nonatomic) NSDictionary *dataBlob;

@end
