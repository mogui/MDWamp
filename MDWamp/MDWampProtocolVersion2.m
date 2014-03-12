//
//  MDWampSpecV2.m
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampProtocolVersion2.h"
#import "NSMutableArray+MDStack.h"

#import "MDWampHello.h"
#import "MDWampWelcome.h"
#import "MDWampAbort.h"

#import "MDWampGoodbye.h"
#import "MDWampError.h"
#import "MDWamp.h"
#define toS(S) @#S

enum {
    MDWampHelloCode         = 0,
    MDWampWelcomeCode       = 1,
    MDWampAbortCode         = 2,
    MDWampChallangeCode     = 3,
    MDWampAuthenticateCode  = 4,
    MDWampGoodbyeCode       = 5,
    MDWampHeartbitCode      = 6,
    MDWampErrorCode         = 7,
};

@implementation MDWampProtocolVersion2

- (BOOL) shouldSendHello
{
    return YES;
}

- (BOOL) shouldSendGoodbye
{
    return NO;
}

- (NSArray *) makeMessage:(MDWampMessage*)message
{
    NSString *msg = [NSStringFromClass([message class]) stringByAppendingString:@"Code"];
    
    if ([msg isEqualToString:toS(MDWampHelloCode)]) {
        // HELLO
        MDWampHello *msg = (MDWampHello *) message;
        return @[
                 [NSNumber numberWithInt:MDWampHelloCode],
                 msg.realm,
                 msg.details
                 ];
        
    } else if ([msg isEqualToString:toS(MDWampWelcomeCode)]) {
        // WELCOME
        MDWampWelcome *msg = (MDWampWelcome *) message;
        return @[
                 [NSNumber numberWithInt:MDWampWelcomeCode],
                 msg.session,
                 msg.details
                 ];
        
    } else {
        // fail not available command
        return nil;
    }
}

- (MDWampMessage *) parseMessage:(NSMutableArray *)response
{
    // switch sul primo parametro un int
    // per capire che messaggio è ed instanzio l'oggetto giusto
    // e lo setto per bene

    int code = [[response shift] intValue];
    
    if (code == MDWampHelloCode) {
        MDWampHello *msg = [[MDWampHello alloc] init];
        msg.realm = [response shift];
        msg.details = [response shift];
        return msg;
        
    } else if (code == MDWampWelcomeCode) {
        MDWampWelcome *msg = [[MDWampWelcome alloc] init];
        msg.session = [response shift];
        msg.details = [response shift];
        return msg;
        
    } else {
            // fail not available command
        return nil;
    }
    
}

@end
