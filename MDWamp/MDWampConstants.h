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
typedef NS_ENUM(int, MDWampSerializationClass) {
    kMDWampSerializationJSON    = 1,
    kMDWampSerializationMsgPack
};

// Supported Versions
typedef NSNumber* MDWampVersion;
#define  kMDWampVersion1         @10
#define  kMDWampVersion2         @20
#define  kMDWampVersion2JSON     @21
#define  kMDWampVersion2Msgpack  @22


// latest version supported
#define	kMDWampCurrentVersion MDWampVersion2


// NSError domain
#define kMDWampErrorDomain @"it.mogui.MDWamp"


#endif
