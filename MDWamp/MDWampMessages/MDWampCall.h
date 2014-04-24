//
//  MDWampCall.h
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"

@interface MDWampCall : NSObject <MDWampMessage>
@property (nonatomic, strong) NSNumber *request;
@property (nonatomic, strong) NSString *callID;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong) NSString *procedure;
@property (nonatomic, strong) NSArray *arguments;
@property (nonatomic, strong) NSDictionary *argumentsKw;
@end
