//
//  MDWampClientConfig.h
//  MDWamp
//
//  Created by Niko Usai on 09/10/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kMDWampRolePublisher   ;
extern NSString * const kMDWampRoleSubscriber  ;
extern NSString * const kMDWampRoleCaller      ;
extern NSString * const kMDWampRoleCallee      ;

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
 *  Similar to what browsers do with the User-Agent HTTP header, 
 *  HELLO message MAY disclose the WAMP implementation in use to its peer
 */
@property (nonatomic, strong) NSString *agent;

/**
 *  returns a suitable Dictionary to be used as details settings for an HELLO message
 *
 *  @return NSDictionary hello details dictionary
 */
- (NSDictionary *) getHelloDetails;
@end
