//
//  SWWTB+NSNotificationCenter+Addition.h
//
//  Copyright (C) 2011-2013 Sonoma Wire Works. All rights reserved.
//

//#import "SWWToolBox.h"

#ifndef SWWTBNSNOTIFICATIONCENTERADDITION_H
#define SWWTBNSNOTIFICATIONCENTERADDITION_H

@interface NSNotificationCenter (SWWTBNSNotificationCenterMultiThreadingAddition)

- (void)postNotificationOnThread:(NSNotification *)aNotification onThread:(NSThread *)thr;
- (void)postNotificationOnThread:(NSNotification *)aNotification onThread:(NSThread *)thr waitUntilDone:(BOOL)shouldWaitUntilDone;
- (void)postNotificationOnMainThread:(NSNotification *)aNotification;

// shouldWaitUntilDone blocks on current thread
- (void)postNotificationOnMainThread:(NSNotification *)aNotification waitUntilDone:(BOOL)shouldWaitUntilDone;

- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject;
- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject userObject:(id)userObject;
- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject userObject:(id)userObject waitUntilDone:(BOOL)shouldWaitUntilDone;

@end

@interface NSNotificationCenter (SWWTBNSNotificationCenterTollFreeAddition)

- (void)postNotificationName:(NSString *)notificationName object:(id)notificationSender userObject:(id)userObject forceAsync:(BOOL)forceAsync;
- (void)postNotificationName:(NSString *)notificationName object:(id)notificationSender userObject:(id)userObject;

@end

#endif /* !SWWTBNSNOTIFICATIONCENTERADDITION_H */

/* EOF */