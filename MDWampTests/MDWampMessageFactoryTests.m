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

@end

@implementation MDWampMessageFactoryTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (Class)v2Class:(NSNumber*)code
{
    return [MDWampMessageFactory messageClassFromCode:code forVersion:kMDWampVersion2];
}

- (Class)v1Class:(NSNumber*)code
{
    return [MDWampMessageFactory messageClassFromCode:code forVersion:kMDWampVersion1];
}

- (void)testVersion1Messages
{
    /*
     WELCOME        0	Server-to-client	Auxiliary
     PREFIX         1	Client-to-server	Auxiliary
     CALL           2	Client-to-server	RPC
     CALLRESULT     3	Server-to-client	RPC
     CALLERROR      4	Server-to-client	RPC
     SUBSCRIBE      5	Client-to-server	PubSub
     UNSUBSCRIBE	6	Client-to-server	PubSub
     PUBLISH        7	Client-to-server	PubSub
     EVENT          8	Server-to-client	PubSub
     */
    XCTAssert([[self v1Class:@0] isSubclassOfClass:[MDWampWelcome class]], @"0 is Welcome");
    
    XCTAssert([[self v1Class:@2] isSubclassOfClass:[MDWampCall class]], @"2 is call");
    XCTAssert([[self v1Class:@3] isSubclassOfClass:[MDWampResult class]], @"3 is call result");
    XCTAssert([[self v1Class:@4] isSubclassOfClass:[MDWampError class]], @"4 is  call error");
    XCTAssert([[self v1Class:@5] isSubclassOfClass:[MDWampSubscribe class]], @"5 is Subscribe");
    XCTAssert([[self v1Class:@6] isSubclassOfClass:[MDWampUnsubscribe class]], @"6 is unsubscribe");
    XCTAssert([[self v1Class:@7] isSubclassOfClass:[MDWampPublish class]], @"7 is publish");

    
    XCTAssert([[self v1Class:@8] isSubclassOfClass:[MDWampEvent class]], @"8 is event");
}

- (void)testVersion2Messages
{
    
    XCTAssertThrows([self v2Class:@0], @"zero code in version 2 doesn't exist");
    XCTAssert([[self v2Class:@1] isSubclassOfClass:[MDWampHello class]], @"1 is Hello");
    XCTAssert([[self v2Class:@2] isSubclassOfClass:[MDWampWelcome class]], @"2 is Welcome");
    XCTAssert([[self v2Class:@3] isSubclassOfClass:[MDWampAbort class]], @"3 is Abort");
    XCTAssert([[self v2Class:@6] isSubclassOfClass:[MDWampGoodbye class]], @"6 is Goodbye");
    XCTAssert([[self v2Class:@8] isSubclassOfClass:[MDWampError class]], @"8 is Error");

    XCTAssert([[self v2Class:@16] isSubclassOfClass:[MDWampPublish class]], @"16 is Publish");
    XCTAssert([[self v2Class:@17] isSubclassOfClass:[MDWampPublished class]], @"16 is Publish");

    
    XCTAssert([[self v2Class:@32] isSubclassOfClass:[MDWampSubscribe class]], @"32 is Subscribe");
    XCTAssert([[self v2Class:@33] isSubclassOfClass:[MDWampSubscribed class]], @"33 is Subscribed");
    XCTAssert([[self v2Class:@34] isSubclassOfClass:[MDWampUnsubscribe class]], @"34 is Subscribe");
    XCTAssert([[self v2Class:@35] isSubclassOfClass:[MDWampUnsubscribed class]], @"35 is Subscribed");
    XCTAssert([[self v2Class:@36] isSubclassOfClass:[MDWampEvent class]], @"36 is Event");
    
    XCTAssert([[self v2Class:@48] isSubclassOfClass:[MDWampCall class]], @"48 is call");
    // Cancel
    XCTAssert([[self v2Class:@50] isSubclassOfClass:[MDWampResult class]], @"50 is Result");
    /*
     64	REGISTER						Rx	Tx
     65	REGISTERED						Tx	Rx
     66	UNREGISTER						Rx	Tx
     67	UNREGISTERED						Tx	Rx
     68	INVOCATION						Tx	Rx
     69	INTERRUPT	advanced					Tx	Rx
     70	YIELD
     */
    XCTAssert([[self v2Class:@64] isSubclassOfClass:[MDWampRegister class]], @"64 is register");
    XCTAssert([[self v2Class:@65] isSubclassOfClass:[MDWampRegistered class]], @"65 is registered");
    XCTAssert([[self v2Class:@66] isSubclassOfClass:[MDWampUnregister class]], @"66 is unregister");
    XCTAssert([[self v2Class:@67] isSubclassOfClass:[MDWampUnregistered class]], @"67 is unregistered");
    XCTAssert([[self v2Class:@68] isSubclassOfClass:[MDWampInvocation class]], @"68 is invocation");
    XCTAssert([[self v2Class:@70] isSubclassOfClass:[MDWampYield class]], @"70 is Yield");
}

@end
