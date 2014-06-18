//
//  MDWampResult.m
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampResult.h"

@implementation MDWampResult



- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        
        if ([tmp[0] isKindOfClass:[NSString class]]) {
            // version 1 PUBLISH
            // [ TYPE_ID_CALLRESULT , callID , result ]
            
            self.callID = [tmp shift];
            self.result = [tmp shift];
        } else {
            // [RESULT, CALL.Request|id, Details|dict, YIELD.Arguments|list, YIELD.ArgumentsKw|dict]

            self.request   = [tmp shift];
            self.details    = [tmp shift];
            if ([tmp count] > 0) self.arguments     = [tmp shift];
            if ([tmp count] > 0) self.argumentsKw   = [tmp shift];
        }
    }
    return self;
}

- (NSArray *)marshallFor:(MDWampVersion)version
{
    if ([version  isEqual: kMDWampVersion1]) {
        return @[@3, self.callID, self.result];
    } else {
        if (self.arguments && self.argumentsKw) {
            return @[@50, self.request, self.details, self.arguments, self.argumentsKw ];
        } else if(self.arguments) {
            return @[@50, self.request, self.details, self.arguments ];
        } else {
            return @[@50, self.request, self.details];
        }
    }
}

- (void)setResult:(id)result
{
    self.arguments = @[result];
}

- (id)result
{
    return self.arguments[0];
}
@end
