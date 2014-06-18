//
//  MDWampSubscribe.m
//  MDWamp
//
//  Created by Niko Usai on 10/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampSubscribe.h"

@implementation MDWampSubscribe

- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        id first = [tmp shift];
        if ([first isKindOfClass:[NSString class]]) {
            // version 1 error
            self.topic = first;
        } else {
            self.request = first;
            self.options = [tmp shift];
            self.topic = [tmp shift];
        }
    }
    return self;
}

- (NSArray *)marshallFor:(MDWampVersion)version
{
    if ([version  isEqual: kMDWampVersion1]) {
        return @[@5, self.topic];
    } else {
        return @[@32, self.request, self.options, self.topic];
    }
}

@end
