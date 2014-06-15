//
//  MDWampYield.h
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"

@interface MDWampYield : NSObject <MDWampMessage>

@property (nonatomic, strong) NSNumber *request;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong) NSArray *arguments;
@property (nonatomic, strong) NSDictionary *argumentsKw;

@end
