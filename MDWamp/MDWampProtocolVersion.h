//
//  MDWampSpec.h
//  MDWamp
//
//  Created by Niko Usai on 06/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"

#define MDWampMessageCode(str)

@class MDWamp;
@protocol MDWampProtocolVersion <NSObject>

/**
 *  Call just after connection is established to know if protocol 
 *  must send an HELLO msg to initiate a connection (needed from vesion 2)
 */
- (BOOL) shouldSendHello;

/**
 *  Call just before disconnection to know if protocol version has to
 *  send a Goodbye msg and wait for the response to close the session
 */
- (BOOL) shouldSendGoodbye;

/**
 *  Return a corrected message pack for the given implementation 
 * in terms of order and parameters
 *
 *  @param message the message
 *
 *  @return array of objects
 */
- (NSArray *) marshallMessage:(MDWampMessage*)message;

/**
 * return a valid message by parsing a raw list of params
 *
 *  @param response a list of objects
 *
 *  @return a valid message
 */
- (MDWampMessage *) unmarshallMessage:(NSArray*)response;

@end
