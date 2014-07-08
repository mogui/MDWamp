//
//  MDWampMessageFactory.h
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

#import <Foundation/Foundation.h>
#import "MDWampConstants.h"
#import "MDWampMessage.h"

#define kMDWampHello        @"MDWampHello"
#define kMDWampWelcome      @"MDWampWelcome"
#define kMDWampAbort        @"MDWampAbort"
#define kMDWampChallange    @"MDWampChallange"
#define kMDWampAuthenticate @"MDWampAuthenticate"
#define kMDWampGoodbye      @"MDWampGoodbye"
#define kMDWampHeartbeat    @"MDWampHeartbeat"
#define kMDWampError        @"MDWampError"
#define kMDWampPublish      @"MDWampPublish"
#define kMDWampPublished    @"MDWampPublished"
#define kMDWampSubscribe    @"MDWampSubscribe"
#define kMDWampSubscribed   @"MDWampSubscribed"
#define kMDWampUnsubscribe  @"MDWampUnsubscribe"
#define kMDWampUnsubscribed @"MDWampUnsubscribed"
#define kMDWampEvent        @"MDWampEvent"
#define kMDWampCall         @"MDWampCall"
#define kMDWampCancel       @"MDWampCancel"
#define kMDWampResult       @"MDWampResult"
#define kMDWampRegister     @"MDWampRegister"
#define kMDWampRegistered   @"MDWampRegistered"
#define kMDWampUnregister   @"MDWampUnregister"
#define kMDWampUnregistered @"MDWampUnregistered"
#define kMDWampInvocation   @"MDWampInvocation"
#define kMDWampInterrupt    @"MDWampInterrupt"
#define kMDWampYield        @"MDWampYield"

@interface MDWampMessageFactory : NSObject
+ (instancetype) sharedFactory;
- (id<MDWampMessage>)messageObjectFromCode:(NSNumber*)code withPayload:(NSArray*)payload;
- (NSString *)messageNameFromCode:(NSNumber*)code;
- (NSNumber *)messageCodeFromObject:(id)object;
@end
