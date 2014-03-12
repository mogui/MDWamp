//
//  MDWampProtocolVersionMock.h
//  MDWamp
//
//  Created by Niko Usai on 12/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampProtocolVersion.h"
@interface MDWampProtocolVersionMock : NSObject <MDWampProtocolVersion>
@property (assign) BOOL sendHello;
@property (assign) BOOL sendGoodbye;
@end
