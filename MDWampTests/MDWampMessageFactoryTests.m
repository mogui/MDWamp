//
//  MDWampMessageFactoryTests.m
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

#import <XCTest/XCTest.h>
#import "MDWampMessageFactory.h"
#import "MDWampMessages.h"
@interface MDWampMessageFactoryTests : XCTestCase
{
    MDWampMessageFactory *factory;
}
@end

@implementation MDWampMessageFactoryTests

- (void)setUp
{
    [super setUp];
    factory = [MDWampMessageFactory sharedFactory];
}

- (void)testObjectFromCode {
    XCTAssert([[[factory objectFromCode:@1 withPayload:nil] class] isSubclassOfClass:[MDWampHello class]], @"@1 is Hello");
    XCTAssert([[[factory objectFromCode:@2 withPayload:nil] class] isSubclassOfClass:[MDWampWelcome class]], @"2 is Welcome");
    XCTAssert([[[factory objectFromCode:@3 withPayload:nil] class] isSubclassOfClass:[MDWampAbort class]], @"3 is Abort");
    XCTAssert([[[factory objectFromCode:@4 withPayload:nil] class] isSubclassOfClass:[MDWampChallenge class]], @"4 is Challange");
    XCTAssert([[[factory objectFromCode:@5 withPayload:nil] class] isSubclassOfClass:[MDWampAuthenticate class]], @"5 is authemticate");

    XCTAssert([[[factory objectFromCode:@6 withPayload:nil] class] isSubclassOfClass:[MDWampGoodbye class]], @"6 is Goodbye");
    XCTAssert([[[factory objectFromCode:@8 withPayload:nil] class] isSubclassOfClass:[MDWampError class]], @"8 is Error");

    XCTAssert([[[factory objectFromCode:@16 withPayload:nil] class] isSubclassOfClass:[MDWampPublish class]], @"16 is Publish");
    XCTAssert([[[factory objectFromCode:@17 withPayload:nil] class] isSubclassOfClass:[MDWampPublished class]], @"16 is Publish");


    XCTAssert([[[factory objectFromCode:@32 withPayload:nil] class] isSubclassOfClass:[MDWampSubscribe class]], @"32 is Subscribe");
    XCTAssert([[[factory objectFromCode:@33 withPayload:nil] class] isSubclassOfClass:[MDWampSubscribed class]], @"33 is Subscribed");
    XCTAssert([[[factory objectFromCode:@34 withPayload:nil] class] isSubclassOfClass:[MDWampUnsubscribe class]], @"34 is Subscribe");
    XCTAssert([[[factory objectFromCode:@35 withPayload:nil] class] isSubclassOfClass:[MDWampUnsubscribed class]], @"35 is Subscribed");
    XCTAssert([[[factory objectFromCode:@36 withPayload:nil] class] isSubclassOfClass:[MDWampEvent class]], @"36 is Event");

    XCTAssert([[[factory objectFromCode:@48 withPayload:nil] class] isSubclassOfClass:[MDWampCall class]], @"48 is call");
    XCTAssert([[[factory objectFromCode:@49 withPayload:nil] class] isSubclassOfClass:[MDWampCancel class]], @"49 is cancel");
    XCTAssert([[[factory objectFromCode:@50 withPayload:nil] class] isSubclassOfClass:[MDWampResult class]], @"50 is Result");

    XCTAssert([[[factory objectFromCode:@64 withPayload:nil] class] isSubclassOfClass:[MDWampRegister class]], @"64 is register");
    XCTAssert([[[factory objectFromCode:@65 withPayload:nil] class] isSubclassOfClass:[MDWampRegistered class]], @"65 is registered");
    XCTAssert([[[factory objectFromCode:@66 withPayload:nil] class] isSubclassOfClass:[MDWampUnregister class]], @"66 is unregister");
    XCTAssert([[[factory objectFromCode:@67 withPayload:nil] class] isSubclassOfClass:[MDWampUnregistered class]], @"67 is unregistered");
    XCTAssert([[[factory objectFromCode:@68 withPayload:nil] class] isSubclassOfClass:[MDWampInvocation class]], @"68 is invocation");
    // 69 kMDWampInterrupt
    XCTAssert([[[factory objectFromCode:@69 withPayload:nil] class] isSubclassOfClass:[MDWampInterrupt class]], @"69 is interrupt");
    XCTAssert([[[factory objectFromCode:@70 withPayload:nil] class] isSubclassOfClass:[MDWampYield class]], @"70 is Yield");
}

