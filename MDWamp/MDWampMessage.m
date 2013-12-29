//
//  MDWampMessage.m
//  MDWamp
//
//  Created by pronk on 13/09/12.
//  Copyright (c) 2012 mogui. All rights reserved.
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

#import "MDWampMessage.h"
#import "MDJSONBridge.h"
@implementation MDWampMessage
@synthesize type;



/*
 * return the first element from the messageStack and removes it from the stack
 * it retain the object!!!
 */
- (id) shiftStack
{
	__autoreleasing id object = [messageStack objectAtIndex:0];
	[messageStack removeObjectAtIndex:0];
	return object;
}

- (int) shiftStackAsInt
{
	return [[self shiftStack] intValue];
}

- (NSString*) shiftStackAsString
{
	return (NSString*)[self shiftStack];
}

- (NSArray*) getRemainingArgs
{
	return [NSArray arrayWithArray:messageStack];
}

- (id) initWithResponseArray:(NSArray*)responseArray
{
	self = [super init];
	if (self) {
		messageStack = [[NSMutableArray alloc] initWithArray: responseArray];
		type = [[self shiftStack] intValue];
	}
	return self;
}

- (id) initWithResponse:(NSString*)response
{
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
	NSArray *responseArray = (NSArray*)[NSJSONSerialization JSONObjectWithData:data
                                                                       options:NSJSONReadingAllowFragments
                                                                         error:nil];
	return [self initWithResponseArray:responseArray];
}


@end
