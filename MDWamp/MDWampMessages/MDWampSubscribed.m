//
//  MDWampSubscribed.m
//  MDWamp
//
//  Created by Niko Usai on 10/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampSubscribed.h"

@implementation MDWampSubscribed

- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        self.request = [tmp shift];
        self.subscription = [tmp shift];
    }
    return self;
}


- (NSArray *)marshallFor:(MDWampVersion)version
{
    if ([version  isEqual: kMDWampVersion1]) {
        [NSException raise:NSInvalidArgumentException format:@"Message not supported"];
        return nil;
    } else {
        return @[@33, self.request, self.subscription];
    }
}


@end
