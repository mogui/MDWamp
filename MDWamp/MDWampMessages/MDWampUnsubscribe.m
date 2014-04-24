//
//  MDwampUnsubscribe.m
//  MDWamp
//
//  Created by Niko Usai on 11/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampUnsubscribe.h"

@implementation MDWampUnsubscribe
- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        if ([tmp[0] isKindOfClass:[NSString class]]) {
            self.topic = [tmp shift];
        } else {
            self.request = [tmp shift];
            self.subscription = [tmp shift];
        }
    }
    return self;
}


- (NSArray *)marshallFor:(MDWampVersion)version
{
    if (version == kMDWampVersion1) {
        return @[@6, self.topic];
    } else {
        return @[@34, self.request, self.subscription];
    }
}
@end
