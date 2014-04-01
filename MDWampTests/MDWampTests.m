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
#import "NSString+MDString.h"

@interface MDWampTests : XCTAsyncTestCase
@property (strong, nonatomic) MDWamp *wamp;
@property (strong, nonatomic) MDWampClientDelegateMock *delegate;
@property (strong, nonatomic) MDWampTransportMock *transport;

@end

@implementation MDWampTests
//- (void)setUp
//{
//    [super setUp];
//    [self prepare];
//    _delegate = [[MDWampClientDelegateMock alloc] init];
//    _wamp = [[MDWamp alloc] initWithServer:kMDWampTestsServerV2URL realm:@"realm1"];
//    
//    _transport = [[MDWampTransportMock alloc] initWithServer:[NSURL URLWithString:kMDWampTestsServerV2URL] protocolVersions:_wamp.subprotocols];
//    _transport.serialization = [[MDWampSerializationMock alloc] init];
//
//    MDWampProtocolVersionMock *verison = [[MDWampProtocolVersionMock alloc] init];
//    verison.sendHello = YES;
//    
//    _transport.protocol = verison;
//
//    _wamp.transport = _transport;
//    _wamp.delegate = _delegate;
//}
//
//- (void)tearDown
//{
//    [super tearDown];
//}
//
//- (void) testConnect {
//    
//    [_wamp connect];
//    
//    wait_for_network(^{
//        XCTAssertTrue([_delegate onOpenCalled], @"onOpen delegate method must have been called");
//        XCTAssertTrue([_wamp isConnected], @"Client must be connected");
//        [self notify:kXCTUnitWaitStatusSuccess];
//    });
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
//}
//
//- (void) testSessionEstablished {
//    [_wamp connect];
//    wait_for_network(^{
//        id msg = _transport.sendBuffer[0];
//        XCTAssert([msg isKindOfClass:[MDWampHello class]], @"An Hello message must be in the buffer");
//        
//        NSDictionary *roles = [[(MDWampHello*)msg details] objectForKey:@"roles"];
//        XCTAssert([roles count] > 0, @"At least a role should be sent in hello message");
//        
//        MDWampWelcome *welcome = [[MDWampWelcome alloc] init];
//        welcome.session = [NSNumber numberWithInt:[[NSString stringWithRandomId] intValue]];
//        [_transport triggerDidReceiveMessage:welcome];
//        XCTAssertNotNil(_wamp.sessionId , @"Must have session");
//        
//        [self notify:kXCTUnitWaitStatusSuccess];
//    });
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
//}

@end
