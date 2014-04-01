//
//  MDWampClient.m
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

#import "MDWamp.h"
#import "NSString+MDString.h"

#import "MDWampTransports.h"


#pragma Constants
NSString * const kMDWampSubprotocolWamp         = @"wamp";
NSString * const kMDWampSubprotocolWamp2JSON    = @"wamp.2.json";
NSString * const kMDWampSubprotocolWamp2MsgPack = @"wamp.2.msgpack";

NSString * const kMDWampRolePublisher   = @"publisher";
NSString * const kMDWampRoleSubscriber  = @"subscriber";
NSString * const kMDWampRoleCaller      = @"caller";
NSString * const kMDWampRoleCallee      = @"callee";


@interface MDWamp () <MDWampTransportDelegate, NSURLConnectionDelegate>
{
	int autoreconnectRetries;
}

@property (nonatomic, strong) NSURL *server;
@property (nonatomic, strong) NSString *realm;
@property (nonatomic, strong) NSString *serverIdent;
@property (nonatomic, strong) NSMutableDictionary *rpcCallbackMap;
@property (nonatomic, strong) NSMutableDictionary *rpcUriMap;
@property (nonatomic, strong) NSMutableDictionary *subscribersCallbackMap;
@property (nonatomic, assign) BOOL sessionEstablished;
@end


@implementation MDWamp

#pragma mark -
#pragma mark Init methods


- (id)initWithURL:(NSURL *)aServer realm:(NSString *)realm delegate:(id<MDWampClientDelegate>)delegate
{
    self = [super init];
	if (self) {
		_shouldAutoreconnect = YES;
		_autoreconnectDelay = 3;
		_autoreconnectMaxRetries = 10;
		
        autoreconnectRetries = 0;
        _sessionEstablished = NO;
        
		self.server     = aServer;
        self.realm      = realm;
		self.delegate   = delegate;
		
		self.rpcCallbackMap = [[NSMutableDictionary alloc] init];
		self.rpcUriMap      = [[NSMutableDictionary alloc] init];
		self.subscribersCallbackMap = [[NSMutableDictionary alloc] init];
        
        self.subprotocols = @[kMDWampSubprotocolWamp2MsgPack, kMDWampSubprotocolWamp2JSON, kMDWampSubprotocolWamp];
        
        self.roles = @[kMDWampRolePublisher, kMDWampRoleSubscriber, kMDWampRoleCaller, kMDWampRoleCallee];
	}
	return self;
}

- (id)initWithServer:(NSString *)aServer realm:(NSString *)realm
{
    return [self initWithURL:[NSURL URLWithString:aServer] realm:realm delegate:nil];
}

/*
 * just for back compatibility
 */
- (id)initWithURLRequest:(NSURLRequest *)aServer delegate:(id<MDWampClientDelegate>)delegate
{
    return [self initWithURL:aServer.URL realm:@"WAMP1" delegate:delegate];
}

- (id)initWithURLRequest:(NSURLRequest *)aServer
{
    return [self initWithURL:aServer.URL realm:@"WAMP1" delegate:nil];
}

- (id)initWithURL:(NSURL *)serverURL
{
    return [self initWithURL:serverURL realm:@"WAMP1" delegate:nil];
}


#pragma mark -
#pragma mark Connection

- (void) connect
{
    // Fallback on default transport
    if (!self.transport) {
        self.transport = [[MDWampTransportWebSocket alloc] initWithServer:self.server protocolVersions:self.subprotocols];
    }
    [self.transport setDelegate:self];
    [self.transport open];
    
}

- (void) disconnect
{
	[self.transport close];
}

- (void) reconnect
{
	if (![self isConnected]) {
		[self disconnect];
		[self connect];
	}
}

- (BOOL) isConnected
{
	return [self.transport isConnected];
}


