//
//  MDWampTransportWebSocket.m
//  MDWamp
//
//  Created by Niko Usai on 11/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampTransportWebSocket.h"
#import "SRWebSocket.h"

@interface MDWampTransportWebSocket () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;

@end

@implementation MDWampTransportWebSocket 

- (id)initWithServer:(NSURL *)request protocolVersions:(NSArray *)protocols
{
    self = [super init];
    if (self) {
        _socket = [[SRWebSocket alloc] initWithURL:request protocols:protocols];
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
#warning TODO: gestire i sottoprotocolli per bene
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    [self.delegate transportDidFailWithError:error];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{

    if (wasClean) {
        [self.delegate transportDidCloseWithError:nil];
    } else {
#warning TODO settare l'error correttamente
        NSError *error = [NSError errorWithDomain:@"asd" code:code userInfo:@{}];
        [self.delegate transportDidCloseWithError:error];
    }
}


@end
