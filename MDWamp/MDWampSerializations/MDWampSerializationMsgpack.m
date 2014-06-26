//
//  MDWampSerializationMsgpack.m
//  MDWamp
//
//  Created by Niko Usai on 24/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampSerializationMsgpack.h"
#import "MessagePack.h"

@implementation MDWampSerializationMsgpack
- (id) pack:(NSArray*)arguments
{
    return [arguments messagePack];
}

- (NSArray*) unpack:(id)data
{
    NSData *d = data;
    if (![data isKindOfClass:[NSData class]]) {
        d = [(NSString*)data dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [d messagePackParse];
}
@end
