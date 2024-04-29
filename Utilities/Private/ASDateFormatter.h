//
//  ASDateFormatter.h
//  Blustream
//
//  Created by Michael Gordon on 6/19/16.
//
//

#import <Foundation/Foundation.h>

@interface ASDateFormatter : NSObject

- (NSString *)stringFromDate:(NSDate *)date;
- (NSDate *)dateFromString:(NSString *)string;

@end
