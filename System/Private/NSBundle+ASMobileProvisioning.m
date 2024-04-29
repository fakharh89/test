//
//  UIApplication+ASMobileProvisioning.m
//  Pods
//
//  Created by Michael Gordon on 11/17/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "NSBundle+ASMobileProvisioning.h"

#import "ASLog.h"

@implementation NSBundle (ASMobileProvisioning)

- (ASAPSEnvironment)as_APSEnvironment {
    NSString *embeddedMobileProvisionFilePath = [self pathForResource:@"embedded" ofType:@"mobileprovision"];
    BOOL usingMobileProvisioningFile = (embeddedMobileProvisionFilePath != nil);
    
    NSString *appStoreReceiptLastComponent = self.appStoreReceiptURL.lastPathComponent;
    BOOL usingSandboxReceipt = [@"sandboxReceipt" compare:appStoreReceiptLastComponent] == NSOrderedSame;
    
    if (!usingMobileProvisioningFile) {
        if (usingSandboxReceipt) {
            ASLog(@"Using Testflight");
            return ASAPSEnvironmentProduction;
        }
        else {
            ASLog(@"On app store");
            return ASAPSEnvironmentProduction;
        }
    }
    
    // Parse as binary string since the start and end of the embedded.mobileprovision file has binary data
    // NSISOLatin1StringEncoding ignores the binary data
    NSString *binaryString = [NSString stringWithContentsOfFile:embeddedMobileProvisionFilePath encoding:NSISOLatin1StringEncoding error:nil];
    
    if (!binaryString) {
        ASLog(@"Couldn't read embedded.mobileprovision");
        return ASAPSEnvironmentUnknown;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:binaryString];
    NSString *binaryPropertyListString;
    
    if (![scanner scanUpToString:@"<plist" intoString:nil]) {
        ASLog(@"Couldn't find start of plist in embedded.mobileprovision");
        return ASAPSEnvironmentUnknown;
    }
    
    if (![scanner scanUpToString:@"</plist>" intoString:&binaryPropertyListString]) {
        ASLog(@"Couldn't find end of plist in embedded.mobileprovision");
        return ASAPSEnvironmentUnknown;
    }
    
    binaryPropertyListString = [NSString stringWithFormat:@"%@</plist>", binaryPropertyListString];
    
    // Now that we have the correct string, undo the conversion to NSISOLatin1StringEncoding
    NSData *binaryPropertyListData = [binaryPropertyListString dataUsingEncoding:NSISOLatin1StringEncoding];
    
    if (!binaryPropertyListData) {
        ASLog(@"Couldn't convert binary plist string back to binary data");
        return ASAPSEnvironmentUnknown;
    }
    
    NSError *error = nil;
    NSDictionary* mobileProvision = [NSPropertyListSerialization propertyListWithData:binaryPropertyListData options:NSPropertyListImmutable format:NULL error:&error];
    
    if (!mobileProvision) {
        ASLog(@"Couldn't parse plist string: %@", error);
        return ASAPSEnvironmentUnknown;
    }
    
    NSDictionary *entitlementsDictionary = mobileProvision[@"Entitlements"];
    
    if (!entitlementsDictionary) {
        ASLog(@"Couldn't find \"Entitilements\" dictionary");
        return ASAPSEnvironmentUnknown;
    }
    
    NSString *apsEnvironment = entitlementsDictionary[@"aps-environment"];
    
    if (!apsEnvironment) {
        ASLog(@"Couldn't find \"aps-environment\" key in Entitlements dictionary");
        return ASAPSEnvironmentUnknown;
    }
    
    ASAPSEnvironment environment = ASAPSEnvironmentUnknown;
    
    if ([apsEnvironment caseInsensitiveCompare:@"development"] == NSOrderedSame) {
        environment = ASAPSEnvironmentDevelopment;
    }
    // This case probably never happens.  The embedded.mobileprovision file doesn't exist
    // on app store builds
    else if ([apsEnvironment caseInsensitiveCompare:@"production"] == NSOrderedSame) {
        environment = ASAPSEnvironmentProduction;
    }
    
    return environment;
}

@end
