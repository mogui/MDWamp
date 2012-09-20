//
//  MDJSONBridge.m
//  MDWamp
//
//  Created by pronk on 19/09/12.
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
