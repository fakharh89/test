//
//  ASAppDelegateProxy.m
//  Pods
//
//  Created by Michael Gordon on 7/6/16.
//
//

#import "ASAppDelegateProxy.h"

#import <objc/runtime.h>

#import "ASConfig.h"
#import "ASLog.h"
#import "ASSystemManager.h"
#import "ASCloudPrivate.h"
#import "ASRemoteNotificationManager.h"
#import "ASOTAUCache.h"
#import "ASNotifications.h"

#import "SWWTB+NSNotificationCenter+Addition.h"

// Very helpful article: https://blog.newrelic.com/2014/04/16/right-way-to-swizzle/

@implementation ASAppDelegateProxy

+ (void)swizzleAppDelegate {
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    
    if (!appDelegate) {
        ASLog(@"App delegate not set, unable to perform automatic setup.");
        return;
    }
    
    Class class = [[UIApplication sharedApplication].delegate class];
    SEL selector = nil;
    
    if ([ASSystemManager shared].config.enableRemoteNotifications) {
        selector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
        originalApplicationDidRegisterForRemoteNotificationsWithDeviceToken = [self swizzleOrAddSelector:selector class:class newImplementation:(IMP)ASApplicationDidRegisterForRemoteNotificationsWithDeviceToken];
        
        selector = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
        originalApplicationDidFailToRegisterForRemoteNotificationsWithError = [self swizzleOrAddSelector:selector class:class newImplementation:(IMP)ASApplicationDidFailToRegisterForRemoteNotificationsWithError];
        
        selector = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
        originalApplicationDidReceiveRemoteNotificationFetchCompletionHandler = [self swizzleOrAddSelector:selector class:class newImplementation:(IMP)ASApplicationDidReceiveRemoteNotificationFetchCompletionHandler];
    }
    
    selector = @selector(application:openURL:options:);
    originalApplicationOpenURLOptions = [self swizzleOrAddSelector:selector class:class newImplementation:(IMP)ASApplicationOpenURLOptions];

    // Microsoft open source code to the rescue!
    // https://github.com/AzureAD/azure-activedirectory-library-for-objc/blob/66b18ab6831dd2ec09d941ef66ab872a867325de/ADAL/src/broker/ios/ADBrokerHelper.m
    
    // UIApplication apparently caches the delegate.  Reset it to fix calls not triggering after they are added
    // to the delegate.
    [UIApplication sharedApplication].delegate = nil;

    // UIApplication setDelegate doesn't retain objects.  We have to retain it manually to ensure it doesn't
    // become a zombie.
    // (__bridge CFTypeRef)appDelegate
    //      Cast the appDelegate to a generic Core Foundation type (CFTypeRef)
    // CFRetain()
    //      https://developer.apple.com/library/content/documentation/CoreFoundation/Conceptual/CFMemoryMgmt/Concepts/Ownership.html
    //      If you get an object from somewhere else, you do not own it. If you want to prevent it being disposed of, you must add yourself as an owner (using CFRetain).
    // (__bridge id)
    //      Cast it back to an Objective-C type

    [UIApplication sharedApplication].delegate = (__bridge id)CFRetain((__bridge CFTypeRef)appDelegate);
}

// Returns original implementation
+ (IMP)swizzleOrAddSelector:(SEL)selector class:(Class)class newImplementation:(IMP)implementation {
    Method method = class_getInstanceMethod(class, selector);
    if (method) {
        ASLog(@"Swizzling %@", NSStringFromSelector(selector));
        return method_setImplementation(method, implementation);
    }
    else {
        ASLog(@"Adding %@", NSStringFromSelector(selector));
        struct objc_method_description description = protocol_getMethodDescription(@protocol(UIApplicationDelegate), selector, NO, YES);
        if (!class_addMethod(class, selector, implementation, description.types)) {
            ASLog(@"Failed to add method!");
        }
        return nil;
    }
}

