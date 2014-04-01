//
//  MDWampClient.h
//  MDWamp
//
//  Created by Niko Usai on 13/12/13.
//  Copyright (c) 2013 mogui.it. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MDWampConstants.h"
#import "MDWampTransport.h"
#import "MDWampClientDelegate.h"
#import "MDWampMessages.h"

/**
 *  Wamp - Roles
 */
extern NSString * const kMDWampRolePublisher   ;
extern NSString * const kMDWampRoleSubscriber  ;
extern NSString * const kMDWampRoleCaller      ;
extern NSString * const kMDWampRoleCallee      ;


@interface MDWamp : NSObject


/**
 * The server generated sessionId
 */
@property (nonatomic, copy, readonly) NSString *sessionId;

/**
 * Protocol version choosed by the transport
 */
@property (nonatomic, readonly) MDWampVersion version;

/**
 * Serialization choosed by the transport
 */
@property (nonatomic, readonly) MDWampSerialization serialization;



/**
 * The delegate must implement the MDWampClientDelegate
 * it is not retained
 */
@property (nonatomic, unsafe_unretained) id<MDWampClientDelegate> delegate;

/**
 * If implemented gets called when client connects
 */
@property (nonatomic, copy) void (^onConnectionOpen)(MDWamp *client);

/**
 * If implemented gets called when client close the connection, or fails to connect
 */
@property (nonatomic, copy) void (^onConnectionClose)(MDWamp *client, NSInteger code, NSString *reason);



/**
 *  An array of MDWampRoles the client will assume on connection
 *  default is all roles TODO: what makes sense to do with feature of advanced protocol??
 */
@property (nonatomic, strong) NSArray *roles;

/**
 *  A map of Class name that immplements a given serialization (which is the key in the dict) it has a default map that can be changed
 */
@property (nonatomic, strong) NSDictionary *serializationInstanceMap;

/**
 * Indicates whether or not MDWamp tries to reconnect after a non implicit disconnection
 */
@property (nonatomic, assign) BOOL shouldAutoreconnect;

/**
 * The seconds between each reconnection try
 */
@property (nonatomic, assign) NSTimeInterval autoreconnectDelay;

/**
 * The maximum times MDWamp will try to reconnect
 */
@property (nonatomic, assign) NSInteger autoreconnectMaxRetries;


#pragma mark - 
#pragma mark Init methods
/**
 *  Returns a new istance with connection configured with given server
 *  it does not automatically connect to the ws server
 *
 *  @param aServer  an url request with full protocol
 *  @param realm    a WAMP routing and administrative domain
 *  @param delegate The connection delegate for this instance
 *
 *  @return client instance
 */
- (id)initWithURL:(NSURL *)aServer realm:(NSString *)realm delegate:(id<MDWampClientDelegate>)delegate;


#pragma mark -
#pragma mark Connection

/**
 * Start the connection with the server
 */
- (void) connect;

/**
 * Disconnect from the server
 */
- (void) disconnect;

/**
 * Handles clean disconnection e reconnection
 */
- (void) reconnect;

/**
 * Returns whether or not we are connected to the server
 * @return BOOL yes if connected
 */
- (BOOL) isConnected;

#pragma mark -
#pragma mark Commands
/**
 * Sets the prefix Uri to share with the server
 * so we can in future calls of other methods use CURIEs instead of full URIs
 * see http://wamp.ws/spec#uris_and_curies for details
 *
 * @param prefix		a string to be used as prefix
 * @param uri			the URI which is subsequently to be abbreviated using the prefix.
 */
- (void) prefix:(NSString*)prefix uri:(NSString*)uri;

#pragma mark -
#pragma mark AUTH WAMP-CRA

/**
 * Issues an authentication request
 *
 * @param appKey		Authentication key, i.e. user or application name
 *                      If undefined, anonymous authentication is performed
 * @param extra			Authentication extra information - optional
 */
- (void) authReqWithAppKey:(NSString *)appKey andExtra:(NSString *)extra;


/**
 * Signs an authentication challenge
 *
 * @param challenge		Authentication challenge as returned by the WAMP server upon a authentication request
 * @param secret		Authentication secret
 */
- (void) authSignChallenge:(NSString *)challenge withSecret:(NSString *)secret;


/**
 * Authenticate, finishing the authentication handshake
 *
 * @param signature		A authentication signature
 */
- (void) authWithSignature:(NSString *)signature;


/**
 * Authenticate websocket with wamp-cra; same protocol as above methods but in single call
 *
 * @param authKey		Authentication key, i.e. user or application name
 *                      If undefined, anonymous authentication is performed
 * @param authExtra			Authentication extra information - optional
 * @param secret		Authentication secret (ie password)
 * @param successBlock  Block to be executed upon sucessful authentication
 * @param errorBlock    Block to be executed upon error during authentication
 */
-(void) authWithKey:(NSString*)authKey Secret:(NSString*)authSecret Extra:(NSString*)authExtra
            Success:(void(^)(NSString* answer)) successBlock
              Error:(void(^)(NSString* procCall, NSString* errorURI, NSString* errorDetails)) errorBlock;

#pragma mark -
#pragma mark RPC
/**
 * Call a Remote Procedure on the server
 * returns the string callID (unique identifier of the call)
 *
 * @param procUri		the URI of the remote procedure to be called
 * @param completeBlock block to be executed on complete if success error is nil, if failure result is nil
 * @param args			zero or more call arguments
 */
- (NSString*) call:(NSString*)procUri
          complete:(void(^)(NSString* callURI, id result, NSError *error))completeBlock
              args:(id)firstArg, ... NS_REQUIRES_NIL_TERMINATION;


#pragma mark -
#pragma mark Pub/Sub

/**
 * Subscribe for a given topic
 *
 * @param topicUri		the URI of the topic to which subscribe
 * @param eventBlock    The Block invoked when an event on the topic is received
 */
- (void) subscribeTopic:(NSString *)topicUri onEvent:(void(^)(id payload))eventBlock;

/**
 * Unsubscribe for a given topic
 *
 * @param topicUri		the URI of the topic to which unsubscribe
 */
- (void) unsubscribeTopic:(NSString *)topicUri;

/**
 * Unubscribe from all subscribed topic
 */
- (void) unsubscribeAll;

/**
 * Publish something to the given topic
 *
 * @param topicUri		the URI of the topic to which publish
 * @param excludeMe		Whether or not exclude caller from the pushing of this event
 */
- (void)publish:(id)payload toTopic:(NSString *)topicUri excludeMe:(BOOL)excludeMe;


/**
 * Shortand for publish not excluding caller from event's receiver
 *
 * @param topicUri		the URI of the topic to which publish
 */
- (void)publish:(id)event toTopic:(NSString *)topicUri;

@end
