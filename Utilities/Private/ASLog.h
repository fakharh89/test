//
//  ASLog.h
//  Blustream
//
//  Created by Michael Gordon on 2/15/15.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import <Foundation/Foundation.h>

void ASLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
void ASBLELog(NSString *message);
void ASLogMessage(NSString *message);

void deleteLog(void);
