//
//  MDWampTransportDelegate.h
//  MDWamp
//
//  Created by Niko Usai on 11/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDWampMessage;

@protocol MDWampTransportDelegate <NSObject>


// message will either be an NSString or NSData
- (void)transportDidReceiveMessage:(MDWampMessage *)message;

@optional
/**
 *  Transport has correctly opened a connection
 */
- (void)transportDidOpen;

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
