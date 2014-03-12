//
//  MDWampTransportWebSocket.h
//  MDWamp
//
//  Created by Niko Usai on 11/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampTransport.h"

@interface MDWampTransportWebSocket : NSObject <MDWampTransport>

@property id<MDWampTransportDelegate>delegate;
@property NSString *subprotocol;

@end
