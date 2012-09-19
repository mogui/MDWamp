//
//  MDJSONBridge.m
//  MDWamp
//
//  Created by pronk on 19/09/12.
//  Copyright (c) 2012 mogui. All rights reserved.
//

#import "MDJSONBridge.h"
#import "JSONKit.h"

@implementation MDJSONBridge
+ (id)objectFromJSONString:(NSString*)jsonString
{
	//Class cls = NSClassFromString (@"NSJSONSerialization");
	if ([NSJSONSerialization class]) {
		return [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
	} else {
		if (NSClassFromString(@"JSONDecoder") == nil) {
			[NSException raise:@"MDJSONParserNotAvailable"
						format:@"No JSON parser available. To support iOS4, you should link JSONKit to your project."];
		}
		return [jsonString objectFromJSONString];
	}
	
}
+ (NSString *)jsonStringFromObject:(id)object
{
	
	NSString *jsonString;
	// asd
	if ([NSJSONSerialization class]) {
		jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:object options:0 error:nil] encoding:NSUTF8StringEncoding];
	} else {
		if (NSClassFromString(@"JSONDecoder") == nil) {
			[NSException raise:@"MDJSONParserNotAvailable"
						format:@"No JSON parser available. To support iOS4, you should link JSONKit to your project."];
		}
		jsonString = [object JSONString];
	}
	return jsonString;
}

@end
