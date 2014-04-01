//
//  MDWampTransportProtocol.h
//  MDWamp
//
//  Created by Niko Usai on 11/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampTransportDelegate.h"
#import "MDWampProtocolVersion.h"
#import "MDWampSerialization.h"

@class MDWampMessage;
@protocol MDWampTransport <NSObject>

/**
 *  The transport delegate
 */
@property id<MDWampTransportDelegate>delegate;

@property (nonatomic, strong) id<MDWampProtocolVersion>protocol;

@property (nonatomic, strong) id<MDWampSerialization>serialization;

/**
 *  Choosen subprotocol after connection
 */
@property (nonatomic, readonly) NSString *subprotocol;

/**
 *  Default initializer
 *  By restricting the array of protocol versions we force to use a given protocol
 *  they are in the form of wamp, wamp.2.json, wamp.2.msgpack
 *
 *  @param request   request representing a server
 *  @param protocols an array of subprotocols supported to let choose Wamp version and serialization by the server.
 *
 *  @return intsance of the transport
 */
- (id)initWithServer:(NSURL *)request protocolVersions:(NSArray *)protocols;

/**
 *  Method used to open a connection to the transport
 */
- (void) open;

/**
 *  Method used to close a connection with the transport
 */
- (void) close;
/**
 *  Test the connection with the transport
 *
 *  @return connection status
 */
- (BOOL) isConnected;

/**
 *  Method to send data on the transport
 */
- (void)send:(MDWampMessage *)data;

@end
