//
//  MDWampMessagesTests.m
//  MDWamp
//
//  Created by Niko Usai on 01/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDWampConstants.h"
#import "MDWampMessages.h"

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

- (void) checkMarshallingV1:(id<MDWampMessage>)msg code:(NSNumber *)code
{
    // Marshalling
    if (code != nil) {
        NSMutableArray *marshalled = [[msg marshallFor:kMDWampVersion1] mutableCopy];
        XCTAssertEqualObjects(code, [marshalled shift], @"Code is wrong");
        
        // equality
        XCTAssertEqualObjects(self.payload, marshalled, @"Marshalled Message should be equal to payload");
    } else {
        XCTAssertThrows([msg marshallFor:kMDWampVersion1], @"Version 1 of protocol not supproted");
    }
}

- (void) checkMarshallingV2:(id<MDWampMessage>)msg code:(NSNumber *)code
{
    // Marshalling
    if (code != nil) {
        NSMutableArray *marshalled = [[msg marshallFor:kMDWampVersion2] mutableCopy];
        XCTAssertEqualObjects(code, [marshalled shift], @"Code is wrong");
        
        // equality
        XCTAssertEqualObjects(self.payload, marshalled, @"Marshalled Message should be equal to payload");
    } else {
        XCTAssertThrows([msg marshallFor:kMDWampVersion1], @"Version 2 of protocol not supproted");
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
    
    [self checkMarshallingV1:hello code:nil];
    [self checkMarshallingV2:hello code:@1];
}

- (void)testWelcome
{
    self.payload = @[@21233872738, @{@"roles": @{@"broker":@{}}}];
    
    MDWampWelcome *msg = [[MDWampWelcome alloc] initWithPayload:_payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertNotNil([msg.roles objectForKey:@"broker"], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.session, _payload[0], @"Checking Message integrity");
    [self checkMarshallingV2:msg code:@2];
    
    self.payload = @[@21233872738, @1, @"Autobahn/0.5.1"];
    MDWampWelcome *msg2 = [[MDWampWelcome alloc] initWithPayload:self.payload];
    [self checkMarshallingV1:msg2 code:@0];
    
}

- (void)testAbort
{
    self.payload = @[@{@"message": @"The realm does not exist."}, @"wamp.error.no_such_realm"];
    
    MDWampAbort *msg = [[MDWampAbort alloc] initWithPayload:_payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertNotNil([msg.details objectForKey:@"message"], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.reason, _payload[1], @"Checking Message integrity");
    
    [self checkMarshallingV1:msg code:nil];
    [self checkMarshallingV2:msg code:@3];
}

- (void)testChallangeCode
{
    self.payload = @[@4,  @{@"message": @"The realm does not exist."}, @"wamp.error.no_such_realm"];
}

- (void)testAuthenticateCode
{
    self.payload = @[@5,  @{@"message": @"The realm does not exist."}, @"wamp.error.no_such_realm"];
}

- (void)testGoodbye
{
    self.payload = @[@{@"message": @"The host is shutting down now."}, @"wamp.error.system_shutdown"];
    
    MDWampGoodbye *msg = [[MDWampGoodbye alloc] initWithPayload:_payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertNotNil([msg.details objectForKey:@"message"], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.reason, _payload[1], @"Checking Message integrity");
    
    [self checkMarshallingV1:msg code:nil];
    [self checkMarshallingV2:msg code:@6];}

- (void)testHeartbitCode
{
    self.payload = @[@7,  @{@"message": @"The realm does not exist."}, @"wamp.error.no_such_realm"];
}

- (void)testError
{
    // call Error version 1
    /*
     
     [4, "AStPd8RS60pfYP8c",
     "http://example.com/error#invalid_numbers",
     "one or more numbers are multiples of 3",
     [0, 3]]
     
     */
    self.payload = @[@"AStPd8RS60pfYP8c", @"http://example.com/error#invalid_numbers", @"one or more numbers are multiples of 3", @[@0, @3]];
    
    MDWampError *msg = [[MDWampError alloc] initWithPayload:_payload];
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertEqualObjects(msg.callID, _payload[0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.error, _payload[1], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.errorDesc, _payload[2], @"Checking Message integrity");
    [self checkMarshallingV1:msg code:@4];
    
    // call error version 2
    self.payload = @[@48, @123456789, @{}, @"com.myapp.error.object_write_protected", @[@"Object is write protected"], @{@"severity": @3}];
    MDWampError *msg2 = [[MDWampError alloc] initWithPayload:self.payload];
    XCTAssertEqualObjects(msg2.error, _payload[3], @"Checking Message integrity");
    XCTAssertEqualObjects(msg2.type, _payload[0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg2.request, _payload[1], @"Checking Message integrity");
    XCTAssertEqualObjects(msg2.arguments[0], _payload[4][0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg2.argumentsKw[@"severity"], _payload[5][@"severity"], @"Checking Message integrity");
    
    [self checkMarshallingV2:msg2 code:@8];

}

- (void) testSubscribe
{
    self.payload = @[@"http://example.com/simple"];
    // [5, "http://example.com/simple"]
    
    MDWampSubscribe *msg = [[MDWampSubscribe alloc] initWithPayload:self.payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertEqualObjects(msg.topic, _payload[0], @"Checking Message integrity");
    [self checkMarshallingV1:msg code:@5];
    
    self.payload = @[@713845233, @{}, @"com.myapp.mytopic1"];
    // [32, 713845233, {}, "com.myapp.mytopic1"]
    MDWampSubscribe *msg2 = [[MDWampSubscribe alloc] initWithPayload:self.payload];
    XCTAssertNotNil(msg2, @"Message Must not be nil");
    XCTAssertEqualObjects(msg2.topic, _payload[2], @"Checking Message integrity");
    [self checkMarshallingV2:msg2 code:@32];
}

- (void) testSubscribed
{
    self.payload = @[@713845233, @5512315355];
    // [33, 713845233, 5512315355]
    MDWampSubscribed *msg2 = [[MDWampSubscribed alloc] initWithPayload:self.payload];
    XCTAssertNotNil(msg2, @"Message Must not be nil");
    XCTAssertEqualObjects(msg2.request, _payload[0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg2.subscription, _payload[1], @"Checking Message integrity");
    [self checkMarshallingV2:msg2 code:@33];
}

- (void) testUnsubscribe
{
    self.payload = @[@713845233, @5512315355];
    
    MDWampUnsubscribe *msg = [[MDWampUnsubscribe alloc] initWithPayload:self.payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertEqualObjects(msg.request, _payload[0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.subscription, _payload[1], @"Checking Message integrity");
    [self checkMarshallingV2:msg code:@34];
    
    self.payload = @[@"com.myapp.mytopic1"];
    MDWampUnsubscribe *msg2 = [[MDWampUnsubscribe alloc] initWithPayload:self.payload];
    XCTAssertNotNil(msg2, @"Message Must not be nil");
    XCTAssertEqualObjects(msg2.topic, _payload[0], @"Checking Message integrity");
    [self checkMarshallingV1:msg2 code:@6];

}

- (void) testUnsubscribed
{
    self.payload = @[@713845233];
    MDWampUnsubscribed *msg2 = [[MDWampUnsubscribed alloc] initWithPayload:self.payload];
    XCTAssertNotNil(msg2, @"Message Must not be nil");
    XCTAssertEqualObjects(msg2.request, _payload[0], @"Checking Message integrity");
    [self checkMarshallingV2:msg2 code:@35];
}

@end
