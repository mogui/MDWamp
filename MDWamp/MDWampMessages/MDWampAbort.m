//
//  MDWampAbort.m
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampAbort.h"

@implementation MDWampAbort

- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        self.details = [tmp shift];
        self.reason = [tmp shift];
    }
    return self;
}


- (NSArray *)marshallFor:(MDWampVersion)version
{
    if (version == kMDWampVersion1) {
        [NSException raise:NSInvalidArgumentException format:@"Message not supported"];
        return nil;
    } else {
        return @[
                 @3,
                 self.details,
                 self.reason
                 ];
    }
}

@end
