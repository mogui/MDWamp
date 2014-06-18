//
//  MDWampWelcome.m
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampWelcome.h"

@implementation MDWampWelcome

- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];

        if ([tmp count] > 2) {
            self.session = [tmp shift];
            self.protocolVersion = [tmp shift];
            self.serverIdent = [tmp shift];
        } else {
            self.session = [tmp shift];
            self.details = [tmp shift];
        }
        
    }
    return self;
}


- (NSArray *)marshallFor:(MDWampVersion)version
{
    if ([version  isEqual: kMDWampVersion1]) {
        return @[
                 @0,
                 self.session,
                 self.protocolVersion,
                 self.serverIdent];
    } else {
        return @[
                 @2,
                 self.session,
                 self.details
                 ];
    }
}

- (NSDictionary *)roles
{
    return self.details[@"roles"];
}
@end
