//
//  MDWampClientConfigTests.m
//  MDWamp
//
//  Created by Niko Usai on 09/10/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDWampClientConfig.h"

#define ROLES @{@"some role" : @"other"}
#define AGENT @"MDWamp v 2.10"

@interface MDWampClientConfigTests : XCTestCase {
    MDWampClientConfig *conf;
}
@end

@implementation MDWampClientConfigTests

- (void)setUp {
    [super setUp];
    conf = [[MDWampClientConfig alloc] init];
    conf.roles = ROLES;
    conf.heartbeatInterval = 2;
    conf.agent = AGENT;
    conf.authmethods = @[];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testGetHelloDetails {
    // This is an example of a functional test case.
    NSDictionary *d =  @{@"roles" : ROLES, @"agent" : AGENT, @"authmetods":@[]};
    NSDictionary *hello = [conf getHelloDetails];
    XCTAssertEqualObjects(d, hello, @"Not proper details dictionary returned");
}

@end
