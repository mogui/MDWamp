//
//  RPCResponse.h
//  MDWamp
//
//  Created by Chris Vanderschuere on 9/15/13.
//  Copyright (c) 2013 mogui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDRPCResponse : NSObject

@property (nonatomic, strong) void (^resultBlock)(NSString* callURI, id result);
@property (nonatomic, strong) void (^errorBlock)(NSString* callURI, NSString* errorURI, NSString* errorDescription);

+ (instancetype) responseWithResult:(void(^)(NSString* callURI, id result))result
                              Error:(void(^)(NSString* callURI, NSString* errorURI, NSString* errorDescription))error;

@end
