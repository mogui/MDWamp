//
//  MDWampInvocation.m
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampInvocation.h"

@implementation MDWampInvocation


- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        // [INVOCATION, Request|id, REGISTERED.Registration|id, Details|dict, CALL.Arguments|list, CALL.ArgumentsKw|dict]
        
        self.request   = [tmp shift];
        self.registration    = [tmp shift];
        self.details        = [tmp shift];
        if ([tmp count] > 0) self.arguments     = [tmp shift];
        if ([tmp count] > 0) self.argumentsKw   = [tmp shift];
    }
    return self;
}

- (NSArray *)marshallFor:(MDWampVersion)version
{
    if (self.arguments && self.argumentsKw) {
        return @[@68, self.request, self.registration, self.details, self.arguments, self.argumentsKw ];
    } else if(self.arguments) {
        return @[@68, self.request, self.registration, self.details, self.arguments ];
    } else {
        return @[@68, self.request, self.registration, self.details];
    }
}

@end
