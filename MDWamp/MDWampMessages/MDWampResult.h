//
//  MDWampResult.h
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"

@interface MDWampResult : NSObject <MDWampMessage>
@property (nonatomic, strong) NSNumber *request;
@property (nonatomic, strong) NSString *callID;
@property (nonatomic, strong) NSDictionary *details;
@property (nonatomic, strong) NSArray *arguments;
@property (nonatomic, strong) NSDictionary *argumentsKw;

@end
