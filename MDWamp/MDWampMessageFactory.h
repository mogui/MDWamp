//
//  MDWampMessageFactory.h
//  MDWamp
//
//  Created by Niko Usai on 01/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampConstants.h"

@interface MDWampMessageFactory : NSObject
+ (Class) messageClassFromCode:(NSNumber*)code forVersion:(MDWampVersion)version;
@end
