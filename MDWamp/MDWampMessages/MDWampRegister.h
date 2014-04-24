//
//  MDWampRegister.h
//  MDWamp
//
//  Created by Niko Usai on 22/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"
@interface MDWampRegister : NSObject <MDWampMessage>
@property (nonatomic, strong) NSNumber *request;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong) NSString *procedure;
@end
