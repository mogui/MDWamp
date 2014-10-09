//
//  MDWampTests.m
//  MDWamp
//
//  Created by Niko Usai on 11/03/14.
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
#import "MDWampTestIncludes.h"
#import "MDWamp.h"
#import "NSString+MDString.h"

#define kMDWampSerializationMock @"MDWampSerializationMock"

@interface MDWampTests : XCTAsyncTestCase
@property (strong, nonatomic) MDWamp *wamp;
@property (strong, nonatomic) MDWampClientDelegateMock *delegate;
@property (strong, nonatomic) MDWampTransportMock *transport;
@property (strong, nonatomic) MDWampSerializationMock *s;
@property (strong, nonatomic) NSDictionary *dictionaryPayload;
@property (strong, nonatomic) NSArray *arrayPayload;
@end

@implementation MDWampTests

- (void)setUp
{
    [super setUp];
    _delegate = [[MDWampClientDelegateMock alloc] init];
    _transport = [[MDWampTransportMock alloc] initWithServer:[NSURL URLWithString:@"http://fakeserver.com"] protocolVersions:@[]];
    _transport.serializationClass = kMDWampSerializationMock;
    self.wamp = [[MDWamp alloc] initWithTransport:_transport realm:@"Realm1" delegate:_delegate];
    _s = [[MDWampSerializationMock alloc] init];

    self.dictionaryPayload = @{@"color": @"orange", @"sizes": @[@23, @42, @7]};
    self.arrayPayload = @[@1,@2, @34, @4545];
    
    [_wamp connect];
    [self prepare];
}

- (void)tearDown
{
    [super tearDown];
}


- (id<MDWampMessage>)msgFromTransportAndCheckIsA:(Class)class
{
    NSArray *arr = [_s unpack:[_transport.sendBuffer lastObject]];
    
    NSMutableArray *tmp = [arr mutableCopy];
    [tmp shift];
    
    id<MDWampMessage> msg = [[MDWampMessageFactory sharedFactory] objectFromCode:arr[0] withPayload:tmp];
    XCTAssertTrue([[msg class] isSubclassOfClass:class], @"Wrong class");
    XCTAssertNotNil(msg, @"An %@ message must be in the transport buffer", NSStringFromClass(class));
    
    return msg;
}

- (void)triggerMsg:(id<MDWampMessage>)msg
{
    NSArray *arr = [msg marshall];
    NSData *d = [_s pack:arr];
    [_transport triggerDidReceiveMessage:d];
}

