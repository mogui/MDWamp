//
//  MDWampClientConfig.h
//  MDWamp
//
//  Created by Niko Usai on 09/10/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>

// ROles
extern NSString* const kMDWampRolePublisher;
extern NSString* const kMDWampRoleSubscriber;
extern NSString* const kMDWampRoleCaller;
extern NSString* const kMDWampRoleCallee;

// Auth methods
extern NSString* const kMDWampAuthMethodCRA;
extern NSString* const kMDWampAuthMethodTicket;

@interface MDWampClientConfig : NSObject

/**
 *  An array of MDWampRoles the client will assume on connection
 *  default is all roles TODO: what makes sense to do with feature of advanced protocol??
 */
@property (nonatomic, strong) NSDictionary *roles;

/**
 * Interval between each heartbeat
 * default is: 0 meaning no heartbeat will be triggered
 */
@property (nonatomic, assign) double heartbeatInterval;

/**
 *  Shared secret to use in wampCRA
 */
@property (nonatomic, strong) NSString *sharedSecret;

/**
 *  Ticket used with ticket-based Auth
 */
@property (nonatomic, strong) NSString *ticket;

/**
 *  Similar to what browsers do with the User-Agent HTTP header, 
 *  HELLO message MAY disclose the WAMP implementation in use to its peer
 */
@property (nonatomic, strong) NSString *agent;

/**
 *  list of authentication method that client is willing to use, currently implemented are:
 *      wampcra - WAMP Challenge-Response Authentication
 */
@property (nonatomic, strong) NSArray *authmethods;

/**
 *  the authentication ID (e.g. username) the client wishes to authenticate as
 */
@property (nonatomic, strong) NSString *authid;

/**
 *  Block used to defer the signing of a Wamp CRA challange
 * in the block you do your processing to sign the challange (async if you need)
 * once getted the signature call
 */
@property (nonatomic, strong) void (^deferredWampCRASigningBlock)( NSString *challange, void(^finishBLock)(NSString *signature) );

/**
 *  returns a suitable Dictionary to be used as details settings for an HELLO message
 *
 *  @return NSDictionary hello details dictionary
 */
- (NSDictionary *) getHelloDetails;



@end