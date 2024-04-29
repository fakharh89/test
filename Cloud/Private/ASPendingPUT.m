//
//  ASPendingPUT.m
//  Blustream
//
//  Created by Michael Gordon on 7/24/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASPendingPUT.h"

@implementation ASPendingPUT

#pragma mark - NSCoding

#define kContainerID @"ContainerID"
#define kDataBlob    @"DataBlob"

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.containerID forKey:kContainerID];
    [encoder encodeObject:self.dataBlob forKey:kDataBlob];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        _containerID = [decoder decodeObjectForKey:kContainerID];
        _dataBlob = [decoder decodeObjectForKey:kDataBlob];
    }
    
    return self;
}

#pragma mark - NSCopying Methods

- (id)copyWithZone:(NSZone *)zone {
    ASPendingPUT *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_containerID = [_containerID copyWithZone:zone];
        copy->_dataBlob = [_dataBlob copyWithZone:zone];
    }
    
    return copy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Container ID: %@\nData: %@", self.containerID, self.dataBlob];
}

@end
