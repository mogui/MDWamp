//
//  NSMutableArray+MDStack.m
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "NSMutableArray+MDStack.h"

@implementation NSMutableArray (MDStack)

- (id) shift 
{
    id obj = [self objectAtIndex:0];
    [self removeObjectAtIndex:0];
    return obj;
}

- (void) unshift:(id)object
{
    [self insertObject:object atIndex:0];
}

- (id) pop
{
    id obj = [self lastObject];
    [self removeLastObject];
    return obj;
}

- (void) push:(id)object
{
    [self addObject:object];
}

@end
