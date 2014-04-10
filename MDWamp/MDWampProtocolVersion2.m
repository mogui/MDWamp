//
//  MDWampSpecV2.m
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampProtocolVersion2.h"
#import "NSMutableArray+MDStack.h"

#import "MDWampMessages.h"
#import "MDWamp.h"

#define toS(S) @#S

enum {
    MDWampHelloCode         = 1,
    MDWampWelcomeCode          ,
    MDWampAbortCode            ,
    MDWampChallangeCode        ,
    MDWampAuthenticateCode     ,
    MDWampGoodbyeCode          ,
    MDWampHeartbitCode         ,
    MDWampErrorCode            ,
};


@implementation MDWampProtocolVersion2

- (BOOL) shouldSendHello
{
    return YES;
}

- (BOOL) shouldSendGoodbye
{
    return YES;
}

- (NSArray *) marshallMessage:(MDWampMessage*)message
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
    } else if ([msg isEqualToString:toS(MDWampAbortCode)]) {
        // ABort
        MDWampAbort *msg = (MDWampAbort *) message;
        return @[
                 [NSNumber numberWithInt:MDWampAbortCode],
                 msg.details,
                 msg.reason
                 ];
    } else if ([msg isEqualToString:toS(MDWampGoodbyeCode)]) {
        // GOODBYE
        MDWampGoodbye *msg = (MDWampGoodbye *) message;
        return @[
                 [NSNumber numberWithInt:MDWampGoodbyeCode],
                 msg.details,
                 msg.reason
                 ];
    } else if ([msg isEqualToString:toS(MDWampErrorCode)]) {
        // ERROR
        MDWampError *msg = (MDWampError *) message;
        return @[
                 [NSNumber numberWithInt:MDWampErrorCode],
                 msg.type,
                 msg.request,
                 msg.details,
                 msg.error,
                 msg.arguments,
                 msg.argumentsKw
                 ];
    } else {
        // fail not available command
        return nil;
    }
}

- (MDWampMessage *) unmarshallMessage:(NSArray *)response
{
    // switch sul primo parametro un int
    // per capire che messaggio è ed instanzio l'oggetto giusto
    // e lo setto per bene
    NSMutableArray *tmpMessage = [response mutableCopy];
    int code = [[tmpMessage shift] intValue];
    
    if (code == MDWampHelloCode) {
        MDWampHello *msg = [[MDWampHello alloc] init];
        msg.realm = [tmpMessage shift];
        msg.details = [tmpMessage shift];
        return msg;
        
    } else if (code == MDWampWelcomeCode) {
        MDWampWelcome *msg = [[MDWampWelcome alloc] init];
        msg.session = [tmpMessage shift];
        msg.details = [tmpMessage shift];
        return msg;
        
    } else if (code == MDWampAbortCode) {
        MDWampAbort *msg = [[MDWampAbort alloc] init];
        msg.details = [tmpMessage shift];
        msg.reason = [tmpMessage shift];
        return msg;
        
    } else if (code == MDWampGoodbyeCode) {
        MDWampGoodbye *msg = [[MDWampGoodbye alloc] init];
        msg.details = [tmpMessage shift];
        msg.reason = [tmpMessage shift];
        return msg;
    
    } else if (code == MDWampErrorCode) {
        MDWampError *msg = [[MDWampError alloc] init];
        msg.type = [tmpMessage shift];
        msg.request = [tmpMessage shift];
        msg.details = [tmpMessage shift];
        msg.error = [tmpMessage shift];
        msg.arguments = [tmpMessage shift];
        msg.argumentsKw = [tmpMessage shift];
        return msg;
    
    } else {
            // fail not available command
        return nil;
    }
    
}

@end
