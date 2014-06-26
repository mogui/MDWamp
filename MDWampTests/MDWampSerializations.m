//
//  MDWampSerializationJSONTests.m
//  MDWamp
//
//  Created by Niko Usai on 18/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDWampSerializations.h"

@interface MDWampSerializations : XCTestCase
{
    id<MDWampSerialization> ser;
}
@end

@implementation MDWampSerializations

- (void)setUp
{
    [super setUp];
    
}

- (void)testPackJson
{
    ser = [[MDWampSerializationJSON alloc] init];
    NSArray *a = @[@1, @2];
    NSString *json = [ser pack:a];
    XCTAssertEqualObjects(json, @"[1,2]", @"Must return correct json");
}

- (void)testUnpackJson
{
    ser = [[MDWampSerializationJSON alloc] init];
    NSString *json = @"[1,2]";
    NSArray *a = [ser unpack:json];
    NSArray *arr = @[@1,@2];
    XCTAssertEqualObjects(a, arr, @"Must return correct object");
}

- (void)testMsgpack {
    ser = [[MDWampSerializationMsgpack alloc] init];
    NSArray *a = @[@1, @2];
    NSData *s = [ser pack:a];
    XCTAssertEqualObjects(a, [ser unpack:s], @"Must be the same as start");
}



@end
