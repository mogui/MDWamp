//
//  RawSocketTransport.m
//  MDWamp
//
//  Created by Niko Usai on 05/07/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampTransportRawSocket.h"
@interface MDWampTransportRawSocket () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) NSInteger port;

@end
@implementation MDWampTransportRawSocket

- (id)initWithHost:(NSString*)host port:(NSInteger)port
{
    self = [super init];
    if (self) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
        self.host = host;
        self.port = port;
        self.serialization = kMDWampSerializationJSON;
        
    }
    return self;
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    if (_delegate && [_delegate respondsToSelector:@selector(transportDidOpenWithVersion:andSerialization:)]) {
        // NOTICE always version 2 !!
        [_delegate transportDidOpenWithSerialization:self.serialization];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
}

- (void) open
{
    NSError *err = nil;
    if (![_socket connectToHost:self.host onPort:self.port error:&err])
    {
        NSLog(@"I goofed: %@", err);
        return;
    }
}

- (void) close
{
   
}

- (BOOL) isConnected
{
    return YES;
}

- (void)send:(id)data
{
    unsigned int len = (unsigned int)[data length];
    NSMutableData *dd = [NSMutableData dataWithBytes:&len length:sizeof(unsigned int)];
    [dd appendData:data];
    [_socket writeData:dd withTimeout:0.5 tag:1];
}

@end