#define nameFromCodeMacro(code, name) \
    XCTAssert([[factory nameFromCode:code] isEqual:name], @"code: %@ must be: %@", code, name);

- (void)testNameFromCode {
    nameFromCodeMacro(@1 , kMDWampHello);
    nameFromCodeMacro(@2 , kMDWampWelcome);
    nameFromCodeMacro(@3 , kMDWampAbort);
    nameFromCodeMacro(@4 , kMDWampChallenge);
    nameFromCodeMacro(@5 , kMDWampAuthenticate);
    nameFromCodeMacro(@6 , kMDWampGoodbye);
    nameFromCodeMacro(@8 , kMDWampError);
    nameFromCodeMacro(@16, kMDWampPublish);
    nameFromCodeMacro(@17, kMDWampPublished);
    nameFromCodeMacro(@32, kMDWampSubscribe);
    nameFromCodeMacro(@33, kMDWampSubscribed);
    nameFromCodeMacro(@34, kMDWampUnsubscribe);
    nameFromCodeMacro(@35, kMDWampUnsubscribed);
    nameFromCodeMacro(@36, kMDWampEvent);
    nameFromCodeMacro(@48, kMDWampCall);
    nameFromCodeMacro(@49, kMDWampCancel);
    nameFromCodeMacro(@50, kMDWampResult);
    nameFromCodeMacro(@64, kMDWampRegister);
    nameFromCodeMacro(@65, kMDWampRegistered);
    nameFromCodeMacro(@66, kMDWampUnregister);
    nameFromCodeMacro(@67, kMDWampUnregistered);
    nameFromCodeMacro(@68, kMDWampInvocation);
    nameFromCodeMacro(@69, kMDWampInterrupt);
    nameFromCodeMacro(@70, kMDWampYield);
}
#define codeFromObjectMacro(c, CLASS) \
obj = [[CLASS alloc] init]; \
code = [factory codeFromObject:obj]; \
XCTAssert([code isEqual:c],@""#CLASS @" must be code %@", c); \

- (void)testCodeFromObject {
    id<MDWampMessage> obj;
    NSNumber *code;
    codeFromObjectMacro(@1 , MDWampHello);
    codeFromObjectMacro(@2 , MDWampWelcome);
    codeFromObjectMacro(@3 , MDWampAbort);
//    codeFromObjectMacro(@4 , MDWampChallange);
//    codeFromObjectMacro(@5 , MDWampAuthenticate);
    codeFromObjectMacro(@6 , MDWampGoodbye);
    codeFromObjectMacro(@8 , MDWampError);
    codeFromObjectMacro(@16, MDWampPublish);
    codeFromObjectMacro(@17, MDWampPublished);
    codeFromObjectMacro(@32, MDWampSubscribe);
    codeFromObjectMacro(@33, MDWampSubscribed);
    codeFromObjectMacro(@34, MDWampUnsubscribe);
    codeFromObjectMacro(@35, MDWampUnsubscribed);
    codeFromObjectMacro(@36, MDWampEvent);
    codeFromObjectMacro(@48, MDWampCall);
//    codeFromObjectMacro(@49, MDWampCancel);
    codeFromObjectMacro(@50, MDWampResult);
    codeFromObjectMacro(@64, MDWampRegister);
    codeFromObjectMacro(@65, MDWampRegistered);
    codeFromObjectMacro(@66, MDWampUnregister);
    codeFromObjectMacro(@67, MDWampUnregistered);
    codeFromObjectMacro(@68, MDWampInvocation);
//    codeFromObjectMacro(@69, MDWampInterrupt);
    codeFromObjectMacro(@70, MDWampYield );}



@end
