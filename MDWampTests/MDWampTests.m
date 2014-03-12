//
//  MDWampTests.m
//  MDWamp
//
//  Created by Niko Usai on 11/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"
#import "MDWampTestIncludes.h"
#import "MDWamp.h"


@interface MDWampTests : XCTAsyncTestCase
@property (strong, nonatomic) MDWamp *wamp;
@property (strong, nonatomic) MDWampClientDelegateMock *delegate;
@property (strong, nonatomic) MDWampTransportMock *transport;

@end

@implementation MDWampTests
- (void)setUp
{
    [super setUp];
    [self prepare];
    _delegate = [[MDWampClientDelegateMock alloc] init];
    _wamp = [[MDWamp alloc] initWithServer:kMDWampTestsServerV2URL realm:@"realm1"];
    
    _transport = [[MDWampTransportMock alloc] initWithServer:[NSURL URLWithString:kMDWampTestsServerV2URL] protocolVersions:_wamp.subprotocols];
    _transport.transportChooseSerialization = [MDWampSerializationMock class];
    _transport.transportChooseVersion = [MDWampProtocolVersionMock class];
    
    _wamp.transport = _transport;
    _wamp.delegate = _delegate;
}
- (void)tearDown
{
    [super tearDown];
}

- (void) testConnect {
    
    [_wamp connect];
    
    wait_for_network(^{
        XCTAssertTrue([_delegate onOpenCalled], @"onOpen delegate method must have been called");
        XCTAssertTrue([_wamp isConnected], @"Client must be connected");
        [self notify:kXCTUnitWaitStatusSuccess];
    });
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}

- (void) testSessionEstablished {
    [_wamp connect];
    wait_for_network(^{

        XCTAssertNotNil(_wamp.sessionId , @"Must have session");
        [self notify:kXCTUnitWaitStatusSuccess];
    });
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}

@end