#pragma mark -
#pragma mark MDWampTransport Delegate
- (void)transportDidReceiveMessage:(MDWampMessage *)message
{
    if ([message isKindOfClass:[MDWampWelcome class]]) {
        MDWampWelcome *welcome = (MDWampWelcome *)message;
        _sessionId = [welcome.session stringValue];
    }
}

- (void)transportDidOpen
{
    MDWampDebugLog(@"websocket connection opened");
	autoreconnectRetries = 0;
    
    // Check if the choosen protocol needs to send an HELLO message
    // to establish connection
    if ([self.transport.protocol shouldSendHello]) {
        MDWampHello *hello = [[MDWampHello alloc] initWithRoles:self.roles];
        hello.realm = self.realm;
        [self.transport send:hello];
    }
    
    //TODO: migrate those when WELCOME is received ;)
	if (_delegate && [_delegate respondsToSelector:@selector(onOpen)]) {
		[_delegate onOpen];
	}
    
    if (self.onConnectionOpen) {
        self.onConnectionOpen(self);
    }
}

- (void)transportDidFailWithError:(NSError *)error {
    
}

- (void)transportDidCloseWithError:(NSError *)error {
    
}


#pragma mark -
#pragma mark Commands

- (void) prefix:(NSString*)prefix uri:(NSString*)uri
{
//	NSString *payload = [self packArguments:[NSNumber numberWithInt:MDWampMessageTypePrefix],prefix, uri, nil];
//	MDWampDebugLog(@"sending prefix: %@", payload);
//	[_socket send:payload];
}


#pragma mark Remote Procedure Call

- (NSString*) call:(NSString*)procUri
           complete:(void(^)(NSString* callURI, id result, NSError *error))completeBlock
              args:(id)firstArg, ... NS_REQUIRES_NIL_TERMINATION
{
//    NSMutableArray *argArray = [[NSMutableArray alloc] init];
//	NSString *callID = [self getRandomId];
//	
//    if (completeBlock) {
//        [self.rpcCallbackMap setObject:completeBlock forKey:callID];
//    }
//	[self.rpcUriMap setObject:procUri forKey:callID];
//	
//	[argArray addObject:[NSNumber numberWithInt:MDWampMessageTypeCall]];
//	[argArray addObject:callID];
//	[argArray addObject:procUri];
//	
//	va_list args;
//    va_start(args, firstArg);
//    for (id arg = firstArg; arg != nil; arg = va_arg(args, id)) {
//		[argArray addObject:arg];
//    }
//    va_end(args);
//	
//	NSString *packedJson = [self packArgumentsWithArray:argArray];
//    
//	[_socket send:packedJson];
//	
//	return callID;
    return nil;
}

#pragma mark Pub/Sub
- (void) subscribeTopic:(NSString *)topicUri onEvent:(void(^)(id payload))eventBlock
{
//	NSString *packedJson = [self packArguments:[NSNumber numberWithInt:MDWampMessageTypeSubscribe], topicUri, nil];
//	NSMutableArray *subscribers = [self.subscribersCallbackMap objectForKey:topicUri];
//    
//	if (subscribers == nil) {
//		NSMutableArray *subList = [[NSMutableArray alloc] init];
//		[self.subscribersCallbackMap setObject:subList forKey:topicUri];
//		subscribers = [self.subscribersCallbackMap objectForKey:topicUri];
//	}
//	
//	[subscribers addObject:eventBlock];
//	[_socket send:packedJson];
}

- (void)unsubscribeTopic:(NSString *)topicUri
{
//	NSString *packedJson = [self packArguments:[NSNumber numberWithInt:MDWampMessageTypeUnsubscribe], topicUri, nil];
//	[_socket send:packedJson];
//	
//	[self.subscribersCallbackMap removeObjectForKey:topicUri];
}

- (void)unsubscribeAll
{
//	for (NSString *topicUri in [_subscribersCallbackMap allKeys]){
//		[self unsubscribeTopic:topicUri];
//	}
//	
//	[_subscribersCallbackMap removeAllObjects];
}

