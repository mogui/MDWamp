//
//  MDWampTransportdelegateMock.h
//  MDWamp
//
//  Created by Niko Usai on 17/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampTransportDelegate.h"
@interface MDWampTransportDelegateMock : NSObject <MDWampTransportDelegate>
@property (assign) BOOL didReceiveCalled;
@property (assign) BOOL didOpenCalled;
@property (assign) BOOL didFailCalled;
@property (assign) BOOL didCloseCalled;
@end
