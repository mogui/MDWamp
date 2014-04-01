//
//  MDWampMessage.h
//  MDWamp
//
//  Created by Niko Usai on 08/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MDWampVersion1,
    MDWampVersion2
} MDWampProtocolVersion;

@interface MDWampMessage : NSObject
+ (Class) makeMessageFromCode:(NSNumber*)code forVersion:(MDWampProtocolVersion)version;

- (int) availableFromVersion;
- (NSArray *) marshall:(MDWampProtocolVersion)version;
- (id) initWithPayload:(NSArray *)payload;
@end
