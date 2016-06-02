//
//  MDWampSerializationJSONTests.m
//  MDWamp
//
//  Created by Niko Usai on 18/06/14.
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
    XCTAssertEqualObjects(json , @"[1,2]" , @"Must return correct json");
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
