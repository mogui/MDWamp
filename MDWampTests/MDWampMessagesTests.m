//
//  MDWampMessagesTests.m
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
#import "MDWampConstants.h"
#import "MDWampMessages.h"


#define makeMessage(mdclass, pay) self.payload = pay; \
mdclass *msg = [[mdclass alloc] initWithPayload:self.payload];


#define testMarshall2(cc) \
XCTAssertNotNil(msg, @"Message Must not be nil"); \
[self checkMarshalling:msg code:cc];

#define msgIntegrity(property, value) XCTAssertEqualObjects(property, self.payload[value], @"Checking Message integrity: %s must be %@", #property, self.payload[value]);


@interface MDWampMessagesTests : XCTestCase
@property (strong) NSArray *payload;
@end

@implementation MDWampMessagesTests

- (void)setUp
{
    [super setUp];
    self.payload = nil;
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void) checkMarshalling:(id<MDWampMessage>)msg code:(NSNumber *)code
{
    // Marshalling
    if (code != nil) {
        NSMutableArray *marshalled = [[msg marshall] mutableCopy];
        XCTAssertEqualObjects(code, [marshalled shift], @"Code is wrong");
        
        // equality
        XCTAssertEqualObjects(self.payload, marshalled, @"Marshalled Message should be equal to payload");
    } else {
        XCTAssertThrows([msg marshall], @"Version 2 of protocol not supproted");
    }
}

- (void)testHello
{
    self.payload = @[@"somerealm", @{@"roles": @{@"publisher":@{}}}];
    
    // Integrity
    MDWampHello *hello = [[MDWampHello alloc] initWithPayload:_payload];
    XCTAssertNotNil(hello, @"Message Must not be nil");
    XCTAssertNotNil([hello.roles objectForKey:@"publisher"], @"Checking Message integrity");
    XCTAssertEqualObjects(hello.realm, _payload[0], @"Checking Message integrity");
    
    [self checkMarshalling:hello code:@1];
}

