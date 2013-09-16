//
//  RPCResponse.m
//  MDWamp
//
//  Created by Chris Vanderschuere on 9/15/13.
//  Copyright (c) 2013 mogui. All rights reserved.
//

#import "MDRPCResponse.h"

@implementation MDRPCResponse
@synthesize resultBlock,errorBlock;

+ (instancetype) responseWithResult:(void(^)(NSString* callURI, id result))result
                              Error:(void(^)(NSString* callURI, NSString* errorURI, NSString* errorDescription))error{
    MDRPCResponse *response = [[MDRPCResponse alloc] init];
    response.resultBlock = result;
    response.errorBlock = error;
    
    return response;
}

@end
