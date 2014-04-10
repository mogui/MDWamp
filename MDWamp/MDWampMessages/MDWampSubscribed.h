//
//  MDWampSubscribed.h
//  MDWamp
//
//  Created by Niko Usai on 10/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"

@interface MDWampSubscribed : NSObject <MDWampMessage>
@property (nonatomic, strong) NSNumber *request;
@property (nonatomic, strong) NSNumber *subscription;
@end
