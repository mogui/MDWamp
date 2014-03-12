//
//  MDWampSerialization.h
//  MDWamp
//
//  Created by Niko Usai on 09/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDWampSerialization <NSObject>

- (NSData*) pack:(NSArray*)arguments;
- (NSArray*) unpack:(NSData*)data;
- (NSData*) packArguments:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

@end
