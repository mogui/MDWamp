//
//  MDWampConstants.h
//  MDWamp
//
//  Created by Niko Usai on 01/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
