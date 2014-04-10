//
//  MDWampSubscribe.h
//  MDWamp
//
//  Created by Niko Usai on 10/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"
// [SUBSCRIBE, Request|id, Options|dict, Topic|uri]
@interface MDWampSubscribe : NSObject <MDWampMessage>
@property (nonatomic, strong) NSNumber *request;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong) NSString *topic;
@end
