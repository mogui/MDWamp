//
//  NSMutableArray+MDStack.h
//  MDWamp
//
//  Adds simple stack behavior to nsarry
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MDStack)
- (id) shift __attribute((ns_returns_retained));
- (void) unshift:(id)object;
- (id) pop __attribute((ns_returns_retained));
- (void) push:(id)object;
@end
