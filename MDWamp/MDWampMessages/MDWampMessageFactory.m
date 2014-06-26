//
//  MDWampMessageFactory.m
//  MDWamp
//
//  Created by Niko Usai on 01/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampMessageFactory.h"
#import "MDWampMessages.h"

@implementation MDWampMessageFactory

+ (Class) messageClassFromCode:(NSNumber*)code forVersion:(MDWampVersion)version
{
    if ([version intValue] < [kMDWampVersion2 intValue] && [code intValue] > 8) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid code"];
    }
    
    switch ([code intValue]) {

        case 0:
            if ([version intValue] < [kMDWampVersion2 intValue])
                return [MDWampWelcome class];
            else
[NSException raise:NSInvalidArgumentException format:@"From version 2 of the protocol 0 code isn't used"];        
        case 1:
            if ([version intValue] < [kMDWampVersion2 intValue])
                return nil; //return [MDWampPrefix class];
            else
                return [MDWampHello class];
        case 2:
            if ([version intValue] < [kMDWampVersion2 intValue])
                return [MDWampCall class];
            else
                return [MDWampWelcome class];
        case 3:
            if ([version intValue] < [kMDWampVersion2 intValue])
                return [MDWampResult class];
            else
                return [MDWampAbort class];
            
        case 4:
            if ([version intValue] < [kMDWampVersion2 intValue])
                return [MDWampError class];
            else
                //return [MDWampChallange class];
        case 5:
            if ([version intValue] < [kMDWampVersion2 intValue])
                return [MDWampSubscribe class];
            else
                //return [MDWampAuthenticate class];
        case 6:
            if ([version intValue] < [kMDWampVersion2 intValue])
                return [MDWampUnsubscribe class];
            else
                return [MDWampGoodbye class];
        case 7:
            if ([version intValue] < [kMDWampVersion2 intValue])
                return [MDWampPublish class];
            else
//                return [MDWampHeartbeat class];
        case 8:
            if ([version intValue] >= [kMDWampVersion2 intValue])
                return [MDWampError class];
            else
                return [MDWampEvent class];

        case 16:
            return [MDWampPublish class];
        case 17:
            return [MDWampPublished class];
            
        case 32:
                return [MDWampSubscribe class];
        case 33:
            return [MDWampSubscribed class];
        case 34:
            return [MDWampUnsubscribe class];
        case 35:
            return [MDWampUnsubscribed class];
        case 36:
            return [MDWampEvent class];

        case 48:
            return [MDWampCall class];
        case 49:
            // return [MDWampCancel class]; // Advanced Protocol
        case 50:
            return [MDWampResult class];
            
        case 64:
            return [MDWampRegister class];
        case 65:
            return [MDWampRegistered class];
        case 66:
            return [MDWampUnregister class];
        case 67:
            return [MDWampUnregistered class];
        case 68:
            return [MDWampInvocation class];
        case 69:
            // return [MDWampInterrupt class]; // Advanced Protocol
        case 70:
            return [MDWampYield class];
        
        default:
            [NSException raise:NSInvalidArgumentException format:@"Invalid code"];
    }
    
    return nil;
}



@end
