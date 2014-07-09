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

#include <stdlib.h>

#import "MDWamp.h"
#import "NSString+MDString.h"
#import "NSMutableArray+MDStack.h"
#import "MDWampTransports.h"
#import "MDWampSerializations.h"
#import "MDWampMessageFactory.h"

#pragma Constants

NSString * const kMDWampRolePublisher   = @"publisher";
NSString * const kMDWampRoleSubscriber  = @"subscriber";
NSString * const kMDWampRoleCaller      = @"caller";
NSString * const kMDWampRoleCallee      = @"callee";


@interface MDWamp () <MDWampTransportDelegate, NSURLConnectionDelegate>

@property (nonatomic, assign) BOOL explicitSessionClose;
@property (nonatomic, strong) id<MDWampTransport> transport;
@property (nonatomic, strong) id<MDWampSerialization> serializator;
@property (nonatomic, strong) NSString *realm;
@property (nonatomic, assign) BOOL sessionEstablished;
@property (nonatomic, assign) BOOL goodbyeSent;

@property (nonatomic, strong) NSMutableDictionary *subscriptionRequests;
@property (nonatomic, strong) NSMutableDictionary *subscriptionEvents;
@property (nonatomic, strong) NSMutableDictionary *subscriptionID;

@property (nonatomic, strong) NSMutableDictionary *publishRequests;

@property (nonatomic, strong) NSMutableDictionary *rpcCallbackMap;
@property (nonatomic, strong) NSMutableDictionary *rpcRegisterRequests;
@property (nonatomic, strong) NSMutableDictionary *rpcUnregisterRequests;
@property (nonatomic, strong) NSMutableDictionary *rpcRegisteredUri;
@property (nonatomic, strong) NSMutableDictionary *rpcRegisteredProcedures;

@end


@implementation MDWamp

#pragma mark -
#pragma mark Init methods


- (id)initWithTransport:(id<MDWampTransport>)transport realm:(NSString *)realm delegate:(id<MDWampClientDelegate>)delegate
{
    self = [super init];
	if (self) {
		
        _explicitSessionClose = NO;
        _sessionEstablished = NO;
        _goodbyeSent        = NO;
        
        self.realm      = realm;
        self.delegate   = delegate;
        self.transport  = transport;
        [self.transport setDelegate:self];

        self.subscriptionRequests   = [[NSMutableDictionary alloc] init];
		self.rpcCallbackMap         = [[NSMutableDictionary alloc] init];
		self.rpcRegisterRequests    = [[NSMutableDictionary alloc] init];
        self.rpcUnregisterRequests  = [[NSMutableDictionary alloc] init];
		self.rpcRegisteredProcedures= [[NSMutableDictionary alloc] init];
        self.rpcRegisteredUri       = [[NSMutableDictionary alloc] init];
		self.subscriptionEvents     = [[NSMutableDictionary alloc] init];
        self.subscriptionID         = [[NSMutableDictionary alloc] init];
        self.publishRequests        = [[NSMutableDictionary alloc] init];
        
        self.roles = @{kMDWampRolePublisher:@{}, kMDWampRoleSubscriber:@{}, kMDWampRoleCaller:@{}, kMDWampRoleCallee:@{}};
	}
	return self;
}

#pragma mark Utils
- (NSNumber *) generateID
{
    unsigned int r = abs(arc4random_uniform(exp2(32)-1));
    return [NSNumber numberWithInt:r];
}

- (void) cleanUp {
    [self.subscriptionRequests   removeAllObjects];
    [self.rpcCallbackMap         removeAllObjects];
    [self.rpcRegisterRequests    removeAllObjects];
    [self.rpcUnregisterRequests  removeAllObjects];
    [self.rpcRegisteredProcedures removeAllObjects];
    [self.rpcRegisteredUri       removeAllObjects];
    [self.subscriptionEvents     removeAllObjects];
    [self.subscriptionID         removeAllObjects];
    [self.publishRequests        removeAllObjects];
}

#pragma mark -
#pragma mark Connection

- (void) connect
{
    [self.transport open];
}

- (void) disconnect
{
    _explicitSessionClose = YES;
	[self.transport close];

    if (self.onSessionClosed) {
        self.onSessionClosed(self, MDWampConnectionClosed, @"MDWamp.session.explicit_closed", nil);
    }
        
    if (self.onSessionClosed) {
        self.onSessionClosed(self, MDWampConnectionClosed, @"MDWamp.session.explicit_closed", nil);
    }
    
    if (_delegate) {
        if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:closedSession:reason:details:)]) {
            [_delegate mdwamp:self closedSession:MDWampConnectionClosed reason:@"MDWamp.session.explicit_closed" details:nil];
        }
    }
}

