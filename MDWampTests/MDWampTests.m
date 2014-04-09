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

- (id<MDWampMessage>)msgFromPayload:(id)payload IsA:(Class)class
{
    NSArray *arr = [_s unpack:payload];
    Class msgC = [MDWampMessageFactory messageClassFromCode:arr[0] forVersion:kMDWampVersion2];

    if ( ![msgC isSubclassOfClass:[MDWampHello class]]) {
        return nil;
    }
    
    NSMutableArray *tmp = [arr mutableCopy];
    [tmp shift];
    
    return [(id<MDWampMessage>)[msgC alloc] initWithPayload:tmp];
}

- (void) testSessionEstablished {
    [_wamp connect];
    
    MDWampHello *hello = [self msgFromPayload:_transport.sendBuffer[0] IsA:[MDWampHello class]];
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

@end
