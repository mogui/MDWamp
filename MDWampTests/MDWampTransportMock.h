//
//  MDWampTransportMock.h
//  MDWamp
//
//  Created by Niko Usai on 12/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampTransport.h"
@interface MDWampTransportMock : NSObject <MDWampTransport>
@property id<MDWampTransportDelegate>delegate;
@property (nonatomic, readonly) NSString *subprotocol;
@property (nonatomic, strong) id<MDWampProtocolVersion>protocol;
@property (nonatomic, strong) id<MDWampSerialization>serialization;

// test utility
@property (assign) BOOL openWillFail;
@property (nonatomic, strong) NSMutableArray *sendBuffer;
- (void) triggerDidReceiveMessage:(MDWampMessage *)msg;
@end