- (BOOL) isConnected
{
	return [self.transport isConnected];
}

#pragma mark -
#pragma mark MDWampTransport Delegate

- (void)transportDidOpenWithSerialization:(NSString*)serialization
{
    MDWampDebugLog(@"websocket connection opened");
    
    _serialization = serialization;
    
    // Init the serializator
    Class ser = NSClassFromString(self.serialization);
    NSAssert(ser != nil, @"Serialization %@ doesn't exists", ser);
    self.serializator = [[ser alloc] init];
    
    // send hello message
    MDWampHello *hello = [[MDWampHello alloc] initWithPayload:@[self.realm, @{@"roles":self.roles}]];
    hello.realm = self.realm;
    [self sendMessage:hello];
}

- (void)transportDidReceiveMessage:(NSData *)message
{
    NSMutableArray *unpacked = [[self.serializator unpack:message] mutableCopy];
    NSNumber *code = [unpacked shift];
    
    if (!unpacked || [unpacked count] < 1) {
#ifdef DEBUG
        [NSException raise:@"it.mogui.mdwamp" format:@"Wrong message recived"];
#else
        MDWampDebugLog(@"Invalid message code received !!");
#endif
    }
    id<MDWampMessage> msg;
    @try {
        msg = [[MDWampMessageFactory sharedFactory] objectFromCode:code withPayload:unpacked];
    }
    @catch (NSException *exception) {
#ifdef DEBUG
        [exception raise];
#else 
        MDWampDebugLog(@"Invalid message code received !!");
#endif
    }
    
    [self receivedMessage:msg];
}

- (void)transportDidFailWithError:(NSError *)error {
    MDWampDebugLog(@"DID FAIL reason %@", error.localizedDescription);
    if (self.onSessionClosed) {
        self.onSessionClosed(self, error.code, error.localizedDescription, error.userInfo);
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:closedSession:reason:details:)]) {
        [_delegate mdwamp:self closedSession:error.code reason:error.localizedDescription details:error.userInfo];
    }
}

- (void)transportDidCloseWithError:(NSError *)error {
    MDWampDebugLog(@"DID CLOSE reason %@", error.localizedDescription);
    _sessionId = nil;
    [self cleanUp];
 
    if (!_explicitSessionClose) {
        if (self.onSessionClosed) {
            self.onSessionClosed(self, error.code, error.localizedDescription, error.userInfo);
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:closedSession:reason:details:)]) {
            [_delegate mdwamp:self closedSession:error.code reason:error.localizedDescription details:error.userInfo];
        }
        
    }
    self.sessionEstablished = NO;

}