- (void)publish:(id)event toTopic:(NSString *)topicUri excludeMe:(BOOL)excludeMe
{
//	NSString *packedData = [self packArguments:[NSNumber numberWithInt:MDWampMessageTypePublish], topicUri, event,[NSNumber numberWithBool:excludeMe], nil];
//	[_socket send:packedData];
}

- (void)publish:(id)event toTopic:(NSString *)topicUri
{
//	[self publish:event toTopic:topicUri excludeMe:NO];
}


//
//#pragma mark -
//#pragma mark AUTH WAMP-CRA -
//#pragma mark TODO: NOT UNIT TESTED
//
//static NSString *wampProcedureURL = @"http://api.wamp.ws/procedure";
//
- (void) authReqWithAppKey:(NSString *)appKey andExtra:(NSString *)extra
{
//    
//    [self call:[NSString stringWithFormat:@"%@#%@", wampProcedureURL, @"authreq"]
//      complete:^(NSString *callURI, id result, NSError *error) {
//          if (!error) {
//              if ([_delegate respondsToSelector:@selector(onAuthReqWithAnswer:)]) {
//                  [_delegate onAuthReqWithAnswer:result];
//              }
//          } else {
//              if ([_delegate respondsToSelector:@selector(onAuthFailForCall:withError:)]) {
//                  [_delegate onAuthFailForCall:@"authreq" withError:error.localizedDescription];
//              }
//          }
//      } args:appKey,extra, nil];
}
//
- (void) authSignChallenge:(NSString *)challenge withSecret:(NSString *)secret
{
//    NSString *signature = [self hmacSHA256Data:challenge withKey:secret];
//    if ([_delegate respondsToSelector:@selector(onAuthSignWithSignature:)]) {
//		[_delegate onAuthSignWithSignature:signature];
//	}
}
//
- (void) authWithSignature:(NSString *)signature
{
//    [self call:[NSString stringWithFormat:@"%@#%@", wampProcedureURL, @"auth"]
//      complete:^(NSString *callURI, id result, NSError *error) {
//          if (!error) {
//              if ([_delegate respondsToSelector:@selector(onAuthWithAnswer:)]) {
//                  [_delegate onAuthWithAnswer:result];
//              }
//          } else {
//              if ([_delegate respondsToSelector:@selector(onAuthFailForCall:withError:)]) {
//                  [_delegate onAuthFailForCall:@"auth" withError:error.localizedDescription];
//              }
//          }
//      } args:signature,nil];
}
//
-(void) authWithKey:(NSString*)authKey Secret:(NSString*)authSecret Extra:(NSString*)authExtra
            Success:(void(^)(NSString* answer)) successBlock
              Error:(void(^)(NSString* procCall, NSString* errorURI, NSString* errorDetails)) errorBlock
{
//    [self call:[NSString stringWithFormat:@"%@#%@", wampProcedureURL, @"authreq"] complete:^(NSString *callURI, id result, NSError *error) {
//        if (!error) {
//            //Respond with signature
//            NSString *signature = [self hmacSHA256Data:result withKey:authSecret];
//            
//            [self call:[NSString stringWithFormat:@"%@#%@", wampProcedureURL, @"auth"] complete:^(NSString *callURI, id result, NSError *error) {
//                if (!error) {
//                    successBlock(result);
//                } else {
//                    errorBlock(@"auth",callURI, error.localizedDescription);
//                }
//            } args:signature, nil];
//        }
//    } args:authKey, authExtra, nil];
}


