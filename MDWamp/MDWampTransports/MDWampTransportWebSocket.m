//
//  MDWampTransportWebSocket.m
//  MDWamp
//
//  Created by Niko Usai on 11/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampTransportWebSocket.h"
#import "SRWebSocket.h"
#import "NSMutableArray+MDStack.h"
@interface MDWampTransportWebSocket () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;

@end

@implementation MDWampTransportWebSocket 

- (id)initWithServer:(NSURL *)request protocolVersions:(NSArray *)protocols
{
    self = [super init];
    if (self) {
        NSMutableArray *supportedProtocols = [[NSMutableArray alloc] init];
        
        if ([protocols containsObject:kMDWampVersion1]) {
            [supportedProtocols unshift:@"wamp"];
        }
        
        if ([protocols containsObject:kMDWampVersion2]) {
            [supportedProtocols unshift:@"wamp.2.json"];
            [supportedProtocols unshift:@"wamp.2.msgpack"];
        } else if ([protocols containsObject:kMDWampVersion2JSON]) {
            [supportedProtocols unshift:@"wamp.2.json"];
        } else if ([protocols containsObject:kMDWampVersion2Msgpack]) {
            [supportedProtocols unshift:@"wamp.2.msgpack"];
        }
        
        NSAssert([supportedProtocols count] > 0, @"Specify a valid WAMP version");
        
        self.socket = [[SRWebSocket alloc] initWithURL:request protocols:supportedProtocols];
        [_socket setDelegate:self];
    }
    return self;
}

- (void) open
{
    [_socket open];
}

- (void) close
{
    [_socket close];
}

- (BOOL) isConnected
{
    return (_socket!=nil)? _socket.readyState == SR_OPEN : NO;
}

- (void)send:(id)data
{
    [_socket send:data];
}


#pragma mark SRWebSocket Delegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    [self.delegate transportDidReceiveMessage:message];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    MDWampDebugLog(@"negotiated protocol is %@", webSocket.protocol);
    NSArray *splittedProtocol = [webSocket.protocol componentsSeparatedByString:@"."];
    if ([splittedProtocol count] == 1) {
        [self.delegate transportDidOpenWithVersion:kMDWampVersion1 andSerialization:kMDWampSerializationJSON];
    } else if ([splittedProtocol count] > 1 && [splittedProtocol[1] isEqual:@"2"] && [splittedProtocol[2] isEqual:@"msgpack"]){
        [self.delegate transportDidOpenWithVersion:kMDWampVersion2 andSerialization:kMDWampSerializationMsgPack];
    } else if ([splittedProtocol count] > 1 && [splittedProtocol[1] isEqual:@"2"] && [splittedProtocol[2] isEqual:@"json"]){
        [self.delegate transportDidOpenWithVersion:kMDWampVersion2 andSerialization:kMDWampSerializationJSON];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    if (error.code==54) {
        //  if error is "The operation couldn’t be completed. Connection reset by peer"
        //  we call the close method
        [self.delegate transportDidCloseWithError:error];
    } else {
        [self.delegate transportDidFailWithError:error];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSError *error = [NSError errorWithDomain:kMDWampErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: reason}];
     [self.delegate transportDidCloseWithError:error];
}


@end
