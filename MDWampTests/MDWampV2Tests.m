//
//  MDWampV2Tests.m
//  MDWamp
//
//  Created by Niko Usai on 06/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"
#import "MDWampTestIncludes.h"
#import "MDWamp.h"

@interface MDWampV2Tests : XCTAsyncTestCase
@property (strong, nonatomic) MDWamp *wc;
@property (strong, nonatomic) MDWampClientDelegateMock *delegate;
@end

@implementation MDWampV2Tests

- (void)setUp
{
    [super setUp];
    [self prepare];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kMDWampTestsServerV2URL]];
    _wc = [[MDWamp alloc] initWithURLRequest:request delegate:nil];
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void) testConnectHandshake
{
    _wc.subprotocols = @[kMDWampSubprotocolWamp2JSON];
    [_wc connect];
    wait_for_network(^{
        [self notify:kXCTUnitWaitStatusSuccess];
    });
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:5.0];
   
}


@end
