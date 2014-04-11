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
    switch ([code intValue]) {
        
        case 0:
            if (version == kMDWampVersion1)
                return [MDWampWelcome class];
            else
[NSException raise:NSInvalidArgumentException format:@"From version 2 of the protocol 0 code isn't used"];        
        case 1:
            if (version == kMDWampVersion1)
                return nil; //return [MDWampPrefix class];
            else
                return [MDWampHello class];
        case 2:
            if (version == kMDWampVersion1)
                return nil; //return [MDWampCall class];
            else
                return [MDWampWelcome class];
        case 3:
            if (version == kMDWampVersion1)
                return nil; //return [MDWampCallResult class];
            else
                return [MDWampAbort class];
            
        case 4:
            if (version == kMDWampVersion1)
                return nil; //return [MDWampCallError class];
            else
                //return [MDWampChallange class];
        case 5:
            if (version == kMDWampVersion1)
                return [MDWampSubscribe class];
            else
                //return [MDWampAuthenticate class];
        case 6:
            if (version == kMDWampVersion1)
                return [MDWampUnsubscribe class];
            else
                return [MDWampGoodbye class];
        case 7:
            if (version == kMDWampVersion1)
                return nil; //return [MDWampPublish class];
            else
//                return [MDWampHeartbeat class];
        case 8:
            if (version == kMDWampVersion1)
                return nil; //return [MDWampEvent class];
            else
                return [MDWampError class];
        case 16:
            if (version == kMDWampVersion2)
                return [MDWampError class];
        case 32:
                return [MDWampSubscribe class];
        case 33:
            return [MDWampSubscribed class];
        case 34:
            return [MDWampUnsubscribe class];
        case 35:
            return [MDWampUnsubscribed class];
        
        default:
            [NSException raise:NSInvalidArgumentException format:@"Invalid code"];
    }
    
    return nil;
}



@end
