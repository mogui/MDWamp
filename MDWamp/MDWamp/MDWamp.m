//
//  MDWamp.m
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


#import "MDWamp.h"
#import "MDJSONBridge.h"
#import "SRWebSocket.h"
#import "MDCrypto.h"

@interface MDWamp () <SRWebSocketDelegate, NSURLConnectionDelegate>
@end

@implementation MDWamp

@synthesize delegate;
@synthesize shouldAutoreconnect;
@synthesize autoreconnectDelay;
@synthesize autoreconnectMaxRetries;

#pragma mark - inner methods

- (NSString*)getRandomId
{
	NSInteger ii;
    NSString *allletters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuwxyz0123456789";
	NSString *outstring = @"";
    for (ii=0; ii<20; ii++) {
        outstring = [outstring stringByAppendingString:[allletters substringWithRange:[allletters rangeOfComposedCharacterSequenceAtIndex:random()%[allletters length]]]];
    }
	
    return outstring;
}


- (NSString*) packArgumentsWithArray:(NSArray*)arguments
{
	return  [MDJSONBridge jsonStringFromObject:arguments];
}

- (NSString*) packArguments:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
	NSMutableArray *argArray = [[NSMutableArray alloc] init];
	va_list args;
    va_start(args, firstObj);
	
    for (id arg = firstObj; arg != nil; arg = va_arg(args, id)) {
		[argArray addObject:arg];
    }
	
    va_end(args);
	
	NSString *packedJson = [self packArgumentsWithArray:argArray];
	
	
	return packedJson;
}


#pragma mark - SRWebSocket delegate methods
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
	MDWampDebugLog(@"message %@", message);
	MDWampMessage *receivedMessage = [[MDWampMessage alloc] initWithResponse:(NSString*)message];
	
	// @TODO refactor without switch and a nicely if else if ...

	
	if (receivedMessage.type == MDWampMessageTypeWelcome) {
		MDWampDebugLog(@"WELCOMMMME");
		sessionId = [[NSString alloc] initWithString:[receivedMessage shiftStackAsString]];
		int serverProtocolVersion = [receivedMessage shiftStackAsInt];
		if (serverProtocolVersion != kMDWampProtocolVersion) {
			[socket close];
			[delegate onClose:0 reason:@"Protocol Version used by client and server don't match!"];
		}
		serverIdent = [[NSString alloc] initWithString:[receivedMessage shiftStackAsString]];
	} else if(receivedMessage.type == MDWampMessageTypeCallResult || receivedMessage.type == MDWampMessageTypeCallError){
		
		NSString *callID = [receivedMessage shiftStackAsString];
		NSString *callUri = [rpcUriMap objectForKey:callID];
		
		if (receivedMessage.type == MDWampMessageTypeCallResult) {
			NSString *callResult = [receivedMessage shiftStackAsString];
			
			// call return method on delegate
            if ([callUri isEqualToString:[NSString stringWithFormat:@"%@#%@", wampProcedureURL, @"authreq"]]) {
                // if it's an auth answer
                if ([delegate respondsToSelector:@selector(onAuthReqWithAnswer:)]) {
                    [delegate onAuthReqWithAnswer:callResult];
                }
            } else if ([callUri isEqualToString:[NSString stringWithFormat:@"%@#%@", wampProcedureURL, @"auth"]]) {
                if ([delegate respondsToSelector:@selector(onAuthWithAnswer:)]) {
                    [delegate onAuthWithAnswer:callResult];
                }
            } else {
                // it's a normal message
                id<MDWampRpcDelegate>rpcDelegate = [rpcDelegateMap objectForKey:callID];
                [rpcDelegate onResult:callResult forCalledUri:callUri];
                [rpcDelegateMap removeObjectForKey:callID];
            }
		} else {
			NSString *errorUri = [receivedMessage shiftStackAsString];
			NSString *errorDetail = [receivedMessage shiftStackAsString];
			
            if ([callUri isEqualToString:[NSString stringWithFormat:@"%@#%@", wampProcedureURL, @"authreq"]]) {
                if ([delegate respondsToSelector:@selector(onAuthFailForCall:)]) {
                    [delegate onAuthFailForCall:@"authreq" withError:errorDetail];
                }
            } else if ([callUri isEqualToString:[NSString stringWithFormat:@"%@#%@", wampProcedureURL, @"auth"]]) {
                if ([delegate respondsToSelector:@selector(onAuthFailForCall:)]) {
                    [delegate onAuthFailForCall:@"auth" withError:errorDetail];
                }
            } else {
                id<MDWampRpcDelegate>rpcDelegate = [rpcDelegateMap objectForKey:callID];
                [rpcDelegate onError:errorUri description:errorDetail forCalledUri:callUri];
                [rpcDelegateMap removeObjectForKey:callID];
            }
		}
		
		[rpcUriMap removeObjectForKey:callID];
	} else if (receivedMessage.type == MDWampMessageTypeEvent) {
		NSString *topicUri = [receivedMessage shiftStackAsString];
		
		id eventPayload = [receivedMessage shiftStack];
		
		NSArray *subscribers = [subscribersDelegateMap objectForKey:topicUri];

		if (subscribers != nil){
			for (id<MDWampEventDelegate>_delegate in subscribers){
				[_delegate onEvent:topicUri eventObject:eventPayload];
			}
		}
	}
	
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
	MDWampDebugLog(@"open");
	autoreconnectRetries = 0;
	if ([delegate respondsToSelector:@selector(onOpen)]) {
		[delegate onOpen];
	}
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
	MDWampDebugLog(@"DID FAIL error %@", error);
	if ([delegate respondsToSelector:@selector(onClose:reason:)]) {
		[self webSocket:webSocket didCloseWithCode:error.code reason:error.localizedFailureReason wasClean:NO];
	}
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
	MDWampDebugLog(@"DID CLOSE reason %@ %d", reason, code);
	
	if (code != 54 && shouldAutoreconnect && autoreconnectRetries < autoreconnectMaxRetries) {
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, autoreconnectDelay * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			MDWampDebugLog(@"trying to reconnect...");
			autoreconnectRetries +=1;
			[self reconnect];
		});
	}
	
	
	if ([delegate respondsToSelector:@selector(onClose:reason:)]) {
		[delegate onClose:code reason:reason];
	}
}


