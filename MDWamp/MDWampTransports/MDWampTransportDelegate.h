//
//  MDWampTransportDelegate.h
//  MDWamp
//
//  Created by Niko Usai on 11/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDWampTransportDelegate <NSObject>


// message will either be an NSString or NSData
- (void)transportDidReceiveMessage:(id)message;

@optional
/**
 *  TRansport has correctly opened a connection
 *  and has choose a protocolVersion class and a serialization class
 *
 *  @param protocolVersion
 *  @param serialization
 */
- (void)transportDidOpenWithProtocolVersion:(Class)protocolVersion andSerialization:(Class)serialization;

/**
 *  Transport Failed connection
 *
 *  @param error
 */
- (void)transportDidFailWithError:(NSError *)error;

/**
 *  Transport Closed connection
 *
 *  @param error 
 */
- (void)transportDidCloseWithError:(NSError *)error;


@end
