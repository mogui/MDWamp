//
//  MDWampTransportdelegateMock.m
//  MDWamp
//
//  Created by Niko Usai on 17/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampTransportDelegateMock.h"
@interface MDWampTransportDelegateMock ()


@end
@implementation MDWampTransportDelegateMock

// message will either be an NSString or NSData
- (void)transportDidReceiveMessage:(NSData *)message {
    self.didReceiveCalled = YES;
}

- (void)transportDidOpenWithVersion:(MDWampVersion)version andSerialization:(MDWampSerializationClass)serialization {
    self.didOpenCalled = YES;
}

- (void)transportDidFailWithError:(NSError *)error {
    self.didFailCalled = YES;
}

- (void)transportDidCloseWithError:(NSError *)error {
    self.didCloseCalled = YES;
}

@end
