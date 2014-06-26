//
//  MDWampSerializationJSON.m
//  MDWamp
//
//  Created by Niko Usai on 09/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampSerializationJSON.h"

@implementation MDWampSerializationJSON

- (id) pack:(NSArray*)arguments
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arguments options:0 error:&error];
    if (error) {
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSArray*) unpack:(id)data
{
    NSData *d = data;
    if (![data isKindOfClass:[NSData class]]) {
        d = [(NSString*)data dataUsingEncoding:NSUTF8StringEncoding];
    }
	return [NSJSONSerialization JSONObjectWithData:d  options:NSJSONReadingAllowFragments error:nil];
}


@end
