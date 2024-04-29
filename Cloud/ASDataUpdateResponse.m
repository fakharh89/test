//
//  ASUpdateResponse.m
//  AFNetworking
//
//  Created by Michael Gordon on 3/7/19.
//  Copyright © 2019 Blustream Corporation. All rights reserved.
//

#import "ASDataUpdateResponsePrivate.h"

#import "ASDateFormatter.h"
#import "ASContainerDataUpdateSummaryPrivate.h"
#import "ASLog.h"

@implementation ASDataUpdateResponse

- (instancetype)initWithDictionaries:(NSArray<NSDictionary *> *)dictionaries {
    self = [super init];
    
    if (self) {
        _containerDataUpdates = [self dateMapFromContainerArray:dictionaries];
    }
    
    return self;
}

- (NSDictionary<NSString *, ASContainerDataUpdateSummary *> *)dateMapFromContainerArray:(NSArray<NSDictionary *> *)array {
    if (!array || array.count == 0) {
        return nil;
    }
    
    NSMutableDictionary<NSString *, ASContainerDataUpdateSummary *> *containerDataUpdateDictionary = [NSMutableDictionary new];
    ASDateFormatter *formatter = [[ASDateFormatter alloc] init];
    
    for (NSDictionary *dictionary in array) {
        NSString *identifier = dictionary[@"containerId"];
        
        ASContainerDataUpdateSummary *summary = containerDataUpdateDictionary[identifier];
        if (!summary) {
            summary = [[ASContainerDataUpdateSummary alloc] initWithContainerIdentifier:identifier];
        }
        
        NSString *dataType = dictionary[@"dataType"];
        NSString *dateString = dictionary[@"lastModified"];
        NSDate *date = [formatter dateFromString:dateString];
        
        if (![summary setDate:date forDataTypeString:dataType]) {
            ASLog(@"Failed to parse data type (%@) for data update!", dataType);
        }
        
        [containerDataUpdateDictionary setObject:summary forKey:identifier];
    }
    
    return [NSDictionary dictionaryWithDictionary:containerDataUpdateDictionary];
}

@end
