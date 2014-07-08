//
//  MDWampMessageFactory.m
//  MDWamp
//
//  Created by Niko Usai on 01/04/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
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

#import "MDWampMessageFactory.h"
#import "MDWampMessage.h"

@interface MDWampMessageFactory ()
@property (nonatomic, strong) NSDictionary *messageMapping;
@end

@implementation MDWampMessageFactory


+ (instancetype) sharedFactory {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MDWampMessageFactory alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.messageMapping = @{
                                @1  : kMDWampHello,
                                @2  : kMDWampWelcome,
                                @3  : kMDWampAbort,
                                @4  : kMDWampChallange,
                                @5  : kMDWampAuthenticate,
                                @6  : kMDWampGoodbye,
                                @7  : kMDWampHeartbeat,
                                @8  : kMDWampError,
                                @16 : kMDWampPublish,
                                @17 : kMDWampPublished,
                                @32 : kMDWampSubscribe,
                                @33 : kMDWampSubscribed,
                                @34 : kMDWampUnsubscribe,
                                @35 : kMDWampUnsubscribed,
                                @36 : kMDWampEvent,
                                @48 : kMDWampCall,
                                @49 : kMDWampCancel,
                                @50 : kMDWampResult,
                                @64 : kMDWampRegister,
                                @65 : kMDWampRegistered,
                                @66 : kMDWampUnregister,
                                @67 : kMDWampUnregistered,
                                @68 : kMDWampInvocation,
                                @69 : kMDWampInterrupt,
                                @70 : kMDWampYield };
    }
    return self;
}

- (NSString *)messageNameFromCode:(NSNumber*)code
{
    return self.messageMapping[code];
}

- (id<MDWampMessage>)messageObjectFromCode:(NSNumber*)code withPayload:(NSArray*)payload
{
    NSString *className = self.messageMapping[code];
    Class messageClass = NSClassFromString(className);
    if (!messageClass) {
        [NSException raise:@"it.mogui.mdwamp" format:@"Unimplemented message: %@", className];
    }
    return [(id<MDWampMessage>)[messageClass alloc] initWithPayload:payload];
}

//- (NSNumber *)messageCodeFromObject:(NSObject*)object
//{
//    NSString *className = [object className];
//    NSArray *keys = [self.messageMapping allKeysForObject:className];
//    return keys[0];
//}


@end
