//
//  MDWampHello.m
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampHello.h"

@interface MDWampHello ()
@end


@implementation MDWampHello

- (id)initWithRoles:(NSArray*)roles
{
    self = [super init];
    if (self) {
        NSMutableDictionary *r = [[NSMutableDictionary alloc] init];
        for (NSString *role in roles) {
            // TODO: features of role???
            [r setObject:@{} forKey:role];
        }
        self.details = @{@"roles": r};
    }
    return self;
}

- (int)availableFromVersion
{
    return 2;
}

- (NSDictionary*)roles
{
    return self.details[@"roles"];
}

@end