//#pragma mark -
//#pragma mark SRWebSocketDelegate
//
//- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
//{
//    MDWampDebugLog(@"%@ \n", message);
//    
//    
//    MDWampMessage *receivedMessage = [[MDWampMessage alloc] initWithResponse:message];
//	
//	if (receivedMessage.type == MDWampMessageTypeWelcome) {
//		MDWampDebugLog(@"WELCOMMMME");
//		_sessionId = [[NSString alloc] initWithString:[receivedMessage shiftStackAsString]];
//		int serverProtocolVersion = [receivedMessage shiftStackAsInt];
//		if (serverProtocolVersion != kMDWampProtocolVersion) {
//			[_socket close];
//            // TODO: maybe put closing code in an enum!!!
//            if (_delegate && [_delegate respondsToSelector:@selector(onClose:reason:)]) {
//                [_delegate onClose:0 reason:@"Protocol Version used by client and server don't match!"];
//            }
//            
//            if (self.onConnectionClose) {
//                self.onConnectionClose(self, 0, @"Protocol Version used by client and server don't match!");
//            }
//
//		}
//		self.serverIdent = [[NSString alloc] initWithString:[receivedMessage shiftStackAsString]];
//	} else if(receivedMessage.type == MDWampMessageTypeCallResult
//              || receivedMessage.type == MDWampMessageTypeCallError){
//		
//		NSString *callID = [receivedMessage shiftStackAsString];
//		NSString *callUri = [self.rpcUriMap objectForKey:callID];
//		
//		if (receivedMessage.type == MDWampMessageTypeCallResult) {
//			NSString *callResult = [receivedMessage shiftStackAsString];
//            void(^callback)(NSString* callURI, id result, NSError *error)  = [self.rpcCallbackMap objectForKey:callID];
//            
//            //Handle with delegate or block
//            if (callback) {
//                callback(callUri, callResult, nil);
//            }
//            [_rpcCallbackMap removeObjectForKey:callID];
//            
//		} else {
//			NSString *errorUri = [receivedMessage shiftStackAsString];
//  			NSString *errorDetail = [receivedMessage shiftStackAsString];
//            NSString *errorDescription = [NSString stringWithFormat:@"%@ %@", errorUri, errorDetail];
//            NSError *error = [NSError errorWithDomain:@"it.mogui.MDWamp" code:34 userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
//            
//            void(^callback)(NSString* callURI, id result, NSError *error)  = [self.rpcCallbackMap objectForKey:callID];
//            
//            if (callback) {
//                callback(errorUri, nil, error);
//            }
//
//            [_rpcCallbackMap removeObjectForKey:callID];
//		}
//		
//		[self.rpcUriMap removeObjectForKey:callID];
//	} else if (receivedMessage.type == MDWampMessageTypeEvent) {
//		NSString *topicUri = [receivedMessage shiftStackAsString];
//		
//		id eventPayload = [receivedMessage shiftStack];
//		
//		NSArray *subscribers = [_subscribersCallbackMap objectForKey:topicUri];
//        
//		if (subscribers != nil){
//			for (void (^eventCallback)(id payload) in subscribers){
//                eventCallback(eventPayload);
//			}
//		}
//	}
//}
//
//- (void)webSocketDidOpen:(SRWebSocket *)webSocket
//{
//	
//}
//
//
//- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
//{
//	MDWampDebugLog(@"DID FAIL error %@", error);
//    [self webSocket:webSocket didCloseWithCode:error.code reason:error.localizedFailureReason wasClean:NO];
//}
//
//- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
//{
//	MDWampDebugLog(@"DID CLOSE reason %@ %ld", reason, (long)code);
//	
//	if (code != 54 && _shouldAutoreconnect && autoreconnectRetries < _autoreconnectMaxRetries) {
//		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _autoreconnectDelay * NSEC_PER_SEC);
//		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//			MDWampDebugLog(@"trying to reconnect...");
//			autoreconnectRetries +=1;
//			[self reconnect];
//		});
//	}
//	
//    if (_delegate && [_delegate respondsToSelector:@selector(onClose:reason:)]) {
//        [_delegate onClose:code reason:reason];
//    }
//    
//    if (self.onConnectionClose) {
//        self.onConnectionClose(self, code, reason);
//    }
//}




@end
