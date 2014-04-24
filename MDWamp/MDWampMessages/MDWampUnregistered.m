//
//  MDWampUnregistered.m
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampUnregistered.h"

@implementation MDWampUnregistered
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
    return @[@67, self.request];
}

@end
