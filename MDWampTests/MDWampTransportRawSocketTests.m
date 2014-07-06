//
//  MDWampTransportRawSocketTests.m
//  MDWamp
//
//  Created by Niko Usai on 06/07/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"
#import "MDWampTransportRawSocket.h"

typedef enum : NSUInteger {
    TestOpen,
    TestMessage
} MDWampRawSocketTestsOperation;

@interface MDWampTransportRawSocketTests : XCTAsyncTestCase <MDWampTransportDelegate>
{
    MDWampTransportRawSocket *transport;
}
@property (assign) MDWampRawSocketTestsOperation operation;
@end

@implementation MDWampTransportRawSocketTests

- (void)setUp
{
    [super setUp];
    transport = [[MDWampTransportRawSocket alloc] initWithHost:@"127.0.0.1" port:5555];
    [transport setSerialization:kMDWampSerializationJSON];
    [transport setDelegate:self];
    [self prepare];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void) transportDidReceiveMessage:(NSData *)message {
    if (self.operation == TestMessage) {
        XCTAssertNotNil(message, @"Must receive welcome message");
        [self notify:kXCTUnitWaitStatusSuccess];
    }
}

- (void) transportDidOpenWithVersion:(MDWampVersion)version andSerialization:(MDWampSerializationClass)serialization {
    if (self.operation == TestOpen) {
        [self notify:kXCTUnitWaitStatusSuccess];
    }
}

- (void) transportDidFailWithError:(NSError *)error {
    
}

- (void) transportDidCloseWithError:(NSError *)error {
   
}

- (void)testOpen
{
    self.operation = TestOpen;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}

- (void)testSendMessage {
    self.operation = TestMessage;
    [transport open];
    
    NSString *helloMsg = @"[1,\"Realm1\",{}]";
    NSData *d = [helloMsg dataUsingEncoding:NSUTF8StringEncoding];
    [transport send:d];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}

@end
