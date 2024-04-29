//
//  ASWritePendingOperation.h
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 4/20/18.
//

#import <Foundation/Foundation.h>

typedef void (^ASWriteCompletionBlock)(NSError *error);

@interface ASWritePendingOperation : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *serviceString;
@property (nonatomic, copy, readonly) NSString *characteristicString;
@property (nonatomic, assign, readonly) id data;
@property (nonatomic, copy, readonly) ASWriteCompletionBlock completion;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithServiceString:(nonnull NSString *)serviceString characteristicString:(nonnull NSString *)characteristicString data:(nonnull id)data completion:(ASWriteCompletionBlock)completion NS_DESIGNATED_INITIALIZER;
    
@end
