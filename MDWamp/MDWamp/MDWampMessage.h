//
//  MDWampMessage.h
//  iOS_WAMP_Test
//
//  Created by pronk on 13/09/12.
//  Copyright (c) 2012 mogui. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	MDWampMessageTypeWelcome,
	MDWampMessageTypePrefix,
	MDWampMessageTypeCall,
	MDWampMessageTypeCallResult,
	MDWampMessageTypeCallError,
	MDWampMessageTypeSubscribe,
	MDWampMessageTypeUnsubscribe,
	MDWampMessageTypePublish,
	MDWampMessageTypeEvent
} MDWampMessageType;



@interface MDWampMessage : NSObject
{
	NSMutableArray *messageStack;
	MDWampMessageType type;
}
@property (readonly) MDWampMessageType type;

- (id) initWithResponseArray:(NSArray*)responseArray;
- (id) initWithResponse:(NSString*)response;

- (id) shiftStack;
- (int) shiftStackAsInt;
- (NSString*) shiftStackAsString;
- (NSArray*) getRemainingArgs;

@end
