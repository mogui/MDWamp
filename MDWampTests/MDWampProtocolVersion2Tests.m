//
//  MDWampTests.m
//  MDWamp
//
//  Created by Niko Usai on 11/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"
#import <MDWamp/MDWampProtocolVersion2.h>
#import <MDWamp/MDWampMessages/MDWampMessages.h>
#import "NSMutableArray+MDStack.h"

@interface MDWampProtocolVersion2Tests : XCTestCase
@property (strong, nonatomic) MDWampProtocolVersion2 *protocol;
@end

@implementation MDWampProtocolVersion2Tests

- (void)setUp
{
    [super setUp];
    _protocol = [[MDWampProtocolVersion2 alloc] init];
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testSendHelloAndSendGoodbye
{
    XCTAssert([_protocol shouldSendGoodbye] && [_protocol shouldSendHello], @"Vesion 2 of protocol should send Hello and Goodbye");
}

- (void)testHello
{
    NSArray *payload = @[@1, @"somerealm", @{@"roles": @{@"publisher":@{}}}];
    
    
    MDWampHello *hello = (MDWampHello *)[_protocol unmarshallMessage:payload];
    
    XCTAssertNotNil(hello, @"Message Must not be nil");
    XCTAssertNotNil([hello.roles objectForKey:@"publisher"], @"Checking Message integrity");
    XCTAssertEqualObjects(hello.realm, payload[1], @"Checking Message integrity");
    
    NSArray *marshalled = [_protocol marshallMessage:hello];
    
    XCTAssertEqualObjects(payload, marshalled, @"Marshalled Message should be equal to payload");
    
}

- (void)testWelcome
{
    NSArray *payload = @[@2, @21233872738, @{@"roles": @{@"broker":@{}}}];
    
    MDWampWelcome *msg = (MDWampWelcome *)[_protocol unmarshallMessage:payload];

    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertNotNil([msg.roles objectForKey:@"broker"], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.session, payload[1], @"Checking Message integrity");
    
    NSArray *marshalled = [_protocol marshallMessage:msg];
    
    XCTAssertEqualObjects(payload, marshalled, @"Marshalled Message should be equal to payload");
}

- (void)testAbort
{
    NSArray *payload = @[@3,  @{@"message": @"The realm does not exist."}, @"wamp.error.no_such_realm"];
    
    MDWampAbort *msg = (MDWampAbort *)[_protocol unmarshallMessage:payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertNotNil([msg.details objectForKey:@"message"], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.reason, payload[2], @"Checking Message integrity");
    
    NSArray *marshalled = [_protocol marshallMessage:msg];
    
    XCTAssertEqualObjects(payload, marshalled, @"Marshalled Message should be equal to payload");
}

- (void)testChallangeCode
{
    NSArray *payload = @[@4,  @{@"message": @"The realm does not exist."}, @"wamp.error.no_such_realm"];
}

- (void)testAuthenticateCode
{
    NSArray *payload = @[@5,  @{@"message": @"The realm does not exist."}, @"wamp.error.no_such_realm"];
}

- (void)testGoodbye
{
    NSArray *payload = @[@6,  @{@"message": @"The host is shutting down now."}, @"wamp.error.system_shutdown"];
    
    MDWampGoodbye *msg = (MDWampGoodbye *)[_protocol unmarshallMessage:payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    XCTAssertNotNil([msg.details objectForKey:@"message"], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.reason, payload[2], @"Checking Message integrity");
    
    NSArray *marshalled = [_protocol marshallMessage:msg];
    
    XCTAssertEqualObjects(payload, marshalled, @"Marshalled Message should be equal to payload");
}

- (void)testHeartbitCode
{
    NSArray *payload = @[@7,  @{@"message": @"The realm does not exist."}, @"wamp.error.no_such_realm"];
}

- (void)testError
{
    NSArray *payload = @[@8, @68, @123456789, @{}, @"com.myapp.error.object_write_protected", @[@"Object is write protected"], @{@"severity": @3}];
    
    MDWampError *msg = (MDWampError *)[_protocol unmarshallMessage:payload];
    
    XCTAssertNotNil(msg, @"Message Must not be nil");
    
    XCTAssertEqualObjects(msg.error, payload[4], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.type, payload[1], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.request, payload[2], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.arguments[0], payload[5][0], @"Checking Message integrity");
    XCTAssertEqualObjects(msg.argumentsKw[@"severity"], payload[6][@"severity"], @"Checking Message integrity");
    
    NSArray *marshalled = [_protocol marshallMessage:msg];
    
    XCTAssertEqualObjects(payload, marshalled, @"Marshalled Message should be equal to payload");
}

@end
