//
//  MDWampUnsubscribed.m
//  MDWamp
//
//  Created by Niko Usai on 11/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampUnsubscribed.h"

@implementation MDWampUnsubscribed

- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        self.request = [tmp shift];
    }
    return self;
}


- (NSArray *)marshallFor:(MDWampVersion)version
{
    if (version == kMDWampVersion1) {
        [NSException raise:NSInvalidArgumentException format:@"Message not supported"];
        return nil;
    } else {
        return @[@35, self.request];
    }
}
@end
