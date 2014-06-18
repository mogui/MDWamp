//
//  MDWampTransportMock.m
//  MDWamp
//
//  Created by Niko Usai on 12/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampTransportMock.h"
#import "MDWamp.h"
#import "MDWampMessages.h"
#import "NSMutableArray+MDStack.h"
#import "MDWampConstants.h"


@interface MDWampTransportMock ()
@property (strong) NSArray *proto;
@property (assign) BOOL connected;
@end


@implementation MDWampTransportMock

- (id)initWithServer:(NSURL *)request protocolVersions:(NSArray *)protocols
{
    self = [super init];
    if (self) {
        self.openWillFail = NO;
        self.connected = NO;
        self.sendBuffer = [[NSMutableArray alloc] init];
        self.serializationClass = 0;
    }
    return self;
}

- (void) open
{
    NSLog(@"Opening transport");
    if (self.openWillFail) {
        NSError *error = [NSError errorWithDomain:kMDWampErrorDomain code:-10 userInfo:@{NSLocalizedDescriptionKey: @"Opening the transport failed miserably"}];
        [self.delegate transportDidFailWithError:error];
    } else {
        [self.delegate transportDidOpenWithVersion:kMDWampVersion2 andSerialization:self.serializationClass];
        self.connected = YES;
    }
}

- (void) close
{
    NSLog(@"Closing the transport");
    self.connected = NO;
    [self.delegate transportDidCloseWithError:nil];
}

- (BOOL) isConnected
{
    return self.connected;
}

- (void)send:(id)data
{
    [self.sendBuffer push:data];
}


// Test methods
- (void) triggerDidReceiveMessage:(id)msg
{
    [self.delegate transportDidReceiveMessage:msg];
}



@end
