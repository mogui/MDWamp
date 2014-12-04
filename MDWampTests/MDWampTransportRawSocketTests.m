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
    TestClose,
    TestMessage,
    TestFail
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
    transport = [[MDWampTransportRawSocket alloc] initWithHost:@"127.0.0.1" port:9000];
    [transport setSerialization:kMDWampSerializationJSON];
    [transport setDelegate:self];
    [self prepare];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) transportDidOpenWithSerialization:(NSString*)serialization {
    XCTAssert([transport isConnected], @"Must be connected");
    
    if (self.operation == TestOpen) {
        [self notify:kXCTUnitWaitStatusSuccess];
    } else if (self.operation == TestClose) {
        [transport close];
    } else if (self.operation == TestMessage) {
        NSString *helloMsg = @"[1,\"realm1\",{\"roles\":{\"publisher\":{},\"subscriber\":{}}}]";
        NSData *d = [helloMsg dataUsingEncoding:NSUTF8StringEncoding];
        [transport send:d];
    } else if (self.operation == TestFail) {
        NSData *d = [@"[Wrong format at all]" dataUsingEncoding:NSUTF8StringEncoding];
        [transport send:d];
    }
}

- (void) transportDidReceiveMessage:(NSData *)message {
    if (self.operation == TestMessage) {
        XCTAssertNotNil(message, @"Must receive something");
        
        NSString *welcome = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
        NSLog(@"received %@", welcome);
        // Test if the received string is a JSON representing a Welcome message
        XCTAssert([welcome hasPrefix:@"[2,"], @"Check received Welcome");
        
        [self notify:kXCTUnitWaitStatusSuccess];
    }
}

- (void) transportDidFailWithError:(NSError *)error {
    XCTAssertFalse([transport isConnected], @"Must be not connected");
    [self notify:kXCTUnitWaitStatusSuccess];
}

- (void) transportDidCloseWithError:(NSError *)error {
    XCTAssertFalse([transport isConnected], @"Must be not connected");
    [self notify:kXCTUnitWaitStatusSuccess];
}

- (void)testOpen
{
    self.operation = TestOpen;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}

- (void)testClose
{
    self.operation = TestClose;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}

- (void)testSendAndReceiveMessage {
    self.operation = TestMessage;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}

- (void)testFail {
    self.operation = TestFail;
    [transport open];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:1];
}
@end
