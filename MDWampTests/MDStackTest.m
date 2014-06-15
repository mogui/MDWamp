//
//  MDStackTest.m
//  MDWamp
//
//  Created by Niko Usai on 15/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSMutableArray+MDStack.h"
@interface MDStackTest : XCTestCase {
    NSMutableArray *arr;
}

@end

@implementation MDStackTest

- (void)setUp
{
    [super setUp];
    arr = [@[@1, @2, @3] mutableCopy];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPush
{
    [arr push:@4];
    XCTAssertEqual([arr count], 4, @"element must be added");
    XCTAssertEqualObjects(arr[3], @4, @"last element should be the one we added");
}

- (void)testPop {
    NSNumber *a = [arr pop];
    XCTAssertEqual([arr count], 2, @"element must be removede when popped");
    XCTAssertEqualObjects(a, @3, @"last element should be the last of the array");

}

- (void)testShift {
    NSNumber *a = [arr shift];
    XCTAssertEqual([arr count], 2, @"element must be removede when shifted");
    XCTAssertEqualObjects(a, @1, @"last element should be the first of the array");
}

- (void)testUnshift {
    [arr unshift:@0];
    XCTAssertEqual([arr count], 4, @"element must be added");
    XCTAssertEqualObjects(arr[0], @0, @"first element should be the one we added");
}

@end
