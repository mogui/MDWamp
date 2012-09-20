//
//  MDWampProtocols.h
//  MDWamp
//
//  Created by pronk on 13/09/12.
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

/*
 * Main MDWamp delegate it manages connection and disconnection of the cliet
 */


@protocol MDWampDelegate <NSObject>
@optional

/*
 * Called when client connect to the server
 */
- (void) onOpen;

/*
 * Called when client disconnect from the server
 * it gives code of the error / reason of disconnect and a description of the reason
 *
 * @param code			error/reason code
 * @param reason		dicsconnection reason
 */
- (void) onClose:(int)code reason:(NSString *)reason;

@end


/*
 * Event Delegate 
 * It is the object that receive the events from the topic it subscribed for
 */

@protocol MDWampEventDelegate <NSObject>
/*
 * Called when an event arrives from the server
 *
 * @param topicUri		the URI of the topic from which the event arrives
 * @param object		payload of the event
 */
- (void) onEvent:(NSString *)topicUri eventObject:(id)object;

@end


/*
 * Remote Procedure Call Delegate
 * It handles return of the remote proceedure called
 */

@protocol MDWampRpcDelegate <NSObject>
/*
 * Called when the result of the Procedure correctly returns
 *
 * @param result		object representing the result of the call
 * @param callUri		remote procedure uri called
 */
- (void) onResult:(id)result forCalledUri:(NSString*)callUri;

/*
 * Called when the remote procedure fails
 *
 * @param errorUri		an URI representing the error type
 * @param errorDesc		Description of the error
 * @param callUri		remote procedure uri called
 */
- (void) onError:(NSString *)errorUri description:(NSString*)errorDesc forCalledUri:(NSString*)callUri;

@end

