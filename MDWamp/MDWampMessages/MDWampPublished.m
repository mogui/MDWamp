//
//  MDWampPublished.m
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampPublished.h"

@implementation MDWampPublished


- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        self.request = [tmp shift];
        self.publication = [tmp shift];
    }
    return self;
}


- (NSArray *)marshallFor:(MDWampVersion)version
{
    if (version == kMDWampVersion1) {
        [NSException raise:NSInvalidArgumentException format:@"Message not supported"];
        return nil;
    } else {
        return @[@17, self.request, self.publication];
    }
}

@end
