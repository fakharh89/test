//
//  ASResourceManager.m
//  Pods
//
//  Created by Michael Gordon on 11/3/16.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASResourceManager.h"

#import "ASLog.h"

@implementation ASResourceManager

- (id)initWithResourceName:(NSString *)name {
    NSParameterAssert(name);
    
    self = [super init];
    if (self) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:name ofType:@"bundle"];
        _bundle = [NSBundle bundleWithPath:bundlePath];
        
        if (_bundle) {
            NSError *error = nil;
            _CSKeyDatabase = [self loadJSONFromPath:[self.bundle pathForResource:@"cskey_db" ofType:@"json"] error:&error];
            
            if (!self.CSKeyDatabase) {
                ASLog(@"Error loading OTAU CS key database!: %@", error);
            }
            
            error = nil;
            
            _OTAUImageDatabase = [self loadJSONFromPath:[self.bundle pathForResource:@"otau" ofType:@"json"] error:&error];
            
            if (!self.OTAUImageDatabase) {
                ASLog(@"Error loading OTAU image database!: %@", error);
            }
            
            [self loadImages];
        }
    }
    return self;
}

- (NSDictionary *)loadJSONFromPath:(NSString *)path error:(NSError * __autoreleasing *)error {
    NSData *JSONData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:error];
    if (!JSONData) {
        return nil;
    }
    
    return [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:error];
}

- (void)loadImages {
    NSString * documentsPath = [[self.bundle bundlePath] stringByAppendingPathComponent:@"Images"];
    
    NSError * error;
    NSArray<NSString *> *images = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
    _imagePaths = [documentsPath stringsByAppendingPaths:images];
    
    if (!self.imagePaths) {
        ASLog(@"Error loading OTAU images!: %@", error);
    }
}

@end
