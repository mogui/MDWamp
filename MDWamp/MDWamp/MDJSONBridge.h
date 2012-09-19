//
//  MDJSONBridge.h
//  MDWamp
//
//  Created by pronk on 19/09/12.
//  Copyright (c) 2012 mogui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDJSONBridge : NSObject

+ (id)objectFromJSONString:(NSString*)jsonString;
+ (NSString *)jsonStringFromObject:(id)object;
@end
