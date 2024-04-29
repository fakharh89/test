//
//  SWWTB+NSNotificationCenter+Addition.m
//
//  Copyright (C) 2011-2013 Sonoma Wire Works. All rights reserved.
//

//#import "SWWTB+NSObject+Addition.h"
#import "SWWTB+NSNotificationCenter+Addition.h"

#define _kSWWTBNSNotificationCenterProxyAdditionNotificationNameKey @"name"
#define _kSWWTBNSNotificationCenterProxyAdditionNotificationObjectKey @"object"
#define _kSWWTBNSNotificationCenterProxyAdditionNotificationUserInfoKey @"userInfo"

@interface NSNotificationCenter (SWWTBNSNotificationCenterProxyAdditionProtected)

+ (void)proxyPostNotification:(NSNotification *)aNotification;
- (void)proxyPostNotificationWithInfo:(NSDictionary *)info;
- (void)proxyPostNotification:(NSNotification *)aNotification;

@end

@implementation NSNotificationCenter (SWWTBNSNotificationCenterProxyAdditionProtected)

+ (void)proxyPostNotification:(NSNotification *)aNotification
{
	@synchronized(self)
	{
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		[[self defaultCenter] postNotification:aNotification];
		[pool drain];
	}
}

- (void)proxyPostNotificationWithInfo:(NSDictionary *)info
{
	@synchronized(self)
	{
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		NSString * name = [info objectForKey:_kSWWTBNSNotificationCenterProxyAdditionNotificationNameKey];
		id object = [info objectForKey:_kSWWTBNSNotificationCenterProxyAdditionNotificationObjectKey];
		NSDictionary * userInfo = [info objectForKey:_kSWWTBNSNotificationCenterProxyAdditionNotificationUserInfoKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:name object:object userInfo:userInfo];
		[pool drain];
	}
}

- (void)proxyPostNotification:(NSNotification *)aNotification
{
	@synchronized(self)
	{
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		//SWWTB_LOG(@"proxyPostNotification: %@", [NSThread currentThread]);
		[self postNotification:aNotification];
		[pool drain];
	}
}

@end

@implementation NSNotificationCenter (SWWTBNSNotificationCenterMultiThreadingAddition)

- (void)postNotificationOnThread:(NSNotification *)aNotification onThread:(NSThread *)thr
{
	[self performSelector:@selector(proxyPostNotification:) onThread:thr withObject:aNotification waitUntilDone:NO];
}

- (void)postNotificationOnThread:(NSNotification *)aNotification onThread:(NSThread *)thr waitUntilDone:(BOOL)shouldWaitUntilDone
{
	[self performSelector:@selector(proxyPostNotification:) onThread:thr withObject:aNotification waitUntilDone:shouldWaitUntilDone];
}

- (void)postNotificationOnMainThread:(NSNotification *)aNotification
{
	if ([NSThread isMainThread]) {
		[self postNotification:aNotification];
		return;
	}
	[self performSelectorOnMainThread:@selector(proxyPostNotification:) withObject:aNotification waitUntilDone:NO];
}

- (void)postNotificationOnMainThread:(NSNotification *)aNotification waitUntilDone:(BOOL)shouldWaitUntilDone
{
	if ([NSThread isMainThread]) {
		[self postNotification:aNotification];
		return;
	}
	[self performSelectorOnMainThread:@selector(proxyPostNotification:) withObject:aNotification waitUntilDone:shouldWaitUntilDone];
}

- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject
{
	if ([NSThread isMainThread]) {
		[self postNotificationName:aName object:anObject userInfo:nil];
		return;
	}
	[self postNotificationOnMainThreadWithName:aName object:anObject userObject:nil waitUntilDone:NO];
}

- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject userObject:(id)userObject
{
	if ([NSThread isMainThread]) {
		[self postNotificationName:aName object:anObject userInfo:((id)userObject)];
		return;
	}
	[self postNotificationOnMainThreadWithName:aName object:anObject userObject:((id)userObject) waitUntilDone:NO];
}

- (void)postNotificationOnMainThreadWithName:(NSString *)aName object:(id)anObject userObject:(id)userObject waitUntilDone:(BOOL)shouldWaitUntilDone
{
	if ([NSThread isMainThread]) {
		[self postNotificationName:aName object:anObject userInfo:((id)userObject)];
		return;
	}
	NSMutableDictionary * newInfo = [[NSMutableDictionary allocWithZone:nil] initWithCapacity:3];
	if (newInfo) {
		if (aName) {
			[newInfo setObject:aName forKey:_kSWWTBNSNotificationCenterProxyAdditionNotificationNameKey];
		}
		if (anObject) {
			[newInfo setObject:anObject forKey:_kSWWTBNSNotificationCenterProxyAdditionNotificationObjectKey];
		}
		if (userObject) {
			[newInfo setObject:((id)userObject) forKey:_kSWWTBNSNotificationCenterProxyAdditionNotificationUserInfoKey];
		}
		[newInfo autorelease];
	}
	[self performSelectorOnMainThread:@selector(proxyPostNotificationWithInfo:) withObject:newInfo waitUntilDone:shouldWaitUntilDone];
}

@end

@implementation NSNotificationCenter (SWWTBNSNotificationCenterTollFreeAddition)

- (void)postNotificationName:(NSString *)notificationName object:(id)notificationSender userObject:(id)userObject forceAsync:(BOOL)forceAsync
{
	if (forceAsync) {
		if ([NSThread isMainThread]) {
			NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
			[self performSelectorInBackground:@selector(proxyPostNotification:) withObject:[NSNotification notificationWithName:notificationName object:notificationSender userInfo:((id)userObject)]];
			[pool drain];
			return;
		}
	}
	[self postNotificationName:notificationName object:notificationSender userInfo:((id)userObject)];
}

- (void)postNotificationName:(NSString *)notificationName object:(id)notificationSender userObject:(id)userObject
{
	[self postNotificationName:notificationName object:notificationSender userObject:userObject forceAsync:YES];
}

@end

/* EOF */