static IMP originalApplicationDidRegisterForRemoteNotificationsWithDeviceToken;
void ASApplicationDidRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, UIApplication *application, NSData *deviceToken) {
    [ASSystemManager.shared.cloud.remoteNotificationManager didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    if (originalApplicationDidRegisterForRemoteNotificationsWithDeviceToken) {
        ((void(*)(id, SEL, UIApplication *, NSData *))originalApplicationDidRegisterForRemoteNotificationsWithDeviceToken)(self, _cmd, application, deviceToken);
    }
}

static IMP originalApplicationDidFailToRegisterForRemoteNotificationsWithError;
void ASApplicationDidFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication *application, NSError *error) {
    ASLog(@"Failed to register for remote notifications: %@", error);
    
    if (originalApplicationDidFailToRegisterForRemoteNotificationsWithError) {
        ((void(*)(id, SEL, UIApplication *, NSError *))originalApplicationDidFailToRegisterForRemoteNotificationsWithError)(self, _cmd, application, error);
    }
}

static IMP originalApplicationDidReceiveRemoteNotificationFetchCompletionHandler;
void ASApplicationDidReceiveRemoteNotificationFetchCompletionHandler(id self, SEL _cmd, UIApplication *application, NSDictionary *userInfo, void (^completionHandler)(UIBackgroundFetchResult)) {
    if (originalApplicationDidReceiveRemoteNotificationFetchCompletionHandler) {
        ((void(*)(id, SEL, UIApplication *, NSDictionary *, void (^)(UIBackgroundFetchResult)))originalApplicationDidReceiveRemoteNotificationFetchCompletionHandler)(self, _cmd, application, userInfo, completionHandler);
    }
    else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

static IMP originalApplicationOpenURLOptions;
BOOL ASApplicationOpenURLOptions(id self, SEL _cmd, UIApplication *application, NSURL *url, NSDictionary<NSString *, id> *options) {
    if (url && [ASOTAUCache addMACAddressesAndKeysFromURL:url]) {
        ASLog(@"Added mac addresses and keys from url!");
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceOTAUAcceptedNotification object:nil userObject:nil];
        return YES;
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASURLRejectedNotification object:nil userObject:nil];
    }
    
    if (originalApplicationOpenURLOptions) {
        return ((BOOL(*)(id, SEL, UIApplication *, NSURL *, NSDictionary *))originalApplicationOpenURLOptions)(self, _cmd, application, url, options);
    }
    
    return NO;
}

static IMP originalApplicationHandleOpenURL;
BOOL ASApplicationHandleOpenURL(id self, SEL _cmd, UIApplication *application, NSURL *url) {
    if (url && [ASOTAUCache addMACAddressesAndKeysFromURL:url]) {
        ASLog(@"Added mac addresses and keys from url!");
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceOTAUAcceptedNotification object:nil userObject:nil];
        return YES;
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASURLRejectedNotification object:nil userObject:nil];
    }
    
    if (originalApplicationOpenURLOptions) {
        return ((BOOL(*)(id, SEL, UIApplication *, NSURL *))originalApplicationHandleOpenURL)(self, _cmd, application, url);
    }
    
    return NO;
}

static IMP originalApplicationOpenURLSourceApplicationAnnotation;
BOOL ASApplicationOpenURLSourceApplicationAnnotation(id self, SEL _cmd, UIApplication *application, NSURL *url, NSString *sourceApplication, id annotation) {
    if (url && [ASOTAUCache addMACAddressesAndKeysFromURL:url]) {
        ASLog(@"Added mac addresses and keys from url!");
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASDeviceOTAUAcceptedNotification object:nil userObject:nil];
        return YES;
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:ASURLRejectedNotification object:nil userObject:nil];
    }
    
    if (originalApplicationOpenURLSourceApplicationAnnotation) {
        return ((BOOL(*)(id, SEL, UIApplication *, NSURL *, NSString *, id))originalApplicationOpenURLSourceApplicationAnnotation)(self, _cmd, application, url, sourceApplication, annotation);
    }
    
    return NO;
}

@end
