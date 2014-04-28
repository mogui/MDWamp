//
//  MDWampYield.m
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampYield.h"

@implementation MDWampYield


- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        // [YIELD, INVOCATION.Request|id, Options|dict, Arguments|list, ArgumentsKw|dict]

        self.request   = [tmp shift];
        self.options    = [tmp shift];
        if ([tmp count] > 0) self.arguments     = [tmp shift];
        if ([tmp count] > 0) self.argumentsKw   = [tmp shift];
    }
    return self;
}

- (NSArray *)marshallFor:(MDWampVersion)version
{
    if (self.arguments && self.argumentsKw) {
        return @[@70, self.request, self.options, self.arguments, self.argumentsKw ];
    } else if(self.arguments) {
        return @[@70, self.request, self.options, self.arguments ];
    } else {
        return @[@70, self.request, self.options];
    }
}


@end
