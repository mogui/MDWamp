//
//  MDWampHeartbeat.m
//  MDWamp
//
//  Created by Niko Usai on 26/08/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampHeartbeat.h"

@implementation MDWampHeartbeat
- (id)initWithPayload:(NSArray *)payload
{
    self = [super init];
    if (self) {
        NSMutableArray *tmp = [payload mutableCopy];
        // [HEARTBEAT, IncomingSeq|integer, OutgoingSeq|integer
        // [HEARTBEAT, IncomingSeq|integer, OutgoingSeq|integer, Discard|string]
        self.incomingSeq    = [tmp shift];
        self.outgoingSeq    = [tmp shift];
        if ([tmp count] > 0) self.discard     = [tmp shift];
    }
    return self;
}

- (NSArray *)marshall
{
    NSNumber *code = [[MDWampMessageFactory sharedFactory] codeFromObject:self];
    
    if (self.discard) {
        return @[code, self.incomingSeq, self.outgoingSeq, self.discard ];
    } else {
        return @[code, self.incomingSeq, self.outgoingSeq];
    }
}
@end
