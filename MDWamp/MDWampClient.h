//
//  MDWampClient.h
//  MDWamp
//
//  Created by Niko Usai on 13/12/13.
//  Copyright (c) 2013 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampClientDelegate.h"

#ifdef DEBUG
#define MDWampDebugLog(fmt, ...) NSLog((@"%s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__);
#endif

// supported protocol version
#define	kMDWampProtocolVersion 1


@interface MDWampClient : NSObject

/**
 * The delegate must implement the MDWampClientDelegate
 * it is not retained
 */
@property (nonatomic, weak) id<MDWampClientDelegate> delegate;

/**
 * The server generated sessionId
 */
@property (nonatomic, copy, readonly) NSString *sessionId;

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
 * Returns a new istance with connection configured with given server
 * it does not automatically connect to the ws server
 *
 * @param serverRequest	 url request with full protocol es. ws://websocket.com
 * @param delegate		The delegate for this instance
 */
- (id) initWithURLRequest:(NSURLRequest *)server delegate:(id<MDWampClientDelegate>)delegate;

/**
 * Convenience method for initWithURLRequest:delegate:
 * delegate can be nil
 *
 * @param serverRequest	 url request with full protocol es. ws://websocket.com
 */

- (id) initWithURLRequest:(NSURLRequest *)server;

/**
 * Convienience method for initWithURLRequest:delegate:
 *
 * Returns a new istance with connection configured with given server
 * it does not automatically connect to th ws server
 *
 * @param server		webserver url with full protocol es. ws://websocket.com
 * @param delegate		The delegate for this instance
 */
- (id) initWithURL:(NSURL *)serverURL;

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


@end
