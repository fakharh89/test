//
//  ASStoreItemGroup.h
//  AFNetworking
//
//  Created by Oleg Ivaniv on 11/2/17.
//

#import <Foundation/Foundation.h>

@interface ASStoreItemGroup : NSObject

@property (nonatomic, strong, readonly) NSNumber *identifier;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, copy, readonly) NSString *descriptionUrl;
@property (nonatomic, copy, readonly) NSString *specsUrl;
@property (nonatomic, copy, readonly) NSString *vendorId;

@end
