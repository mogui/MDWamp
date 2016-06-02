//
//  MDWampTransportWebSocketTests.m
//  MDWamp
//
//  Created by Niko Usai on 17/06/14.
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

- (void)transportDidOpenWithSerialization:(NSString*)serialization {

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
        XCTAssertEqualObjects(serialization, kMDWampSerializationJSON, @"serialization should be json");
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


- (void)testDidOpen
{
    transport = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080"] protocolVersions:@[kMDWampProtocolWamp2json]];
    transport.delegate = self;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}

- (void)testDidFailWrongProtocol
{
    transport = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080"] protocolVersions:@[kMDWampProtocolWamp2json]]; // crossbar fails when giving verison 1
    transport.delegate = self;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}

- (void)testSendReceiveMessage
{
    transport = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080"] protocolVersions:@[kMDWampProtocolWamp2json]]; // crossbar fails when giving verison 1
    transport.delegate = self;
    self.testMessage = YES;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:3];
}

//- (void)testDidClose
//{
//    transport = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080/ws"] protocolVersions:@[@"wamp"]]; // crossbar fails when giving verison 1
//    transport.delegate = self;
//    self.testClose = YES;
//    [transport open];
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
//}

- (void)testDidCloseError
{
    transport = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080"] protocolVersions:@[kMDWampProtocolWamp2json]]; // crossbar fails when giving verison 1
    transport.delegate = self;
    self.testCloseError = YES;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}
@end
