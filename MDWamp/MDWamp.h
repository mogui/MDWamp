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

typedef NS_ENUM(NSInteger, MDWampConnectionCloseCode) {
    MDWampConnectionAborted,
    MDWampConnectionClosed
};

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
@property (nonatomic, readonly) MDWampSerializationClass serialization;

/**
 * The delegate must implement the MDWampClientDelegate
 * it is not retained
 */
@property (nonatomic, unsafe_unretained) id<MDWampClientDelegate> delegate;

/**
 * If implemented gets called when client connects
 */
@property (nonatomic, copy) void (^onSessionEstablished)(MDWamp *client, NSDictionary *info);

/**
 * If implemented gets called when client close the connection, or fails to connect
 */
@property (nonatomic, copy) void (^onSessionClosed)(MDWamp *client, NSInteger code, NSString *reason, NSDictionary *details);

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
- (id)initWithTransport:(id<MDWampTransport>)transport realm:(NSString *)realm delegate:(id<MDWampClientDelegate>)delegate;


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
#pragma mark Pub/Sub

/**
 * Subscribe for a given topic
 *
 *  @param topic      the URI of the topic to which subscribe
 *  @param onError    result of subscription (called only from version 2)
 *  @param eventBlock The Block invoked when an event on the topic is received
 */
- (void) subscribe:(NSString *)topic
           onEvent:(void(^)(id payload))eventBlock
            result:(void(^)(NSError *error))result;


/**
 * Unsubscribe for a given topic
 *
 * @param topicUri		the URI of the topic to which unsubscribe
 * @param result    result of subscription (called only from version 2)
 */
- (void)unsubscribe:(NSString *)topic
             result:(void(^)(NSError *error))result;

/**
 * Unubscribe from all subscribed topic
 */
- (void) unsubscribeAll;


/**
 *  Complete Publish
 *
 *  @param topic   is the topic published to.
 *  @param args    is a list of application-level event payload elements.
 *  @param argsKw  is a an optional dictionary containing application-level event payload
 *  @param options is a dictionary that allows to provide additional publication request details in an extensible way
 */
- (void) publishTo:(NSString *)topic
              args:(NSArray*)args
                kw:(NSDictionary *)argsKw
           options:(NSDictionary *)options
            result:(void(^)(NSError *error))result;

/**
 *  Shortand for publishing a list of payload
 *
 *  @param topic   is the topic published to.
 *  @param args    is a list of application-level event payload elements.
 */
- (void) publishTo:(NSString *)topic
              args:(NSArray*)args
            result:(void(^)(NSError *error))result;

/**
 *  Shortand for publishing a payload
 *  it's the only publishing method suitable for Legacy protocol
 *  NOTICE that from version 2 if payload isn't a dictionary it will complain!
 *
 *  @param topic   is the topic published to.
 *  @param payload is a list of application-level event payload elements.
 */
- (void) publishTo:(NSString *)topic
           payload:(id)payload
            result:(void(^)(NSError *error))result;


#pragma mark -
#pragma mark RPC
/**
 * Call a Remote Procedure on the server
 * returns the string callID (unique identifier of the call)
 *
 * @param procUri		the URI of the remote procedure to be called
 * @param args			arguments array to the procedure
 * @param kwArgs		keyword arguments array to the procedure
 * @param completeBlock block to be executed on complete if success error is nil, if failure result is nil
 
 */
- (void) call:(NSString*)procUri
         args:(NSArray*)args
       kwArgs:(NSDictionary*)argsKw
     complete:(void(^)(MDWampResult *result, NSError *error))completeBlock;


- (void) registerRPC:(NSString *)procUri
           procedure:(id (^)(NSDictionary* details, NSArray *arguments, NSDictionary *argumentsKW))procedureBlock
              result:(void(^)(NSError *error))resultCallback;

- (void) unregisterRPC:(NSString *)procUri
                result:(void(^)(NSError *error))result;


//#pragma mark -
//#pragma mark AUTH WAMP-CRA
//
///**
// * Issues an authentication request
// *
// * @param appKey		Authentication key, i.e. user or application name
// *                      If undefined, anonymous authentication is performed
// * @param extra			Authentication extra information - optional
// */
//- (void) authReqWithAppKey:(NSString *)appKey andExtra:(NSString *)extra;
//
//
///**
// * Signs an authentication challenge
// *
// * @param challenge		Authentication challenge as returned by the WAMP server upon a authentication request
// * @param secret		Authentication secret
// */
//- (void) authSignChallenge:(NSString *)challenge withSecret:(NSString *)secret;
//
//
///**
// * Authenticate, finishing the authentication handshake
// *
// * @param signature		A authentication signature
// */
//- (void) authWithSignature:(NSString *)signature;
//
//
///**
// * Authenticate websocket with wamp-cra; same protocol as above methods but in single call
// *
// * @param authKey		Authentication key, i.e. user or application name
// *                      If undefined, anonymous authentication is performed
// * @param authExtra			Authentication extra information - optional
// * @param secret		Authentication secret (ie password)
// * @param successBlock  Block to be executed upon sucessful authentication
// * @param errorBlock    Block to be executed upon error during authentication
// */
//-(void) authWithKey:(NSString*)authKey Secret:(NSString*)authSecret Extra:(NSString*)authExtra
//            Success:(void(^)(NSString* answer)) successBlock
//              Error:(void(^)(NSString* procCall, NSString* errorURI, NSString* errorDetails)) errorBlock;


@end
