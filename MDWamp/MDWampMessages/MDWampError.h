//
//  MDWampError.h
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampMessage.h"
#warning MErge with version 1 call error?? direi di si

@interface MDWampError : NSObject<MDWampMessage>
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *request;
@property (nonatomic, strong) NSString *callID;     // Used in version 1
@property (nonatomic, strong) NSDictionary *details;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSString *errorDesc;  // Used in vesion 1
@property (nonatomic, strong) NSArray *arguments;
@property (nonatomic, strong) NSDictionary *argumentsKw;
@end
