//
//  MDWamp.h
//  MDWamp
//
//  Created by mogui on 08/09/12.
//  Copyright (c) 2012 mogui. All rights reserved.
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


#import <Foundation/Foundation.h>


#import "MDWampProtocols.h"
#import "MDWampMessage.h"

#define MDWampDebugLog(fmt, ...) if([MDWamp debug]) NSLog((@"%s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__);

// supported protocol version
#define	kMDWampProtocolVersion 1

@class SRWebSocket;
@protocol SRWebSocketDelegate;


@interface MDWamp : NSObject

{
	NSURLRequest *server;
	SRWebSocket *socket;
	NSString *sessionId;
	NSString *serverIdent;
	__unsafe_unretained id<MDWampDelegate> delegate;
	
	NSMutableDictionary *rpcDelegateMap;
	NSMutableDictionary *rpcUriMap;
	NSMutableDictionary *subscribersDelegateMap;
	
	BOOL shouldAutoreconnect;
	int autoreconnectMaxRetries;
	int autoreconnectDelay;
	int autoreconnectRetries;

}

/*
 * The delegate must implement the MDWampDelegate
 * it is not retained
 */
@property (nonatomic, unsafe_unretained) id<MDWampDelegate> delegate;

/*
 * Indicates whether or not MDWamp tries to reconnect after a non implicit disconnection
 */
@property (nonatomic, assign) BOOL shouldAutoreconnect;

/*
 * The seconds between each reconnection try
 */
@property (nonatomic, assign) int autoreconnectDelay;

/*
 * The maximum times MDWamp will try to reconnect
 */
@property (nonatomic, assign) int autoreconnectMaxRetries;

/*
 * Returns a new istance with connection configured with given server
 * it does not automatically connect to the ws server
 *
 * @param serverRequest	 url request with full protocol es. ws://websocket.com
 * @param delegate		The delegate for this instance
 */

- (id) initWithURLRequest:(NSURLRequest *)server delegate:(id<MDWampDelegate>)delegate;

/*
 * Convienience method for initWithURLRequest:delegate:
 *
 * Returns a new istance with connection configured with given server
 * it does not automatically connect to th ws server
 * 
 * @param server		webserver url with full protocol es. ws://websocket.com
 * @param delegate		The delegate for this instance
 */
- (id) initWithUrl:(NSString *)server delegate:(id<MDWampDelegate>)delegate;

/*
 * Start the connection with the server
 */
- (void) connect;

/*
 * Disconnect from the server
 */
- (void) disconnect;

/*
 * Handles clean disconnection e reconnection
 */
- (void) reconnect;

/*
 * Returns whether or not we are connected to the server
 */
- (BOOL) isConnected;


/*
 * AUTH WAMP-CRA IMPLEMENTATION -----------------------------------
 */

/*
 * Issues an authentication request
 *
 * @param appKey		Authentication key, i.e. user or application name
 *                      If undefined, anonymous authentication is performed
 * @param extra			Authentication extra information - optional
 */
- (void) authReqWithAppKey:(NSString *)appKey andExtra:(NSString *)extra;


/*
 * Signs an authentication challenge
 *
 * @param challenge		Authentication challenge as returned by the WAMP server upon a authentication request
 * @param secret		Authentication secret
 */
- (void) authSignChallenge:(NSString *)challenge withSecret:(NSString *)secret;


/*
 * Authenticate, finishing the authentication handshake
 *
 * @param signature		A authentication signature
 */
- (void) authWithSignature:(NSString *)signature;


/*
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

/*
 * MESSAGES IMPLEMENTATIONS ---------------------------------------
 */

/*
 * Sets the prefix Uri to share with the server
 * so we can in future calls of other methods use CURIEs instead of full URIs
 * see http://wamp.ws/spec#uris_and_curies for details
 *
 * @param prefix		a string to be used as prefix
 * @param uri			the URI which is subsequently to be abbreviated using the prefix.
 */
- (void) prefix:(NSString*)prefix uri:(NSString*)uri;


/*
 * Call a Remote Procedure on the server
 * returns the string callID (unique identifier of the call)
 *
 * @param procUri		the URI of the remote procedure to be called
 * @param delegate		The delegate for this call
 * @param args			zero or more call arguments
 */
- (NSString*) call:(NSString*)procUri withDelegate:(id<MDWampRpcDelegate>)rpcDelegate args:(id)firstArg, ... NS_REQUIRES_NIL_TERMINATION;

/*
 * Call a Remote Procedure on the server
 * returns the string callID (unique identifier of the call)
 *
 * @param procUri		the URI of the remote procedure to be called
 * @param success		block to be executed on succcess
 * @param error         block to be executed on failure
 * @param args			zero or more call arguments
 */
- (NSString*) call:(NSString*)procUri
                success:(void(^)(NSString* callURI, id result))success
                    error:(void(^)(NSString* callURI, NSString* errorURI, NSString* errorDescription))error
                        args:(id)firstArg, ... NS_REQUIRES_NIL_TERMINATION;

/*
 * Subscribe for a given topic
 *
 * @param topicUri		the URI of the topic to which subscribe
 * @param delegate		The delegate for this subscription
 */
- (void) subscribeTopic:(NSString *)topicUri withDelegate:(id<MDWampEventDelegate>)delegate;

/*
 * Unsubscribe for a given topic
 *
 * @param topicUri		the URI of the topic to which unsubscribe
 */
- (void) unsubscribeTopic:(NSString *)topicUri;

/*
 * Unubscribe from all subscribed topic
 */
- (void) unsubscribeAll;

/*
 * Publish something to the given topic
 *
 * @param topicUri		the URI of the topic to which publish
 * @param excludeMe		Whether or not exclude caller from the pushing of this event
 */
- (void)publish:(id)event toTopic:(NSString *)topicUri excludeMe:(BOOL)excludeMe;


/*
 * Shortand for publish not excluding caller from event's receiver
 *
 * @param topicUri		the URI of the topic to which publish
 */
- (void)publish:(id)event toTopic:(NSString *)topicUri;

/*
 * Set if debug LOG are activeted or not
 *
 */
+ (void)setDebug:(BOOL)debug;

@end
