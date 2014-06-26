//
//  MDWampSerialization.h
//  MDWamp
//
//  Created by Niko Usai on 09/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MDWampSerialization <NSObject>

- (id) pack:(NSArray*)arguments;
- (NSArray*) unpack:(id)data;

@end
