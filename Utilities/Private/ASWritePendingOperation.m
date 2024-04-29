//
//  ASWritePendingOperation.m
//  AS-iOS-Framework
//
//  Created by Oleg Ivaniv on 4/20/18.
//

#import "ASWritePendingOperation.h"

@interface ASWritePendingOperation()

@property (nonatomic, copy, readwrite) NSString *serviceString;
@property (nonatomic, copy, readwrite) NSString *characteristicString;
@property (nonatomic, assign, readwrite) id data;
@property (nonatomic, copy, readwrite) ASWriteCompletionBlock completion;

@end

@implementation ASWritePendingOperation

- (instancetype)initWithServiceString:(nonnull NSString *)serviceString characteristicString:(nonnull NSString *)characteristicString data:(nonnull id)data completion:(ASWriteCompletionBlock)completion {
    self = [super init];
    
    if (self) {
        _serviceString = serviceString;
        _characteristicString = characteristicString;
        _data = data;
        _completion = completion;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isServiceStringEqual = [self.serviceString isEqualToString:((ASWritePendingOperation *)object).serviceString];
    BOOL isCharacteristicStringEqual = [self.characteristicString isEqualToString:((ASWritePendingOperation *)object).characteristicString];
    
    return isServiceStringEqual && isCharacteristicStringEqual;
}

@end