#pragma mark -
#pragma mark Message Management
- (void) receivedMessage:(id<MDWampMessage>)message
{
    
    if ([message isKindOfClass:[MDWampWelcome class]]) {
        
        MDWampWelcome *welcome = (MDWampWelcome *)message;
        _sessionId = [welcome.session stringValue];
    
        NSDictionary *details = welcome.details;
        
        self.sessionEstablished = YES;
        
        if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:sessionEstablished:)]) {
            [_delegate mdwamp:self sessionEstablished:details];
        }
        
        if (self.onSessionEstablished) {
            self.onSessionEstablished(self, details);
        }
        
    } else if ([message isKindOfClass:[MDWampAbort class]]) {
        
        MDWampAbort *abort = (MDWampAbort *)message;
        _explicitSessionClose = YES;
        [self.transport close];
  
        if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:closedSession:reason:details:)]) {
            [_delegate mdwamp:self closedSession:MDWampConnectionAborted reason:abort.reason details:abort.details];
        }
        
        if (self.onSessionClosed) {
            self.onSessionClosed(self, MDWampConnectionAborted, abort.reason, abort.details);
        }
        
    } else if ([message isKindOfClass:[MDWampGoodbye class]]) {
        
        // Received Goodbye message
        MDWampGoodbye *goodbye = (MDWampGoodbye *)message;
        
        // if we initiated the disconnection we don't send the goddbye back
        if (!self.goodbyeSent) {
            MDWampGoodbye *goodbyeResponse = [[MDWampGoodbye alloc] initWithPayload:@[@{}, @"wamp.error.goodbye_and_out"]];
            [self sendMessage:goodbyeResponse];
        }
        
        // close either way
        [self.transport close];
        
        if (_delegate && [_delegate respondsToSelector:@selector(mdwamp:closedSession:reason:details:)]) {
            [_delegate mdwamp:self closedSession:MDWampConnectionClosed reason:goodbye.reason details:goodbye.details];
        }
        
        if (self.onSessionClosed) {
            self.onSessionClosed(self, MDWampConnectionClosed, goodbye.reason, goodbye.details);
        }
        
    } else if ([message isKindOfClass:[MDWampError class]]) {
        
        // Manage different errors based on the type code
        // that relates to message classes
        
        MDWampError *error = (MDWampError *)message;
        
        NSString *errorType = [[MDWampMessageFactory sharedFactory] nameFromCode:error.type];
        if ([errorType isEqual:kMDWampSubscribe]) {
            // It's a subscribe error
            NSArray *callbacks = self.subscriptionRequests[error.request];

            if (!callbacks) {
                return;
            }
            
            void(^resultCallback)(NSError *)  = callbacks[0];
            
            resultCallback([error makeError]);

            // clean subscriber structures
            [self.subscriptionRequests removeObjectForKey:error.request];
            NSString *topicName = [self.subscriptionID allKeysForObject:error.request][0];
            [self.subscriptionID removeObjectForKey:topicName];
            
        } else if ([errorType isEqual:kMDWampUnsubscribe]) {
            NSArray *callbacks = self.subscriptionRequests[error.request];
            
            if (!callbacks) {
                return;
            }
            
            void(^resultCallback)(NSError *)  = callbacks[0];
            resultCallback([error makeError]);
            
            // cleanup
            [self.subscriptionRequests removeObjectForKey:error.request];
            
        } else if ([errorType isEqual:kMDWampPublish ]) {
            
            void(^resultCallback)(NSError *) = [self.publishRequests objectForKey:error.request];
            
            if (resultCallback) {
                resultCallback([error makeError]);
            }
            
            // cleanup
            [self.publishRequests removeObjectForKey:error.request];
            
        } else if ([errorType isEqual:kMDWampCall]) {

            void(^resultcallback)(MDWampResult *, NSError *) = self.rpcCallbackMap[error.request];
            if (resultcallback) {
                resultcallback(nil, [error makeError]);
            }

            [self.rpcCallbackMap removeObjectForKey:error.request];
            
        } else if ([errorType isEqual:kMDWampRegister]) {
            NSArray *registrationRequest = [self.rpcRegisterRequests objectForKey:error.request];
            if (!registrationRequest) {
                MDWampDebugLog(@"registration not present ignore");
                return;
            }
            
            // remove payload of the request
            [self.rpcRegisterRequests removeObjectForKey:error.request];
            
            void(^resultCallback)(NSError *) = registrationRequest[0];
            resultCallback([error makeError]);

        } else if ([errorType isEqual:kMDWampUnregister]) {
            NSArray *unregistrationRequest = [self.rpcUnregisterRequests objectForKey:error.request];
            if (!unregistrationRequest) {
                MDWampDebugLog(@"request not present ignoring");
                return;
            }
            
            // remove unregister request
            [self.rpcUnregisterRequests removeObjectForKey:error.request];
            
            void(^resultCallback)(NSError *) = unregistrationRequest[1];
            if (resultCallback) {
                resultCallback([error makeError]);
            }
        }
        
    } else if ([message isKindOfClass:[MDWampSubscribed class]]) {
        
        MDWampSubscribed *subscribed = (MDWampSubscribed *)message;
        NSArray *callbacks = self.subscriptionRequests[subscribed.request];
        
        // retrieve list of subscribers
        NSMutableArray *subscribers = [self.subscriptionEvents objectForKey:subscribed.subscription];
        if (subscribers == nil) {
            subscribers = [[NSMutableArray alloc] init];
            [self.subscriptionEvents setObject:subscribers forKey:subscribed.subscription];
        }
        [subscribers addObject:callbacks[1]];
        
        // clean subscriptionRequest map once called the callback
        [self.subscriptionRequests removeObjectForKey:subscribed.request];
        
        void(^resultCallback)(NSError *)  = callbacks[0];
        resultCallback(nil);
        
        
    } else if ([message isKindOfClass:[MDWampUnsubscribed class]]) {
        MDWampUnsubscribed *unsub = (MDWampUnsubscribed *)message;
        NSArray *infos = self.subscriptionRequests[unsub.request];
        
        NSNumber *subscription = self.subscriptionID[infos[1]];
        [self.subscriptionEvents removeObjectForKey:subscription];
        [self.subscriptionID removeObjectForKey:infos[1]];
        
        [self.subscriptionRequests removeObjectForKey:unsub.request];
        
        void(^resultCallback)(NSError *) = infos[0];
        resultCallback(nil);
        
    } else if ([message isKindOfClass:[MDWampPublished class]]) {
        MDWampPublished *pub = (MDWampPublished *)message;
        
        void(^resultCallback)(NSError *) = [self.publishRequests objectForKey:pub.request];
        if (resultCallback) {
            resultCallback(nil);
            
            [self.publishRequests removeObjectForKey:pub.request];
        }
    } else if ([message isKindOfClass:[MDWampEvent class]]) {
        MDWampEvent *event = (MDWampEvent *)message;
        NSArray *events = [self.subscriptionEvents objectForKey:event.subscription];
        
        for (void(^eventCallback)(MDWampEvent *) in events) {
            if (eventCallback) {
                eventCallback(event);
            }
        }
        
        
    } else if ([message isKindOfClass:[MDWampResult class]]) {
        MDWampResult *result = (MDWampResult *)message;
        
        void(^resultcallback)(MDWampResult *, NSError *) = self.rpcCallbackMap[result.request];
        
        if (resultcallback) {
            resultcallback(result, nil);
        }
        
        [self.rpcCallbackMap removeObjectForKey:result.request];
    } else if ([message isKindOfClass:[MDWampRegistered class]]) {
        MDWampRegistered *registered = (MDWampRegistered *)message;
        
        NSArray *registrationRequest = self.rpcRegisterRequests[registered.request];
        if (!registrationRequest) {
            MDWampDebugLog(@"request is not present, ignoring it");
            return;
        }
        
        // store the procedure
        [self.rpcRegisteredProcedures setObject:registrationRequest[2] forKey:registered.registration];
        
        // map uri to registrationID
        [self.rpcRegisteredUri setObject:registered.registration forKey:registrationRequest[1]];
        
        void(^resultcallback)(NSError *) = registrationRequest[0];
        
        // cleanup, remove the request
        [self.rpcRegisterRequests removeObjectForKey:registered.request];
        
        if (resultcallback) {
            resultcallback(nil);
        }
        
        
        
    } else if ([message isKindOfClass:[MDWampUnregistered class]]) {
        MDWampUnregistered *unregistered    = (MDWampUnregistered *)message;
        NSArray *unregistrationRequest      = self.rpcUnregisterRequests[unregistered.request];
        void(^resultcallback)(NSError *)    = unregistrationRequest[1];
        NSNumber *registrationID            = unregistrationRequest[0];
        
        if (resultcallback) {
            resultcallback(nil);
        }
        
        // remove registered procedure
        [self.rpcRegisteredProcedures removeObjectForKey:registrationID];
        
        // remove uri mapping
        [self.rpcRegisteredUri enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isEqual:registrationID]) {
                [self.rpcRegisteredUri removeObjectForKey:key];
                *stop = YES;
            }
        }];
        
        // cleanup request
        [self.rpcUnregisterRequests removeObjectForKey:unregistered.request];
        
    } else if ([message isKindOfClass:[MDWampInvocation class]]) {
        MDWampInvocation *invocation = (MDWampInvocation *)message;
        
        id(^procedure)(NSDictionary* details, NSArray *arguments, NSDictionary *argumentsKW) = [self.rpcRegisteredProcedures objectForKey:invocation.registration];
        
        id result = procedure(invocation.details, invocation.arguments, invocation.argumentsKw);
        
        // creating the yield message
        MDWampYield *yield = [[MDWampYield alloc] initWithPayload:@[invocation.request, @{}]];
        
        // try to parse result and craft a meaningful YIELD
        if (result == nil) {
            // nothing to do procedure is returning a void
        } else if([result isKindOfClass:[NSDictionary class]]) {
            yield.argumentsKw = result;
        } else if([result isKindOfClass:[NSArray class]]) {
            yield.arguments = result;
        } else {
            yield.arguments = @[result];
        }

        [self sendMessage:yield];
    }
}

