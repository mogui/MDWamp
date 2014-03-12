//
//  MDWampError.h
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"
#warning MErge with version 1 call error?? direi di si

@interface MDWampError : MDWampMessage
@property (nonatomic, assign) NSNumber *type;
@property (nonatomic, assign) NSNumber *request;
@property (nonatomic, strong) NSDictionary *details;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSArray *arguments;
@property (nonatomic, strong) NSDictionary *argumentsKw;
@end
