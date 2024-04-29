//
//  ASDateFormatter.m
//  Blustream
//
//  Created by Michael Gordon on 6/19/16.
//
//

#import "ASDateFormatter.h"

#import "sqlite3.h"

// Built using ISO8601DateFormatter
// https://github.com/boredzo/iso-8601-date-formatter/


@interface ASDateFormatter ()

@property (assign, readwrite, nonatomic) sqlite3 *db;
@property (assign, readwrite, nonatomic) sqlite3_stmt *statement;
@property (strong, readwrite, nonatomic) NSDateFormatter *unparsingFormatter;
@property (strong, readwrite, nonatomic) NSCalendar *unparsingCalendar;

@end

@implementation ASDateFormatter

- (id)init {
    self = [super init];
    if (self) {
        sqlite3_open(":memory:", &_db);
        _statement = NULL;
        sqlite3_prepare_v2(_db, "SELECT strftime('%s', ?);", -1, &_statement, NULL);
        
        self.unparsingCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        self.unparsingCalendar.firstWeekday = 2; //Monday
        self.unparsingCalendar.timeZone = [NSTimeZone defaultTimeZone];
        
        self.unparsingFormatter = [[NSDateFormatter alloc] init];
        self.unparsingFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
        self.unparsingFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
        self.unparsingFormatter.calendar = self.unparsingCalendar;
        self.unparsingFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    return self;
}

- (void)dealloc {
    sqlite3_finalize(_statement);
    sqlite3_close(_db);
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSString *dateString = [self.unparsingFormatter stringForObjectValue:date];
    
    NSInteger offset = [self.unparsingCalendar.timeZone secondsFromGMTForDate:date];
    offset /= 60;  //bring down to minutes
    if (offset == 0) {
        dateString = [dateString stringByAppendingString:@"Z"];
    }
    else {
        int timeZoneOffsetHour = abs((int)(offset / 60));
        int timeZoneOffsetMinute = abs((int)(offset % 60));
        
        if (offset > 0) {
            dateString = [dateString stringByAppendingString:@"+"];
        }
        else {
            dateString = [dateString stringByAppendingString:@"-"];
        }
        
        dateString = [dateString stringByAppendingFormat:@"%.2d", timeZoneOffsetHour];
        
        dateString = [dateString stringByAppendingFormat:@"%.2d", timeZoneOffsetMinute];
    }
    
    return dateString;
}

- (NSDate *)dateFromString:(NSString *)string {
    // Use SQL instead of NSCalendar dateFromComponents.  dateFromComponents is absurdly slow
    sqlite3_bind_text(_statement, 1, [string UTF8String], -1, SQLITE_STATIC);
    sqlite3_step(_statement);
    int64_t value = sqlite3_column_int64(_statement, 0);
    sqlite3_clear_bindings(_statement);
    sqlite3_reset(_statement);
    
    NSTimeInterval parsedFractionOfSecond = 0.0;
    
    NSInteger numberOfDecimals = string.length - 20 - 1;
    
    NSString *millisString = [string substringWithRange:NSMakeRange(20, numberOfDecimals)];
    parsedFractionOfSecond = [millisString intValue] / pow(10, numberOfDecimals);
    
    NSDate *parsedDate = [NSDate dateWithTimeIntervalSince1970:(value + parsedFractionOfSecond)];
    
    return parsedDate;
}

@end
