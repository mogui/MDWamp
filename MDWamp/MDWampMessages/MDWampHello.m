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
        NSMutableDictionary *roles = [[NSMutableDictionary alloc] init];
        for (NSString *role in roles) {
            // TODO: features of role???
            [roles setObject:@{} forKey:role];
        }
        self.details = @{@"roles": roles};
    }
    return self;
}

- (int)availableFromVersion
{
    return 2;
}



@end
