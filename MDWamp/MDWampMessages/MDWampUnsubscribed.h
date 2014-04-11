//
//  MDWampUnsubscribed.h
//  MDWamp
//
//  Created by Niko Usai on 11/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"
@interface MDWampUnsubscribed : NSObject <MDWampMessage>
@property (nonatomic, strong) NSNumber *request;
@end