- (void) testSessionEstablished {
    [_wamp setOnSessionEstablished:^(MDWamp *wamp, NSDictionary *details) {
        XCTAssertEqualObjects(details[@"serverIdent"], @"MDWampServer", @"must return details correctly");
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    
    MDWampHello *hello = [self msgFromTransportAndCheckIsA:[MDWampHello class]];
    
    NSDictionary *roles = [[hello details] objectForKey:@"roles"];
    XCTAssert([roles count] > 0, @"At least a role should be sent in hello message");
    
    MDWampWelcome *welcome = [[MDWampWelcome alloc] init];
    welcome.session = [NSNumber numberWithInt:[[NSString stringWithRandomId] intValue]];
    welcome.details = @{@"serverIdent":@"MDWampServer"};
    
    [self triggerMsg:welcome];
    XCTAssertTrue([_wamp isConnected], @"must be connected");
    XCTAssertNotNil(_wamp.sessionId , @"Must have session");
    XCTAssert(_delegate.onOpenCalled , @"Session  onOpen method must be called");
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testSessionAbort {
    [_wamp setOnSessionClosed:^(MDWamp *w, NSInteger code, NSString *reason, NSDictionary *det) {
        XCTAssertEqualObjects(reason, @"wamp.error.no_such_realm", @"must return abort reasons");
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    MDWampAbort *abort = [[MDWampAbort alloc] initWithPayload:@[@{@"message": @"The realm does not exist."}, @"wamp.error.no_such_realm"]];

    [self triggerMsg:abort];
    
    XCTAssert(_delegate.onCloseCalled , @"Session is Abortd onClose method must be called");
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testGoodbye {
    
    MDWampGoodbye *goodbye = [[MDWampGoodbye alloc] initWithPayload:@[@{}, @"wamp.error.close_realm"]];
    [self triggerMsg:goodbye];
    
    [self msgFromTransportAndCheckIsA:[MDWampGoodbye class]];
    
    XCTAssert(_delegate.onCloseCalled , @"Server sent goodbye onClose method must be called");
}

- (void)testDisconnect {
    [_wamp setOnSessionClosed:^(MDWamp *w, NSInteger code, NSString *reason, NSDictionary *details) {
        XCTAssert(code == MDWampConnectionClosed	, @"explicit close");
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    [_wamp disconnect];
    XCTAssert(_delegate.onCloseCalled, @"On close must be called on delegate");
    XCTAssertFalse([_wamp isConnected], @"Must not be connected");
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}
- (void)testSubscribeFails {
    [_wamp subscribe:@"com.topic.x"  onEvent:^(id payload) {
        // nothing to do
    } result:^(NSError *error) {
        XCTAssertEqualObjects(error.localizedDescription, @"wamp.error.not_authorized", @"Must call error");
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    MDWampSubscribe *sub = [self msgFromTransportAndCheckIsA:[MDWampSubscribe class]];
    MDWampError *error = [[MDWampError alloc] initWithPayload:@[@32, sub.request, @{}, @"wamp.error.not_authorized"]];
    [_transport triggerDidReceiveMessage:[error marshall]];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testSubscribe {
    [_wamp subscribe:@"com.topic.x" onEvent:^(id payload) {
        // nothing to do
    } result:^(NSError *error) {
        XCTAssertNil(error, @"error must be nil");
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    MDWampSubscribe *sub2 = [self msgFromTransportAndCheckIsA:[MDWampSubscribe class]];
    MDWampSubscribed *subscribed = [[MDWampSubscribed alloc] initWithPayload:@[sub2.request, @12343234]];
    [_transport triggerDidReceiveMessage:[subscribed marshall]];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}


- (void)testUnsubscribe
{
    
    [_wamp subscribe:@"com.asder.x" onEvent:^(id payload) {
        // nothing
    } result:^(NSError *error) {
        
        // triggering an error server side
        [_wamp unsubscribe:@"com.asder.x" result:^(NSError *error) {
            XCTAssertNil(error, @"Successfully unsubscribed");
            // Should fail instantly
            [self notify:kXCTUnitWaitStatusSuccess];
        }];
        
        MDWampUnsubscribe *un2 = [self msgFromTransportAndCheckIsA:[MDWampUnsubscribe class]];
        
        MDWampUnsubscribed *unsub = [[MDWampUnsubscribed alloc] initWithPayload:@[un2.request]];
        [_transport triggerDidReceiveMessage:[unsub marshall]];
        
    } ];
    
    MDWampSubscribe *sub3 = [self msgFromTransportAndCheckIsA:[MDWampSubscribe class]];
    MDWampSubscribed *subscribed2 = [[MDWampSubscribed alloc] initWithPayload:@[sub3.request, @12343234]];
    [_transport triggerDidReceiveMessage:[subscribed2 marshall]];
    
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}


- (void)testUnsubscribeFail
    {
    [_wamp subscribe:@"com.asder.x" onEvent:^(id payload) {
        // nothing
    } result:^(NSError *error) {
        
        // triggering an error server side
        [_wamp unsubscribe:@"com.asder.x" result:^(NSError *error) {
            XCTAssertNotNil(error, @"Must call error");
            // Should fail instantly
            [self notify:kXCTUnitWaitStatusSuccess];
        }];
        
        MDWampUnsubscribe *un2 = [self msgFromTransportAndCheckIsA:[MDWampUnsubscribe class]];
        
        MDWampError *error2 = [[MDWampError alloc] initWithPayload:@[@34, un2.request, @{}, @"wamp.error.no_such_subscription"]];
        [_transport triggerDidReceiveMessage:[error2 marshall]];

    } ];
    
    MDWampSubscribe *sub3 = [self msgFromTransportAndCheckIsA:[MDWampSubscribe class]];
    MDWampSubscribed *subscribed2 = [[MDWampSubscribed alloc] initWithPayload:@[sub3.request, @12343234]];
    [_transport triggerDidReceiveMessage:[subscribed2 marshall]];
    
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testPublish {
    [_wamp publishTo:@"com.myapp.mytopic1"
                args:self.arrayPayload
                  kw:self.dictionaryPayload
             options:@{@"acknowledge":@YES}
              result:^(NSError *error) {
                  // check if publishing is OK or not
                  XCTAssertNil(error, @"No error must be triggered");
                  
                  [self notify:kXCTUnitWaitStatusSuccess];
              }];
    MDWampPublish *msg = [self msgFromTransportAndCheckIsA:[MDWampPublish class]];
    XCTAssertEqualObjects(msg.argumentsKw, self.dictionaryPayload, @"Publish message sent to transport");
    XCTAssertEqualObjects(msg.arguments, self.arrayPayload, @"Publish message sent to transport");
    MDWampPublished *pub = [[MDWampPublished alloc] initWithPayload:@[msg.request, @123123123]];
    [_transport triggerDidReceiveMessage:[pub marshall]];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testHeartbeat {
    
    [_wamp disconnect]; // we must set heartbeat before connect
    MDWampClientConfig *conf = [[MDWampClientConfig alloc] init];
    conf.roles = @{
      kMDWampRolePublisher : @{},
      kMDWampRoleSubscriber : @{},
      kMDWampRoleCaller : @{},
      kMDWampRoleCallee : @{}
      };
    conf.heartbeatInterval = 1;
    [_wamp setConfig:conf];
    [_wamp connect];
    
    // wait for beat to be received
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MDWampHeartbeat *msg = [self msgFromTransportAndCheckIsA:[MDWampHeartbeat class]];
        XCTAssertEqualObjects(msg.incomingSeq, @0, @"Incoming must be 0 for first message");
        XCTAssertEqualObjects(msg.outgoingSeq, @1, @"Out must be 1");
        MDWampHeartbeat *beat = [[MDWampHeartbeat alloc] initWithPayload:@[@1, @1]];
        [_transport triggerDidReceiveMessage:[beat marshall]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            MDWampHeartbeat *msg = [self msgFromTransportAndCheckIsA:[MDWampHeartbeat class]];
            XCTAssertEqualObjects(msg.incomingSeq, @1, @"Incoming must be 0 for first message");
            XCTAssertEqualObjects(msg.outgoingSeq, @2, @"Out must be 1");
            [self notify:kXCTUnitWaitStatusSuccess];
        });
    });

    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:7];
}

- (void)testPublishWithError {
    [_wamp publishTo:@"com.myapp.mytopic1"
                args:self.arrayPayload
                  kw:self.dictionaryPayload
             options:@{@"acknowledge":@YES}
              result:^(NSError *error) {
                  // check if publishing is OK or not
                  XCTAssertNotNil(error, @"Error must be triggered");
                  XCTAssertEqualObjects(error.localizedDescription, @"wamp.error.not_authorized", @"right error must be passed");
                  [self notify:kXCTUnitWaitStatusSuccess];
              }];
    MDWampPublish *msg = [self msgFromTransportAndCheckIsA:[MDWampPublish class]];
    XCTAssertEqualObjects(msg.argumentsKw, self.dictionaryPayload, @"Publish message sent to transport");
    XCTAssertEqualObjects(msg.arguments, self.arrayPayload, @"Publish message sent to transport");
    MDWampError *error = [[MDWampError alloc] initWithPayload:@[@16, msg.request,@{},@"wamp.error.not_authorized"]];
    [_transport triggerDidReceiveMessage:[error marshall]];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testEvent {
    NSArray *eventPayload = @[@"foo"];
    __block MDWampSubscribed *subscribed = nil;
    
    [_wamp subscribe:@"com.topic.x"  onEvent:^(MDWampEvent *payload) {
        // nothing to do
        XCTAssertEqualObjects(payload.arguments, eventPayload, @"event received must be the same of event dispatched");
        [self notify:kXCTUnitWaitStatusSuccess];
    } result:^(NSError *error) {
        XCTAssertNil(error, @"Must be no error");
        // trigger event
        MDWampEvent *event = [[MDWampEvent alloc] initWithPayload:@[subscribed.subscription, @123343, @{}, eventPayload]];
        [_transport triggerDidReceiveMessage:[event marshall]];

    }];
    
    MDWampSubscribe *sub = [self msgFromTransportAndCheckIsA:[MDWampSubscribe class]];
    subscribed = [[MDWampSubscribed alloc] initWithPayload:@[sub.request, @12343234]];
    [_transport triggerDidReceiveMessage:[subscribed marshall]];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testCallProcedure {
    [_wamp call:@"com.myapp.add2" args:@[@23, @7] kwArgs:nil complete:^(MDWampResult *result, NSError *error) {
        XCTAssertEqualObjects(result.result, @30, @"MUST return correct result from the call");
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    MDWampCall *msg = [self msgFromTransportAndCheckIsA:[MDWampCall class]];

    MDWampResult *res = [[MDWampResult alloc] initWithPayload:@[msg.request, @{}, @[@30]]];
    [_transport triggerDidReceiveMessage:[res marshall]];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testCallProcedureFails {
    [_wamp call:@"com.myapp.wrong" args:nil kwArgs:nil complete:^(MDWampResult *result, NSError *error) {
        XCTAssertNil(result, @"result must be nil");
        XCTAssertEqualObjects(error.localizedDescription, @"wamp.error.no_such_procedure", @"right error returned");
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    MDWampCall *msg = [self msgFromTransportAndCheckIsA:[MDWampCall class]];
    
    MDWampError *res = [[MDWampError alloc] initWithPayload:@[@48, msg.request, @{}, @"wamp.error.no_such_procedure"]];
    [_transport triggerDidReceiveMessage:[res marshall]];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}


- (void)testRegister {
    // register and receive registered message
    [_wamp registerRPC:@"com.myapp.myprocedure1" procedure:^ id(NSDictionary *details, NSArray *arguments, NSDictionary *argumentsKW) {
        // do nothing
        return nil;
    } result:^(NSError *error) {
        XCTAssertNil(error, @"Error must be nil if register is all right");
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    
    MDWampRegister *msg = [self msgFromTransportAndCheckIsA:[MDWampRegister class]];
    
    MDWampRegistered *res = [[MDWampRegistered alloc] initWithPayload:@[msg.request, @12343565]];
    [_transport triggerDidReceiveMessage:[res marshall]];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testRegisterFail {
    // register and receive registered message
    [_wamp registerRPC:@"com.myapp.myprocedure1" procedure:^id(NSDictionary *details, NSArray *arguments, NSDictionary *argumentsKW) {
        // do nothing
        return nil;
    } result:^(NSError *error) {
        XCTAssertNotNil(error, @"Error must be nil if register is all right");
        XCTAssertEqualObjects(error.localizedDescription, @"wamp.error.procedure_already_exists", @"must return right error");
        [self notify:kXCTUnitWaitStatusSuccess];
    }];
    MDWampRegister *msg = [self msgFromTransportAndCheckIsA:[MDWampRegister class]];
    
    MDWampError *res = [[MDWampError alloc] initWithPayload:@[@64, msg.request, @{}, @"wamp.error.procedure_already_exists"]];
    [_transport triggerDidReceiveMessage:[res marshall]];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testUnregister {
    
    [_wamp registerRPC:@"com.myapp.myprocedure1" procedure:^id(NSDictionary *details, NSArray *arguments, NSDictionary *argumentsKW) {
        return nil;
    } result:^(NSError *error) {
        XCTAssertNil(error, @"Error must be nil");
        [_wamp unregisterRPC:@"com.myapp.myprocedure1" result:^(NSError *error) {
            XCTAssertNil(error, @"Error must be nil if register is all right");
            [self notify:kXCTUnitWaitStatusSuccess];
        }];
        
        MDWampUnregister *msg = [self msgFromTransportAndCheckIsA:[MDWampUnregister class]];
        
        MDWampUnregistered *res = [[MDWampUnregistered alloc] initWithPayload:@[msg.request]];
        [_transport triggerDidReceiveMessage:[res marshall]];
    }];
    
    MDWampRegister *msg = [self msgFromTransportAndCheckIsA:[MDWampRegister class]];
    
    MDWampRegistered *res = [[MDWampRegistered alloc] initWithPayload:@[msg.request, @12343565]];
    [_transport triggerDidReceiveMessage:[res marshall]];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testUnregisterFail {
    [_wamp registerRPC:@"com.myapp.myprocedure1" procedure:^id(NSDictionary *details, NSArray *arguments, NSDictionary *argumentsKW) {
        return nil;
    } result:^(NSError *error) {
        [_wamp unregisterRPC:@"com.myapp.myprocedure1" result:^(NSError *error) {
            XCTAssertNotNil(error, @"Error must be nil if register is all right");
            
            XCTAssertEqualObjects(error.localizedDescription, @"wamp.error.no_such_registration", @"UNregistereing for a never registered procedure must be not ok");
            [self notify:kXCTUnitWaitStatusSuccess];
        }];
        
        MDWampUnregister *msg = [self msgFromTransportAndCheckIsA:[MDWampUnregister class]];
        
        MDWampError *res = [[MDWampError alloc] initWithPayload:@[@66, msg.request, @{}, @"wamp.error.no_such_registration"]];
        [_transport triggerDidReceiveMessage:[res marshall]];
    }];
    
    MDWampRegister *msg = [self msgFromTransportAndCheckIsA:[MDWampRegister class]];
    
    MDWampRegistered *res = [[MDWampRegistered alloc] initWithPayload:@[msg.request, @12343565]];
    [_transport triggerDidReceiveMessage:[res marshall]];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testYield {
//    trigger an invocation message and send a YIELD
// tested with a register call with a register call we save the callback to call
    NSNumber *registrationID = @12343565;
    NSNumber *invokationRequestID = @343565878;
    
    [_wamp registerRPC:@"com.myapp.myprocedure1" procedure:^id(NSDictionary *details, NSArray *arguments, NSDictionary *argumentsKW) {
        
        return [NSNumber numberWithInt:[arguments[0] intValue] + [arguments[1] intValue]];
    } result:^(NSError *error) {
        // procedure is registered, forcing an invoke message
        
        XCTAssertNil(error, @"No error should be triggered");
        MDWampInvocation *invoke = [[MDWampInvocation alloc] initWithPayload:@[invokationRequestID, registrationID, @{}, @[@23, @7]]];
        [_transport triggerDidReceiveMessage:[invoke marshall]];
        // retrieve the Yield message with the result
        MDWampYield *yield = [self msgFromTransportAndCheckIsA:[MDWampYield class]];
        XCTAssertEqualObjects(yield.arguments[0], @30, @"Yield must contain the result of the procedure registered");
        [self notify:kXCTUnitWaitStatusSuccess];
        
    }];
    
    MDWampRegister *msg = [self msgFromTransportAndCheckIsA:[MDWampRegister class]];
    MDWampRegistered *res = [[MDWampRegistered alloc] initWithPayload:@[msg.request, registrationID]];
    [_transport triggerDidReceiveMessage:[res marshall]];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:0.5];
}

- (void)testYieldFails {
    
}



@end
