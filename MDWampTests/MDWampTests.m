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

#define kMDWampTestsFakeSerialization 99

@interface MDWampTests : XCTAsyncTestCase
@property (strong, nonatomic) MDWamp *wamp;
@property (strong, nonatomic) MDWampClientDelegateMock *delegate;
@property (strong, nonatomic) MDWampTransportMock *transport;
@property (strong, nonatomic) MDWampSerializationMock *s;
@end

@implementation MDWampTests

- (void)setUp
{
    [super setUp];
    _delegate = [[MDWampClientDelegateMock alloc] init];
    _transport = [[MDWampTransportMock alloc] initWithServer:[NSURL URLWithString:@"http://fakeserver.com"]];
    _transport.serializationClass = kMDWampTestsFakeSerialization;
    self.wamp = [[MDWamp alloc] initWithTransport:_transport realm:@"Realm1" delegate:_delegate];
    self.wamp.serializationInstanceMap = @{[NSNumber numberWithInt:kMDWampTestsFakeSerialization]: [MDWampSerializationMock class]};
    _s = [[MDWampSerializationMock alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSData *) msgToData:(id<MDWampMessage>)msg
{
    NSArray *arr = [msg marshallFor:kMDWampVersion2];
    return [_s pack:arr];
}

- (id<MDWampMessage>)msgFromTransportAndCheckIsA:(Class)class
{
    NSArray *arr = [_s unpack:[_transport.sendBuffer lastObject]];
    Class msgC = [MDWampMessageFactory messageClassFromCode:arr[0] forVersion:kMDWampVersion2];

    if ( ![msgC isSubclassOfClass:class]) {
        return nil;
    }
    
    NSMutableArray *tmp = [arr mutableCopy];
    [tmp shift];
    
    return [(id<MDWampMessage>)[msgC alloc] initWithPayload:tmp];
}

- (void) testSessionEstablished {
    [_wamp connect];
    
    MDWampHello *hello = [self msgFromTransportAndCheckIsA:[MDWampHello class]];
    XCTAssertNotNil(hello, @"An Hello message must be in the transport buffer");
    
    NSDictionary *roles = [[hello details] objectForKey:@"roles"];
    XCTAssert([roles count] > 0, @"At least a role should be sent in hello message");
    
    MDWampWelcome *welcome = [[MDWampWelcome alloc] init];
    welcome.session = [NSNumber numberWithInt:[[NSString stringWithRandomId] intValue]];
    welcome.details = @{};
    NSData *d = [self msgToData:welcome];
    [_transport triggerDidReceiveMessage:d];
    
    XCTAssertNotNil(_wamp.sessionId , @"Must have session");
}

- (void)testSessionAbort {
    [_wamp connect];
    
    MDWampAbort *abort = [[MDWampAbort alloc] initWithPayload:@[@{@"message": @"The realm does not exist."}, @"wamp.error.no_such_realm"]];

    [_transport triggerDidReceiveMessage:[self msgToData:abort]];
    
    XCTAssert(_delegate.onCloseCalled , @"Session is Abortd onClose method must be called");
}

- (void)testGoodbye {
    [_wamp connect];
    MDWampGoodbye *goodbye = [[MDWampGoodbye alloc] initWithPayload:@[@{}, @"wamp.error.close_realm"]];
    [_transport triggerDidReceiveMessage:[self msgToData:goodbye]];
    MDWampGoodbye *goodbyeResp = [self msgFromTransportAndCheckIsA:[MDWampGoodbye class]];
    XCTAssertNotNil(goodbyeResp, @"client must send goodbye response");
    XCTAssert(_delegate.onCloseCalled , @"Server sent goodbye onClose method must be called");
}

- (void)testSubscribe
{
    [_wamp connect];
    
    //
    // test fail subscription
    //
    [self prepare];
    [_wamp subscribe:@"com.topic.x" result:^(NSString *error, NSDictionary *details) {
        XCTAssertEqualObjects(error, @"wamp.error.not_authorized", @"Must call error");
        [self notify:kXCTUnitWaitStatusSuccess];
    } onEvent:^(id payload) {
        
    }];
    MDWampSubscribe *sub = [self msgFromTransportAndCheckIsA:[MDWampSubscribe class]];
    MDWampError *error = [[MDWampError alloc] initWithPayload:@[@32, sub.request, @{}, @"wamp.error.not_authorized"]];
    [_transport triggerDidReceiveMessage:[error marshallFor:kMDWampVersion2]];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
    
    
    //
    // test succed subscription
    //
    [self prepare];
    [_wamp subscribe:@"com.topic.x" result:^(NSString *error, NSDictionary *details) {
        XCTAssertNil(error, @"error must be nil");
        [self notify:kXCTUnitWaitStatusSuccess];
    } onEvent:^(id payload) {
        
    }];
    MDWampSubscribe *sub2 = [self msgFromTransportAndCheckIsA:[MDWampSubscribe class]];
    MDWampSubscribed *subscribed = [[MDWampSubscribed alloc] initWithPayload:@[sub2.request, @12343234]];
    [_transport triggerDidReceiveMessage:[subscribed marshallFor:kMDWampVersion2]];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
    
    
    //
    // test received event
    //
    [self prepare]; 
    [_wamp subscribe:@"com.topic.x" result:^(NSString *error, NSDictionary *details) {
        
    } onEvent:^(id payload) {
        XCTAssertNotNil(payload, @"received event");
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    // serve il publish
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

@end
