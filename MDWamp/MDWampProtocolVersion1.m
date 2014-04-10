//
//  MDWampSpecV1.m
//  MDWamp
//
//  Created by Niko Usai on 06/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampProtocolVersion1.h"

enum {
	MDWampWelcomeCode       = 0,
	MDWampPrefixCode        = 1,
	MDWampCallCode          = 2,
	MDWampCallResultCode    = 3,
	MDWampCallErrorCode     = 4,
	MDWampSubscribeCode     = 5,
	MDWampUnsubscribeCode   = 6,
	MDWampPublishCode       = 7,
	MDWampEventCode         = 8
};

@implementation MDWampProtocolVersion1

- (NSArray *) marshallMessage:(MDWampMessage*)message
{
    return @[];
}

- (MDWampMessage *) unmarshallMessage:(NSString*)response
{
    return nil;
}

@end