- (void) sendMessage:(id<MDWampMessage>)message
{
    MDWampDebugLog(@"Sending %@", message);
    if ([message isKindOfClass:[MDWampGoodbye class]]) {
        self.goodbyeSent = YES;
    }
    NSArray *marshalled = [message marshall];
    id packed = [self.serializator pack:marshalled];
    [self.transport send:packed];
}



#pragma mark -
#pragma mark Commands

#pragma mark -
#pragma mark Pub/Sub
- (void) subscribe:(NSString *)topic
           onEvent:(void(^)(MDWampEvent *payload))eventBlock
            result:(void(^)(NSError *error))result
{
    NSNumber *request = [self generateID];
    MDWampSubscribe *subscribe = [[MDWampSubscribe alloc] initWithPayload:@[request, @{}, topic]];
    
    // we have to wait Subscribed message before add event
    [self.subscriptionRequests setObject:@[result, eventBlock] forKey:request];
    [self.subscriptionID setObject:request forKey:topic];

    [self sendMessage:subscribe];
}

- (void)unsubscribe:(NSString *)topic result:(void(^)(NSError *error))result
{
    if (!self.subscriptionID[topic] && !self.subscriptionEvents[topic]) {
        // inexistent sunscription we abort
        MDWampError *error = [[MDWampError alloc] initWithPayload:@[@-12, @0, @{}, @"mdwamp.error.no_such_subscription"]];
        result([error makeError]);
        return;
    }
    
    NSNumber *request = [self generateID];
    NSNumber *subscription = self.subscriptionID[topic];
    NSArray *payload = @[request, subscription];
    // storing callback for unsubscription result
    [self.subscriptionRequests setObject:@[result, topic] forKey:request];
    MDWampUnsubscribe *unsubscribe = [[MDWampUnsubscribe alloc] initWithPayload:payload];
    [self sendMessage:unsubscribe];
}

