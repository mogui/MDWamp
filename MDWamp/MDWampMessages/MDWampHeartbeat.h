//
//  MDWampHeartbeat.h
//  MDWamp
//
//  Created by Niko Usai on 26/08/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"
@interface MDWampHeartbeat : NSObject <MDWampMessage>
@property (nonatomic, strong) NSNumber *incomingSeq;
@property (nonatomic, strong) NSNumber *outgoingSeq;
@property (nonatomic, strong) NSString *discard;


@end
