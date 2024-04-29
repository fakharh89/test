//
//  ASLog.m
//  Blustream
//
//  Created by Michael Gordon on 2/15/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASLog.h"

#import "ASConfig.h"
#import "ASSystemManagerPrivate.h"
#import "ASDateFormatter.h"

dispatch_queue_t log_queue() {
    static dispatch_queue_t as_log_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        as_log_queue = dispatch_queue_create("com.acoustic-stream.log.queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return as_log_queue;
}

void ASBLELog(NSString *message) {
    ASLogLevel level = ASSystemManager.shared.config.loggingLevel;
    
    if (level == ASLogLevelDisabled || !message) {
        return;
    }
    
    ASLogMessage(message);
}

void ASLog(NSString *format, ...) {
    va_list args;
    
    ASLogLevel level = ASSystemManager.shared.config.loggingLevel;
    
    if (level == ASLogLevelDisabled || level == ASLogLevelBLEOnly) {
        return;
    }
    
    if (format) {
        va_start(args, format);
        
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        
        ASLogMessage(message);
        
        va_end(args);
    }
}

void ASLogMessage(NSString *message) {
    
    if (ASSystemManager.shared.config.logToFile) {
        NSDate *now = [NSDate date];
        dispatch_async(log_queue(), ^{
            static NSString *filename;
            static ASDateFormatter *formatter;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
                filename = [docsPath stringByAppendingPathComponent:@"Log.txt"];
                formatter = [[ASDateFormatter alloc] init];
            });
            
            NSString *logMessage = [NSString stringWithFormat:@"%@: %@\n", [formatter stringFromDate:now], message];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
                NSError *error = nil;
                if (![logMessage writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
                    NSLog(@"Critical error!  Couldn't update log file with message!\n%@", error);
                }
            }
            else {
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filename];
                [fileHandle seekToEndOfFile];
                [fileHandle writeData:[logMessage dataUsingEncoding:NSUTF8StringEncoding]];
                [fileHandle closeFile];
            }
            
            // Set folder to not backup to iCloud.  Writing erases this attribute
            [ASSystemManager addSkipBackupAttributeToItemAtPath:filename];
        });
    }
        
    ASCustomLoggingBlock block = ASSystemManager.shared.config.customLogger;
    
    if (block) {
        block(message);
    }
    else {
        NSLog(@"%@", message);
    }
}

void deleteLog(void) {
    dispatch_sync(log_queue(), ^{
        NSString *docsPath = [ASSystemManager applicationHiddenDocumentsDirectory];
        NSString *filename = [docsPath stringByAppendingPathComponent:@"Log.txt"];
        [[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
    });
}
