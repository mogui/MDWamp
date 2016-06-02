//
//  MDWampSerializationMock.m
//  MDWamp
//
//  Created by Niko Usai on 12/03/14.
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

#import "MDWampSerializationMock.h"

@implementation MDWampSerializationMock

- (id) pack:(NSArray*)arguments;
{
    return arguments;
}

- (NSArray*) unpack:(id)data
{
    return data;
}

- (NSData*) packArguments:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray *argArray = [[NSMutableArray alloc] init];
	va_list args;
    va_start(args, firstObj);
	
    for (id arg = firstObj; arg != nil; arg = va_arg(args, id)) {
		[argArray addObject:arg];
    }
	
    va_end(args);
	
	return [self pack:argArray];
}

@end
