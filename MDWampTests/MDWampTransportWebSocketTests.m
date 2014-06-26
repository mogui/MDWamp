//
//  MDWampTransportWebSocketTests.m
//  MDWamp
//
//  Created by Niko Usai on 17/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"
#import "MDWampTransportWebSocket.h"
#import "MDWampTransportDelegate.h"
@interface MDWampTransportWebSocketTests : XCTAsyncTestCase <MDWampTransportDelegate>
{
    MDWampTransportWebSocket *transport;
}
@property (assign) BOOL testClose;
@property (assign) BOOL testCloseError;
@property (assign) BOOL testMessage;
@end

@implementation MDWampTransportWebSocketTests

- (void)setUp
{
    [super setUp];
    self.testClose = NO;
    self.testMessage = NO;
    [self prepare];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)transportDidReceiveMessage:(NSData *)message {
    XCTAssertNotNil(message, @"Must receive a message");
    [self notify:kXCTUnitWaitStatusSuccess];
}

- (void)transportDidOpenWithVersion:(MDWampVersion)version andSerialization:(MDWampSerializationClass)serialization {

    if (self.testClose) {
        [transport close];
    } else if (self.testCloseError) {
        
        // Send malformed message to force socket close
        [transport send:@"[1, \"Realm1\", {}]"];
    } else if (self.testMessage) {
        while (![transport isConnected]) {
            // just wait
            sleep(1);
        }
        // test hello message just to receive something back
        [transport send:@"[1, \"Realm1\", {\"roles\": {\"publisher\": {}}}]"];
    } else {
        XCTAssertEqualObjects(version, kMDWampVersion2, @"version should be 2");
        [self notify:kXCTUnitWaitStatusSuccess];
    }
}

- (void)transportDidFailWithError:(NSError *)error {
    XCTAssertNotNil(error, @"error triggered for bad protocol");
    XCTAssertEqual(error.code,2132, @"bad response code error from server 400 must be triggered");
    [self notify:kXCTUnitWaitStatusSuccess];
}

- (void)transportDidCloseWithError:(NSError *)error {
    if (self.testCloseError) {
        XCTAssertNotNil(error, @"Close must be called with a nice error");
        XCTAssertEqual(error.code,1002, @"WAMP Protocol Error (missing mandatory roles attribute in options in HELLO) must be triggered");
        [self notify:kXCTUnitWaitStatusSuccess];
    } else if (self.testClose) {
        XCTAssertNotNil(error, @"Close must be called with a nice error");
        XCTAssertEqual(error.code,54, @"Connection resetted by peer must be triggered");
        [self notify:kXCTUnitWaitStatusSuccess];
    }
}


- (void)testDidOpenWithVersion2
{
    transport = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080/ws"] protocolVersions:@[kMDWampVersion2]];
    transport.delegate = self;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}

- (void)testDidFailWrongProtocol
{
    transport = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080/ws"] protocolVersions:@[kMDWampVersion1]]; // crossbar fails when giving verison 1
    transport.delegate = self;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}

- (void)testSendReceiveMessage
{
    transport = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080/ws"] protocolVersions:@[kMDWampVersion2JSON]]; // crossbar fails when giving verison 1
    transport.delegate = self;
    self.testMessage = YES;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:3];
}
- (void)testDidClose
{
    transport = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080/ws"] protocolVersions:@[kMDWampVersion2]]; // crossbar fails when giving verison 1
    transport.delegate = self;
    self.testClose = YES;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}

- (void)testDidCloseError
{
    transport = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080/ws"] protocolVersions:@[kMDWampVersion2]]; // crossbar fails when giving verison 1
    transport.delegate = self;
    self.testCloseError = YES;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}
@end
