//
//  MDWampMessageFactoryTests.m
//  MDWamp
//
//  Created by Niko Usai on 01/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDWampMessageFactory.h"
#import "MDWampMessages.h"
@interface MDWampMessageFactoryTests : XCTestCase

@end

@implementation MDWampMessageFactoryTests

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

- (Class)v2Class:(NSNumber*)code
{
    return [MDWampMessageFactory messageClassFromCode:code forVersion:kMDWampVersion2];
}

- (Class)v1Class:(NSNumber*)code
{
    return [MDWampMessageFactory messageClassFromCode:code forVersion:kMDWampVersion1];
}

- (void)testVersion1Messages
{
    
    XCTAssert([[self v1Class:@0] isSubclassOfClass:[MDWampWelcome class]], @"0 is Welcome");
    
    XCTAssert([[self v1Class:@5] isSubclassOfClass:[MDWampSubscribe class]], @"5 is Subscribe");
}

- (void)testVersion2Messages
{
    
    XCTAssertThrows([self v2Class:@0], @"zero code in version 2 doesn't exist");

    XCTAssert([[self v2Class:@1] isSubclassOfClass:[MDWampHello class]], @"1 is Hello");

    XCTAssert([[self v2Class:@2] isSubclassOfClass:[MDWampWelcome class]], @"2 is Welcome");
    
    XCTAssert([[self v2Class:@3] isSubclassOfClass:[MDWampAbort class]], @"3 is Abort");
    
    XCTAssert([[self v2Class:@6] isSubclassOfClass:[MDWampGoodbye class]], @"6 is Goodbye");
    
    XCTAssert([[self v2Class:@8] isSubclassOfClass:[MDWampError class]], @"8 is Error");
    
    XCTAssert([[self v2Class:@32] isSubclassOfClass:[MDWampSubscribe class]], @"32 is Subscribe");
    
    XCTAssert([[self v2Class:@33] isSubclassOfClass:[MDWampSubscribed class]], @"33 is Subscribed");
    
}

@end
