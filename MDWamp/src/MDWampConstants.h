//
//  MDWampConstants.h
//  MDWamp
//
//  Created by Niko Usai on 08/07/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray+MDStack.h"
#import "NSString+MDString.h"

// Debug Boilerplate
#ifdef DEBUG
#define MDWampDebugLog(fmt, ...) NSLog((@"%s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__);
#else
#define MDWampDebugLog(fmt, ...)
#endif

// Serialization Classes
FOUNDATION_EXPORT NSString *const kMDWampSerializationMsgpack;
FOUNDATION_EXPORT NSString *const kMDWampSerializationJSON;

// NSError domain
FOUNDATION_EXPORT NSString *const kMDWampErrorDomain;

