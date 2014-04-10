//
//  MDWampWelcome.h
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"

@interface MDWampWelcome : NSObject<MDWampMessage>
@property (nonatomic, strong) NSNumber *session;
@property (nonatomic, strong) NSDictionary *details;
@property (nonatomic, readonly) NSDictionary *roles;
@property (nonatomic, strong) NSNumber *protocolVersion;
@property (nonatomic, strong) NSString *serverIdent;
@end
