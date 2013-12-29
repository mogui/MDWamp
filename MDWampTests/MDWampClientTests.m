//
//  MDWampClientTests.m
//  MDWamp
//
//  Created by Niko Usai on 13/12/13.
//  Copyright (c) 2013 mogui.it. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"
#import "MDWampTest.h"
#import "MDWampClient.h"

@interface MDWampClientTests : XCTAsyncTestCase
@property (strong, nonatomic) MDWampClient *wc;
@property (strong, nonatomic) MDWampClientDelegateMock *delegate;
@end

@implementation MDWampClientTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)initClientWithServer:(NSString*)server delegate:(id<MDWampClientDelegate>)delegate
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:server]];
    _wc = [[MDWampClient alloc] initWithURLRequest:request delegate:delegate];
}

- (void)initClientAndDelegate
{
    self.delegate = [[MDWampClientDelegateMock alloc] init];
    [self initClientWithServer:kMDWampTestsServerURL delegate:_delegate];
}

- (void)initClient
{
    [self initClientWithServer:kMDWampTestsServerURL delegate:nil];
}

- (void) testInitWithRequestAndDelegate
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kMDWampTestsServerURL]];
    _wc = [[MDWampClient alloc] initWithURLRequest:request delegate:nil];
    XCTAssertNotNil(_wc, @"Inited ws client must not be nil");
}

- (void) testConnectWithValidServer
{
    [self initClientAndDelegate];
    
    [self prepare];
    [_wc connect];

    wait_for_network(^{
        XCTAssertTrue([_delegate onOpenCalled], @"onOpen delegate method must have been called");
        XCTAssertTrue([_wc isConnected], @"Client must be connected");
        [self notify:kXCTUnitWaitStatusSuccess];
    });
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}

- (void) testConnectWithValidServerWithBlock
{
    [self initClient];
    
    __weak MDWampClientTests *weakSelf = self;
    [_wc setOnConnectionOpen:^(MDWampClient *client){
        XCTAssertTrue([weakSelf.wc isConnected], @"Client must be connected");
        [weakSelf notify:kXCTUnitWaitStatusSuccess];
    }];
    [self prepare];
    [_wc connect];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}


- (void) testConnectCloseConnectionWithBlock
{
    [self initClient];
    
    __weak MDWampClientTests *weakSelf = self;
    
    [_wc setOnConnectionOpen:^(MDWampClient *client){
       [client disconnect];
    }];
    [_wc setOnConnectionClose:^(MDWampClient *client, NSInteger code, NSString *reason) {
        XCTAssertEqual((int)code, 54, @"Must be clean closing");
        [weakSelf notify:kXCTUnitWaitStatusSuccess];
    }];
    [self prepare];
    [_wc connect];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}


- (void) testConnectWithWrongServerMustFail
{
    [self initClientWithServer:@"ws://blabla:9090" delegate:nil];
    [self prepare];
    [_wc connect];
    
     wait_for_network(^{
        XCTAssertFalse([_wc isConnected], @"Client must NOT be connected");
        [self notify:kXCTUnitWaitStatusSuccess];
     });
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];

}

- (void) testDisconnection
{
    [self initClient];
    [self prepare];
    [_wc connect];
    
    wait_for_network(^{
        if ([_wc isConnected]) {
            [_wc disconnect];
            wait_for_network(^{
                XCTAssertFalse([_wc isConnected], @"Client must not be connected");
                XCTAssertTrue([_delegate onCloseCalled], @"On close has to be called");
            });
        } else {
            XCTFail(@"Has not connected!");
        }
        [self notify:kXCTUnitWaitStatusSuccess];
    });
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}

- (void) testRPCCallSum
{
    [self initClientAndDelegate];
    [self prepare];
    __weak MDWampClientTests *weakSelf = self;
    
    [_delegate setOnOpenCallback:^{
        [weakSelf notify:kXCTUnitWaitStatusSuccess];
    }];
    [_wc connect];
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
    // here we are connected connected
    
    [self prepare];
    [_wc call:@"http://example.com/simple/calc#add" complete:^(NSString *callURI, id result, NSError *error) {
        if (error== nil) {
            MDWampDebugLog(@"Got result from RPC %@", result);
            XCTAssertEqual([result intValue], 5, @"2 + 3 is not 5");
            [weakSelf notify:kXCTUnitWaitStatusSuccess];
        } else {
            XCTFail(@"RPC must not fail");
            [self notify:kXCTUnitWaitStatusFailure];
        }
    } args:@2, @3, nil];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
    
    // Failing call
    [self prepare];
    [_wc call:@"http://example.com/simple/calc#add" complete:^(NSString *callURI, id result, NSError *error) {
        if (error!= nil) {
            XCTAssertNotNil(error.description, @"RPC MUST Fail, we've passed wrong number of argument");
            MDWampDebugLog(@"error: %@", error.localizedDescription);
            [self notify:kXCTUnitWaitStatusSuccess];
        }
    } args:@2, nil];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}

- (void)testSimplePubSub
{
    [self initClientAndDelegate];
    [self prepare];
    __weak MDWampClientTests *weakSelf = self;
    
    static NSString *topic = @"http://example.com/simple";
    static NSString *payloadString = @"Foo";
    
    [_wc setOnConnectionOpen:^(MDWampClient *client){
        [client subscribeTopic:topic onEvent:^(id payload) {
            NSLog(@"%@", payload);
            XCTAssertEqualObjects(payload, payloadString, @"Must received the sent payload");
            [weakSelf notify:kXCTUnitWaitStatusSuccess];
        }];
    }];
    
    MDWampClient *anotherClient = [[MDWampClient alloc] initWithURL:[NSURL URLWithString:kMDWampTestsServerURL]];
    [anotherClient setOnConnectionOpen:^(MDWampClient *client){
        [client publish:payloadString toTopic:topic];
    }];
    
    [_wc connect];
    [anotherClient connect];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:5.0];
}

// TODO: make a valid unit test for CRA authentication, current wstest suite doesn't include cra auth
//
//
//- (void) testCRA
//{
//    [self initClientAndDelegate];
//    [self prepare];
//    __weak MDWampClientTests *weakSelf = self;
//    [_wc setOnConnectionOpen:^{
//        [weakSelf.wc authReqWithAppKey:nil andExtra:nil];
//        
//        wait_for_network(^{
//            XCTAssertTrue(weakSelf.delegate.onAuthReqWithAnswerCalled, @"on auth req not called on delegate");
//            [weakSelf notify:kXCTUnitWaitStatusSuccess];
//        });
//        
//    }];
//    [_wc connect];
//    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
//}

@end
