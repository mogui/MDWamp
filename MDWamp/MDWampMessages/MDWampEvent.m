//
//  MDWampEvent.m
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampEvent.h"

@implementation MDWampEvent


- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        
        if ([tmp[0] isKindOfClass:[NSString class]]) {
            // version 1 PUBLISH
            // [ TYPE_ID_EVENT , topicURI , event ]
            self.topic = [tmp shift];
            self.argumentsKw = [tmp shift];
        } else {
            // [EVENT, SUBSCRIBED.Subscription|id, PUBLISHED.Publication|id, Details|dict, PUBLISH.Arguments|list, PUBLISH.ArgumentsKw|dict]

            self.subscription   = [tmp shift];
            self.publication    = [tmp shift];
            self.details        = [tmp shift];
            if ([tmp count] > 0) self.arguments     = [tmp shift];
            if ([tmp count] > 0) self.argumentsKw   = [tmp shift];
        }
    }
    return self;
}

- (NSArray *)marshallFor:(MDWampVersion)version
{
    if (version == kMDWampVersion1) {
        return @[@8, self.topic, self.event];
    } else {
        if (self.arguments && self.argumentsKw) {
            return @[@36, self.subscription, self.publication, self.details, self.arguments, self.argumentsKw ];
        } else if(self.arguments) {
            return @[@36, self.subscription, self.publication, self.details, self.arguments ];
        } else {
            return @[@36,self.subscription, self.publication, self.details];
        }
    }
}


- (NSDictionary *)event {
    return self.argumentsKw;
}

- (void)setEvent:(NSDictionary *)event {
    self.argumentsKw = event;
}

@end
