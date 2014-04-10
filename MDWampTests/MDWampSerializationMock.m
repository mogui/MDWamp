//
//  MDWampSerializationMock.m
//  MDWamp
//
//  Created by Niko Usai on 12/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
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
