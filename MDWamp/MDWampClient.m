//
//  MDWampClient.m
//  MDWamp
//
//  Created by Niko Usai on 13/12/13.
//  Copyright (c) 2013 mogui.it. All rights reserved.
//

#import "MDWampClient.h"
#import "SRWebSocket.h"

@interface MDWampClient () <NSURLConnectionDelegate>
{
	int autoreconnectRetries;
}

@property (nonatomic, strong) NSURLRequest *server;
@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) NSString *serverIdent;
@property (nonatomic, strong) NSMutableDictionary *rpcDelegateMap;
@property (nonatomic, strong) NSMutableDictionary *rpcUriMap;
@property (nonatomic, strong) NSMutableDictionary *subscribersDelegateMap;

@end


@implementation MDWampClient

#pragma mark -
#pragma mark Init methods

- (id)initWithURLRequest:(NSURLRequest *)aServer delegate:(id<MDWampClientDelegate>)delegate
{
    self = [super init];
	if (self) {
		_shouldAutoreconnect = YES;
		_autoreconnectDelay = 3;
		_autoreconnectMaxRetries = 10;
		
        autoreconnectRetries = 0;
        
		self.server = aServer;
		self.delegate = delegate;
		
		self.rpcDelegateMap = [[NSMutableDictionary alloc] init];
		self.rpcUriMap = [[NSMutableDictionary alloc] init];
		self.subscribersDelegateMap = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)initWithURLRequest:(NSURLRequest *)aServer
{
    self = [self initWithURLRequest:aServer delegate:nil];
    return self;
}

- (id)initWithURL:(NSURL *)serverURL
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serverURL];
    self = [self initWithURLRequest:request delegate:nil];
    return self;
}


#pragma mark -
#pragma mark Connection

- (void) connect
{
	self.socket = [[SRWebSocket alloc] initWithURLRequest:_server protocols:[NSArray arrayWithObjects:@"wamp", nil]];
	//[self.socket setDelegate:self];
	[self.socket open];
    
}

- (void) disconnect
{
	[self.socket close];
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
	return (_socket!=nil)? _socket.readyState == SR_OPEN : NO;
}


@end
