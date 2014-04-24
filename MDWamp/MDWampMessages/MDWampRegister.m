//
//  MDWampRegister.m
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampRegister.h"

@implementation MDWampRegister

// [REGISTER, Request|id, Options|dict, Procedure|uri]

- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        self.request = [tmp shift];
        self.options = [tmp shift];
        self.procedure = [tmp shift];
    }
    return self;
}

- (NSArray *)marshallFor:(MDWampVersion)version
{
    return @[@64, self.request, self.options, self.procedure];
}


@end