- (void)testWelcome
{
    self.payload = @[@21233872738, @{@"roles": @{@"broker":@{}}}];
    
    MDWampWelcome *msg = [[MDWampWelcome alloc] initWithPayload:_payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertNotNil([msg.roles objectForKey:@"broker"], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.session, _payload[0], @"Checking Message integrity");
    [self checkMarshalling:msg code:@2];
    
}

- (void)testAbort
{
    self.payload = @[@{@"message": @"The realm does not exist."}, @"wamp.error.no_such_realm"];
    
    MDWampAbort *msg = [[MDWampAbort alloc] initWithPayload:_payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertNotNil([msg.details objectForKey:@"message"], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.reason, _payload[1], @"Checking Message integrity");
    
    [self checkMarshalling:msg code:@3];
}

- (void)testChallangeCode
{
    makeMessage(MDWampChallenge, (@[@"simple", @{}]) );
    testMarshall2(@4);
    msgIntegrity(msg.authMethod, 0)
    msgIntegrity(msg.extra, 1)
}

- (void)testAuthenticateCode
{
    makeMessage(MDWampAuthenticate, (@[@"76YASTFDa8s7das8d6", @{}]) );
    testMarshall2(@5);
    msgIntegrity(msg.signature, 0)
    msgIntegrity(msg.extra, 1)
}

- (void)testGoodbye
{
    self.payload = @[@{@"message": @"The host is shutting down now."}, @"wamp.error.system_shutdown"];
    
    MDWampGoodbye *msg = [[MDWampGoodbye alloc] initWithPayload:_payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertNotNil([msg.details objectForKey:@"message"], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.reason, _payload[1], @"Checking Message integrity");
    
    [self checkMarshalling:msg code:@6];}



- (void)testError {
    self.payload = @[@48, @123456789, @{}, @"com.myapp.error.object_write_protected", @[@"Object is write protected"], @{@"severity": @3}];
    MDWampError *msg2 = [[MDWampError alloc] initWithPayload:self.payload];
    XCTAssertEqualObjects(msg2.error, _payload[3], @"Checking Message integrity");
    XCTAssertEqualObjects(msg2.type, _payload[0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg2.request, _payload[1], @"Checking Message integrity");
    XCTAssertEqualObjects(msg2.arguments[0], _payload[4][0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg2.argumentsKw[@"severity"], _payload[5][@"severity"], @"Checking Message integrity");
    
    [self checkMarshalling:msg2 code:@8];
}

- (void) testSubscribe {
    self.payload = @[@713845233, @{}, @"com.myapp.mytopic1"];
    // [32, 713845233, {}, "com.myapp.mytopic1"]
    MDWampSubscribe *msg2 = [[MDWampSubscribe alloc] initWithPayload:self.payload];
    XCTAssertNotNil(msg2, @"Message Must not be nil");
    XCTAssertEqualObjects(msg2.topic, _payload[2], @"Checking Message integrity");
    [self checkMarshalling:msg2 code:@32];
}

- (void) testSubscribed
{
    self.payload = @[@713845233, @5512315355];
    // [33, 713845233, 5512315355]
    MDWampSubscribed *msg2 = [[MDWampSubscribed alloc] initWithPayload:self.payload];
    XCTAssertNotNil(msg2, @"Message Must not be nil");
    XCTAssertEqualObjects(msg2.request, _payload[0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg2.subscription, _payload[1], @"Checking Message integrity");
    [self checkMarshalling:msg2 code:@33];
}

- (void) testUnsubscribe
{
    self.payload = @[@713845233, @5512315355];
    
    MDWampUnsubscribe *msg = [[MDWampUnsubscribe alloc] initWithPayload:self.payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertEqualObjects(msg.request, _payload[0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.subscription, _payload[1], @"Checking Message integrity");
    [self checkMarshalling:msg code:@34];
}

- (void) testUnsubscribed
{
    self.payload = @[@713845233];
    MDWampUnsubscribed *msg2 = [[MDWampUnsubscribed alloc] initWithPayload:self.payload];
    XCTAssertNotNil(msg2, @"Message Must not be nil");
    XCTAssertEqualObjects(msg2.request, _payload[0], @"Checking Message integrity");
    [self checkMarshalling:msg2 code:@35];
}

- (void) testPublish {
    // [16, 239714735, {}, "com.myapp.mytopic1", [], {"color": "orange", "sizes": [23, 42, 7]}]
    self.payload = @[@713845233, @{}, @"com.myapp.mytopic1", @[], @{@"color":@"orange", @"sizes":@[@23, @42]} ];
    
    MDWampPublish *msg = [[MDWampPublish alloc] initWithPayload:self.payload];
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertEqualObjects(msg.request, _payload[0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.topic, _payload[2], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.argumentsKw[@"color"], @"orange", @"Checking Message integrity");
    [self checkMarshalling:msg code:@16];
}

- (void) testPublished
{
    self.payload = @[@713845233, @34554];
    MDWampPublished *msg = [[MDWampPublished alloc] initWithPayload:self.payload];
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertEqualObjects(msg.request, _payload[0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.publication, _payload[1], @"Checking Message integrity");
    [self checkMarshalling:msg code:@17];
}

- (void) testEvent {
    // [36, 5512315355, 4429313566, {}, [], {"color": "orange", "sizes": [23, 42, 7]}]
    makeMessage(MDWampEvent, ( @[@5512315355,@4429313566,@{},@[],@{@"color": @"orange",@"sizes": @[@23,@42,@7]}]));

    testMarshall2(@36);
    
    msgIntegrity(msg.subscription , 0);
    msgIntegrity(msg.publication  , 1);
    msgIntegrity(msg.event        , 4);
}


- (void) testRegister {
    //    [64, 25349185, {}, "com.myapp.myprocedure1"]
    makeMessage(MDWampRegister, (@[@25349185, @{}, @"com.myapp.myprocedure1"]) );
    testMarshall2(@64);
    msgIntegrity(msg.request, 0)
    msgIntegrity(msg.options, 1)
    msgIntegrity(msg.procedure, 2)

}

- (void) testRegistered {
    makeMessage(MDWampRegistered, (@[@25349185, @2103333224]) );
    testMarshall2(@65);
    msgIntegrity(msg.request, 0);
    msgIntegrity(msg.registration, 1);
}

- (void) testUnregister {
    makeMessage(MDWampUnregister, (@[@25349185, @2103333224]) );
    testMarshall2(@66);
    msgIntegrity(msg.request, 0);
    msgIntegrity(msg.registration, 1);
}

- (void) testUnregistered {
    makeMessage(MDWampUnregistered, (@[@25349185]) );
    testMarshall2(@67);
    msgIntegrity(msg.request, 0);
}

- (void) testCall {
    makeMessage(MDWampCall, (@[@7814135, @{}, @"com.myapp.user.new", @[@"johnny"], @{@"firstname": @"John", @"surname": @"Doe"}]));
    testMarshall2(@48);
    msgIntegrity(msg.request, 0);
    msgIntegrity(msg.procedure, 2);
    msgIntegrity(msg.arguments, 3);
    msgIntegrity(msg.argumentsKw, 4);
}


- (void) testResult {
    makeMessage(MDWampResult, (@[@7814135, @{}, @[], @{@"userid": @123, @"karma": @10}]));
    testMarshall2(@50);
    msgIntegrity(msg.request, 0);
    msgIntegrity(msg.options, 1);
    msgIntegrity(msg.arguments, 2);
    msgIntegrity(msg.argumentsKw, 3);
}

- (void) testInvocation {
    makeMessage(MDWampInvocation, (@[ @6131533, @9823529, @{}, @[@"johnny"], @{@"firstname": @"John", @"surname": @"Doe"}]));
    testMarshall2(@68);
    msgIntegrity(msg.request, 0);
    msgIntegrity(msg.registration, 1);
    msgIntegrity(msg.arguments, 3);
    msgIntegrity(msg.argumentsKw, 4);
}

- (void) testYield {
    makeMessage(MDWampYield, ( @[@6131533, @{}, @[], @{@"userid": @123, @"karma": @10}] ));
    testMarshall2(@70);
    msgIntegrity(msg.request, 0);
    msgIntegrity(msg.options, 1);
    msgIntegrity(msg.arguments, 2);
    msgIntegrity(msg.argumentsKw, 3);
}

- (void) testCancel {
    makeMessage(MDWampCancel, (@[@123019283, @{}]) );
    testMarshall2(@49);
    msgIntegrity(msg.request, 0)
    msgIntegrity(msg.options, 1)
}

- (void) testInterrupt {
    makeMessage(MDWampInterrupt, (@[@123019283, @{}]) );
    testMarshall2(@69);
    msgIntegrity(msg.request, 0)
    msgIntegrity(msg.options, 1)
}
@end
