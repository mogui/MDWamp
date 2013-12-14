//
//  MDWampClientTests.m
//  MDWamp
//
//  Created by Niko Usai on 13/12/13.
//  Copyright (c) 2013 mogui.it. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDWampTest.h"
#import "MDWampClient.h"

@interface MDWampClientTests : XCTestCase
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

- (void)initClientWithDelegate
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kMDWampTestsServerURL]];
    self.delegate = [[MDWampClientDelegateMock alloc] init];
    _wc = [[MDWampClient alloc] initWithURLRequest:request delegate:_delegate];
}

- (void) testInitWithRequestAndDelegate
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kMDWampTestsServerURL]];
    _wc = [[MDWampClient alloc] initWithURLRequest:request delegate:nil];
    XCTAssertNotNil(_wc, @"Inited ws client must not be nil");
}

- (void) testConnectWithValidServer
{
    [self initClientWithDelegate];
    [_wc connect];
    StartBlock();
    double delayInSeconds = kMDWampTestsNetworkWait;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        XCTAssertTrue([_delegate onOpenCalled], @"onOpen delegate method must have been called");
        XCTAssertTrue([_wc isConnected], @"Client must be connected");
        EndBlock();
    });
    WaitUntilBlockCompletes();
}

@end
