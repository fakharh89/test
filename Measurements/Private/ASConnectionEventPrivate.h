//
//  ASConnectionEventPrivate.h
//  Pods
//
//  Created by Michael Gordon on 12/5/17.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//

#import "ASConnectionEvent.h"

@interface ASConnectionEvent ()

+ (ASConnectionEventType)typeForString:(NSString *)string;
+ (ASConnectionEventReason)reasonForString:(NSString *)string;

@end
