//
//  MDWampClientConfig.m
//  MDWamp
//
//  Created by Niko Usai on 09/10/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampClientConfig.h"

#pragma Constants

NSString * const kMDWampRolePublisher   = @"publisher";
NSString * const kMDWampRoleSubscriber  = @"subscriber";
NSString * const kMDWampRoleCaller      = @"caller";
NSString * const kMDWampRoleCallee      = @"callee";

@implementation MDWampClientConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.roles = @{
          kMDWampRolePublisher : @{},
          kMDWampRoleSubscriber : @{},
          kMDWampRoleCaller : @{},
          kMDWampRoleCallee : @{}
        };
    }
    return self;
}

- (NSDictionary *)getHelloDetails {
    NSMutableDictionary *d =  [NSMutableDictionary dictionaryWithDictionary:@{@"roles" : self.roles}];
    
    if (self.agent) {
        d[@"agent"] = self.agent;
    }
    
    return [NSDictionary dictionaryWithDictionary:d];
}

@end
