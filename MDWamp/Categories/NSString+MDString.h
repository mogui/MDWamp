//
//  NSString+MDString.h
//  MDWamp
//
//  Created by Niko Usai on 09/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MDString)
+ (NSString*) stringWithRandomId;
- (NSString *) hmacSHA256DataWithKey:(NSString *)key;
@end
