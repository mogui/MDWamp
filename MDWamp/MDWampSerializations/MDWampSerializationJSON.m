//
//  MDWampSerializationJSON.m
//  MDWamp
//
//  Created by Niko Usai on 09/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampSerializationJSON.h"

@implementation MDWampSerializationJSON

- (NSString*) packArgumentsWithArray:(NSArray*)arguments
{
    // TODO: check errors ?
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arguments options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString*) packArguments:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
	NSMutableArray *argArray = [[NSMutableArray alloc] init];
	va_list args;
    va_start(args, firstObj);
	
    for (id arg = firstObj; arg != nil; arg = va_arg(args, id)) {
		[argArray addObject:arg];
    }
	
    va_end(args);
	
	return [self packArgumentsWithArray:argArray];
}


@end
