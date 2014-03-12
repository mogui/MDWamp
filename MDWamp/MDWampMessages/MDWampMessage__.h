//
//  MDWampMessage.h
//  MDWamp
//
//  Created by pronk on 13/09/12.
//  Copyright (c) 2012 mogui. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

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



@interface MDWampMessage__ : NSObject
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