- (void) publishTo:(NSString *)topic
              args:(NSArray*)args
                kw:(NSDictionary *)argsKw
           options:(NSDictionary *)options
            result:(void(^)(NSError *error))result
{
    NSNumber *request = [self generateID];
    if (options == nil)
        options = @{};
    
    MDWampPublish *msg = [[MDWampPublish alloc] initWithPayload:@[request, options, topic]];
    if (args)
        msg.arguments = args;
    
    if (argsKw)
        msg.argumentsKw = argsKw;
    
    if (options[@"acknowledge"]) {
        // store callback to later use if acknowledge is TRUE
        [self.publishRequests setObject:result forKey:request];
    }
    
    [self sendMessage:msg];
}

- (void) publishTo:(NSString *)topic
              args:(NSArray*)args
            result:(void(^)(NSError *error))result
{
    [self publishTo:topic args:args kw:nil options:nil result:result];
}

- (void) publishTo:(NSString *)topic
           payload:(id)payload
            result:(void(^)(NSError *error))result
{
    if ([payload isKindOfClass:[NSDictionary class]]) {
        [self publishTo:topic args:nil kw:payload options:nil result:result];
    } else if ([payload isKindOfClass:[NSArray class]]) {
        [self publishTo:topic args:payload kw:nil options:nil result:result];
    } else {
        [self publishTo:topic args:@[payload] kw:nil options:nil result:result];
    }
}

#pragma mark -
#pragma mark Remote Procedure Call

- (void) call:(NSString*)procUri
              args:(NSArray*)args
            kwArgs:(NSDictionary*)argsKw
          complete:(void(^)(MDWampResult *result, NSError *error))completeBlock
{
    NSNumber *request = [self generateID];


    MDWampCall *msg = [[MDWampCall alloc] initWithPayload:@[request, @{}, procUri]];
    if (args)
        msg.arguments = args;
    
    if (argsKw)
        msg.argumentsKw = argsKw;
    
    [self.rpcCallbackMap setObject:completeBlock forKey:msg.request];
    
    [self sendMessage:msg];

}

- (void) registerRPC:(NSString *)procUri
           procedure:(id (^)(NSDictionary* details, NSArray *arguments, NSDictionary *argumentsKW))procedureBlock
              result:(void(^)(NSError *error))resultCallback
{
    NSNumber *request = [self generateID];
    
    MDWampRegister *msg = [[MDWampRegister alloc] initWithPayload:@[request, @{}, procUri]];
    
    [self.rpcRegisterRequests setObject:@[resultCallback, procUri, procedureBlock] forKey:request];
    
    [self sendMessage:msg];
}

- (void) unregisterRPC:(NSString *)procUri
                result:(void(^)(NSError *error))resultCallback
{
    NSNumber *request = [self generateID];
    NSNumber *registrationID = [self.rpcRegisteredUri objectForKey:procUri];
    if (registrationID == nil) {
        resultCallback([NSError errorWithDomain:kMDWampErrorDomain code:12 userInfo:@{NSLocalizedDescriptionKey: @"wamp.error.no_such_registration"}]);
        return;
    }
    MDWampUnregister *msg = [[MDWampUnregister alloc] initWithPayload:@[request, registrationID]];
    [self.rpcUnregisterRequests setObject:@[registrationID, resultCallback] forKey:request];
    [self sendMessage:msg];
}

@end