#pragma mark - ARC authentication

static NSString *wampProcedureURL = @"http://api.wamp.ws/procedure";

- (void) authReqWithAppKey:(NSString *)appKey andExtra:(NSString *)extra
{
    NSString* url = [NSString stringWithFormat:@"%@#%@", wampProcedureURL, @"authreq"];
    [self call:url withDelegate:nil args:appKey, extra, nil];
}

- (void) authSignChallenge:(NSString *)challenge withSecret:(NSString *)secret
{
    NSString *signature = [MDCrypto hmacSHA256Data:challenge withKey:secret];
    if ([delegate respondsToSelector:@selector(onAuthSignWithSignature:)]) {
		[delegate onAuthSignWithSignature:signature];
	}
}

- (void) authWithSignature:(NSString *)signature
{
    NSString* url = [NSString stringWithFormat:@"%@#%@", wampProcedureURL, @"auth"];
    [self call:url withDelegate:nil args:signature, nil];
}

#pragma mark - public interface

- (id)initWithUrl:(NSString *)_server delegate:(id<MDWampDelegate>)_delegate
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_server]];
    self = [self initWithURLRequest:request delegate:_delegate];
    return self;
}

- (id)initWithURLRequest:(NSURLRequest *)_server delegate:(id<MDWampDelegate>)_delegate{
    self = [super init];
	if (self) {
		shouldAutoreconnect = YES;
		autoreconnectRetries = 0;
		autoreconnectDelay = 3;
		autoreconnectMaxRetries = 10;
		
		server = _server;
		self.delegate = _delegate;
		
		rpcDelegateMap = [[NSMutableDictionary alloc] init];
		rpcUriMap = [[NSMutableDictionary alloc] init];
		subscribersDelegateMap = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) reconnect
{
	if (![self isConnected]) {
		[self disconnect];
		[self connect];
	}
}

- (void) connect
{
	socket = [[SRWebSocket alloc] initWithURLRequest:server protocols:[NSArray arrayWithObjects:@"wamp", nil]];
	[socket setDelegate:self];
	[socket open];

}

- (void) disconnect
{
	[socket close];
	socket = nil;
}

- (BOOL) isConnected
{
	return (socket!=nil)? socket.readyState == SR_OPEN : NO;
}

- (void) prefix:(NSString*)prefix uri:(NSString*)uri
{
	NSString *payload = [self packArguments:[NSNumber numberWithInt:MDWampMessageTypePrefix],prefix, uri, nil];
	MDWampDebugLog(@"sending prefix: %@", payload);
	[socket send:payload];
}

/*
 * RPC
 */

//
//	Call remote procedure
//
- (NSString*) call:(NSString*)procUri withDelegate:(id<MDWampRpcDelegate>)rpcDelegate args:(id)firstArg, ...
{
	NSMutableArray *argArray = [[NSMutableArray alloc] init];
	NSString *callID = [self getRandomId];
	
    if (rpcDelegate) {
        [rpcDelegateMap setObject:rpcDelegate forKey:callID];
    }
	[rpcUriMap setObject:procUri forKey:callID];
	
	[argArray addObject:[NSNumber numberWithInt:MDWampMessageTypeCall]];
	[argArray addObject:callID];
	[argArray addObject:procUri];
	
	va_list args;
    va_start(args, firstArg);
	
    for (id arg = firstArg; arg != nil; arg = va_arg(args, id)) {
		[argArray addObject:arg];
    }
	
    va_end(args);
	
	NSString *packedJson = [self packArgumentsWithArray:argArray];
    NSLog(@"%@", packedJson);
    
	[socket send:packedJson];
	
	return callID;
}


/*
 *	Publish / Subscribe
 */

- (void) subscribeTopic:(NSString *)topicUri withDelegate:(id<MDWampEventDelegate>)_delegate
{
	NSString *packedJson = [self packArguments:[NSNumber numberWithInt:MDWampMessageTypeSubscribe], topicUri, nil];
	
	NSMutableArray *subscribers = [subscribersDelegateMap objectForKey:topicUri];
	if (subscribers == nil) {
		NSMutableArray *subList = [[NSMutableArray alloc] init];
		[subscribersDelegateMap setObject:subList forKey:topicUri];
		
		subscribers = [subscribersDelegateMap objectForKey:topicUri];
	}
	
	[subscribers addObject:_delegate];
	[socket send:packedJson];

}

- (void)unsubscribeTopic:(NSString *)topicUri
{
	NSString *packedJson = [self packArguments:[NSNumber numberWithInt:MDWampMessageTypeUnsubscribe], topicUri, nil];
	[socket send:packedJson];
	
	[subscribersDelegateMap removeObjectForKey:topicUri];
}

- (void)unsubscribeAll
{
	for (NSString *topicUri in [subscribersDelegateMap allKeys]){
		[self unsubscribeTopic:topicUri];
	}
	
	[subscribersDelegateMap removeAllObjects];
}

- (void)publish:(id)event toTopic:(NSString *)topicUri excludeMe:(BOOL)excludeMe
{
	NSString *packedData = [self packArguments:[NSNumber numberWithInt:MDWampMessageTypePublish], topicUri, event,[NSNumber numberWithBool:excludeMe], nil];
	[socket send:packedData];
}

- (void)publish:(id)event toTopic:(NSString *)topicUri
{
	[self publish:event toTopic:topicUri excludeMe:NO];
}


#pragma mark - static Debug method



static bool isInDebug;
+ (BOOL)debug
{
	return isInDebug;
}
+ (void)setDebug:(BOOL)debug
{
	isInDebug = debug;
}


@end

