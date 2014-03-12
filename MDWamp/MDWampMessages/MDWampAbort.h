//
//  MDWampAbort.h
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"

@interface MDWampAbort : MDWampMessage
@property (nonatomic, strong) NSDictionary *details;
@property (nonatomic, strong) NSString *reason;
@end
