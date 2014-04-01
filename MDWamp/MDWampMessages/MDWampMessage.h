//
//  MDWampMessage.h
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampConstants.h"

@protocol MDWampMessage <NSObject>

- (id) initWithPayload:(NSArray *)payload;
- (NSArray *) marshallFor:(MDWampVersion)version;
@end

