//
//  MDWampProtocolVersionMock.m
//  MDWamp
//
//  Created by Niko Usai on 12/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampProtocolVersionMock.h"

@implementation MDWampProtocolVersionMock

- (id)init
{
    self = [super init];
    if (self) {
        self.sendHello = YES;
        self.sendGoodbye = YES;
    }
    return self;
}

- (BOOL) shouldSendHello
{
    return self.sendHello;
}

- (BOOL) shouldSendGoodbye
{
    return self.sendGoodbye;
}

/**
 *  Return a corrected message pack for the given implementation
 * in terms of order and parameters
 *
 *  @param message the message
 *
 *  @return array of objects
 */
- (NSArray *) makeMessage:(MDWampMessage*)message
{
    NSString *messageName = NSStringFromClass([message class]);
    return @[messageName];
}

/**
 * return a valid message by parsing a raw list of params
 *
 *  @param response a list of objects
 *
 *  @return a valid message
 */
- (MDWampMessage *) parseMessage:(NSMutableArray*)response
{
    Class msg = NSClassFromString(response[0]);
    return [[msg alloc] init];
}

@end
