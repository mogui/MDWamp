//
//  MDwampUnsubscribe.h
//  MDWamp
//
//  Created by Niko Usai on 11/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"

@interface MDWampUnsubscribe : NSObject <MDWampMessage>
@property (nonatomic, strong) NSString *topic;
@property (nonatomic, strong) NSNumber *request;
@property (nonatomic, strong) NSNumber *subscription;
@end
