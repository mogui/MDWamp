//
//  MDWampHello.m
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampHello.h"

@interface MDWampHello ()
@end


@implementation MDWampHello

- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        self.realm = [tmp shift];
        self.details = [tmp shift];

    }
    return self;
}

- (NSArray *) marshallFor:(MDWampVersion)version
{
    if (version < kMDWampVersion2) {
        [NSException raise:NSInvalidArgumentException format:@"Message not supported"];
        return nil;
    }
    return @[
             [NSNumber numberWithInt:1],
                 self.realm,
                 self.details
                 ];
    
}

- (NSDictionary*)roles
{
    return self.details[@"roles"];
}

@end
