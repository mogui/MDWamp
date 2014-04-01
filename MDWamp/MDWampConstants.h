//
//  MDWampConstants.h
//  MDWamp
//
//  Created by Niko Usai on 01/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#ifndef MDWamp_MDWampConstants_h
#define MDWamp_MDWampConstants_h

#import "NSMutableArray+MDStack.h"
#import "NSString+MDString.h"

#ifdef DEBUG
#define MDWampDebugLog(fmt, ...) NSLog((@"%s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__);
#else
#define MDWampDebugLog(fmt, ...)
#endif


// Supported Serialization
typedef enum {
    kMDWampSerializationJSON    = 1,
    kMDWampSerializationMsgPack
} MDWampSerialization;

// Supported Versions
typedef enum {
    kMDWampVersion1 = 1,
    kMDWampVersion2 = 2
} MDWampVersion;

// latest version supported
#define	kMDWampCurrentVersion MDWampVersion2

// NSError domain
#define kMDWampErrorDomain @"it.mogui.MDWamp"


#endif
