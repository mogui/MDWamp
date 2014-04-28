//
//  MDWampCall.m
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampCall.h"

@implementation MDWampCall

- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        
        if ([tmp[0] isKindOfClass:[NSString class]]) {
            // version 1 PUBLISH
            // [ TYPE_ID_CALL , callID , procURI , ... ]
            self.callID     = [tmp shift];
            self.procedure  = [tmp shift];
            NSMutableArray *tmpArgs = [[NSMutableArray alloc] init];
            while ([tmp count] > 0) {
                [tmpArgs addObject:[tmp shift]];
            }
            
            if ([tmpArgs count] > 0)
                self.arguments = tmpArgs;
            
        } else {
            // [CALL, Request|id, Options|dict, Procedure|uri, Arguments|list, ArgumentsKw|dict]

            
            self.request        = [tmp shift];
            self.options    = [tmp shift];
            self.procedure        = [tmp shift];
            if ([tmp count] > 0) self.arguments     = [tmp shift];
            if ([tmp count] > 0) self.argumentsKw   = [tmp shift];
        }
    }
    return self;
}

- (NSArray *)marshallFor:(MDWampVersion)version
{
    if (version == kMDWampVersion1) {
        if ([self.arguments count] > 0) {
            NSMutableArray *tmpCall = [[NSMutableArray alloc] initWithObjects:@2, self.callID, self.procedure, nil];
            for (int i=0; i < [self.arguments count]; i++) {
                [tmpCall addObject:self.arguments[i]];
            }
            NSArray *arr = [NSArray arrayWithArray:tmpCall];
            return arr;
        } else {
            return @[@2, self.callID, self.procedure];
        }
        
        
    } else {
        if (self.arguments && self.argumentsKw) {
            return @[@48, self.request, self.options, self.procedure, self.arguments, self.argumentsKw ];
        } else if(self.arguments) {
            return @[@48, self.request, self.options, self.procedure, self.arguments ];
        } else {
            return @[@48,self.request, self.options, self.procedure];
        }
    }
}

@end
