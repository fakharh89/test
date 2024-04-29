//
//  ASNotifications.m
//  Blustream
//
//  Created by Michael Gordon on 12/11/14.
//  Copyright © 2017 Blustream Corporation. All rights reserved.
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE', which is part of this source code package.
//

#import "ASNotifications.h"

NSString * const ASDeviceManagerStateChangedNotification         = @"com.acousticstream.devicemanager.statechanged";

NSString * const ASDeviceAdvertisedNotification                  = @"com.acousticstream.device.advertising";
NSString * const ASDeviceFoundNotification                       = @"com.acousticstream.device.advertising";
NSString * const ASDeviceConnectedNotification                   = @"com.acousticstream.device.connected";
NSString * const ASDeviceDisconnectedNotification                = @"com.acousticstream.device.disconnected";
NSString * const ASDeviceConnectFailedNotification               = @"com.acousticstream.device.connectfail";
NSString * const ASDeviceRegionStateDeterminedNotification       = @"com.acousticstream.device.regionstatedetermined";
NSString * const ASDeviceRSSIUpdatedNotification                 = @"com.acousticstream.device.rssiupdated";
NSString * const ASDeviceOTAUAcceptedNotification                = @"com.acousticstream.device.otau.accepted";
NSString * const ASDeviceSyncedNotification                      = @"com.acousticstream.device.synced";
NSString * const ASDeviceSyncedNoChangesNotification             = @"com.acousticstream.device.synced.nochange";

NSString * const ASContainerCharacteristicReadNotification       = @"com.acousticstream.container.characteristicread";
NSString * const ASContainerCharacteristicReadFailedNotification = @"com.acousticstream.container.characteristicreadfail";
NSString * const ASContainerSyncedNotification                   = @"com.acousticstream.container.synced";
NSString * const ASContainerImageSyncedNotification              = @"com.acousticstream.container.imageedited";
NSString * const ASContainerNoChangesNotification                = @"com.acousticstream.container.synced.nochange";
NSString * const ASContainerSyncedNoChangesNotification          = @"com.acousticstream.container.synced.nochange";
NSString * const ASContainerDataDownloadedFromDeviceNotification = @"com.acousticstream.container.data.downloaded";

NSString * const ASUserLoggedOutNotification                     = @"com.acousticstream.user.loggedout";
NSString * const ASUserSyncedNotification                        = @"com.acousticstream.user.synced";
NSString * const ASUserSyncedNoChangeNotification                = @"com.acousticstream.user.synced.nochange";
NSString * const ASUserImageSyncedNotification                   = @"com.acousticstream.user.imagesynced";

NSString * const ASURLRejectedNotification                       = @"com.acousticstream.url.rejected";
