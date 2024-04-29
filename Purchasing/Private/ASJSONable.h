//
//  ASJSONable.h
//  Pods
//
//  Created by Michael Gordon on 6/9/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ASJSONable <NSObject>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryWithError:(NSError * __autoreleasing *)error;

@end
