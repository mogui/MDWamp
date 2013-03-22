//
//  MDCrypto.h
//  MDWamp
//
//  Created by Mathias on 3/21/13.
//  Copyright (c) 2013 mogui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDCrypto : NSObject

+ (NSString *) hmacSHA256Data:(NSString *)data withKey:(NSString *)key;

@end
