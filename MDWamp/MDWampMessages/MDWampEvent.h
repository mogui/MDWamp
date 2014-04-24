//
//  MDWampEvent.h
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"
// [EVENT, SUBSCRIBED.Subscription|id, PUBLISHED.Publication|id, Details|dict, PUBLISH.Arguments|list, PUBLISH.ArgumentsKw|dict]
@interface MDWampEvent : NSObject <MDWampMessage>
@property (nonatomic, strong) NSNumber *subscription;
@property (nonatomic, strong) NSNumber *publication;
@property (nonatomic, strong) NSString *topic;
@property (nonatomic, strong) NSDictionary *details;
@property (nonatomic, strong) NSArray *arguments;
@property (nonatomic, strong) NSDictionary *argumentsKw;
@property (nonatomic, assign) NSDictionary *event;
@end
