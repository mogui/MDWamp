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
@property NSString *subprotocol;

// test utility
@property (assign) BOOL openWillFail;
@property (assign) Class transportChooseVersion;
@property (assign) Class transportChooseSerialization;
@property (assign) NSMutableArray *sendBuffer;
- (void) triggerDidReceiveMessage:(id)msg;
@end
