//
//  MDWampTest.h
//  MDWamp
//
//  Created by Niko Usai on 13/12/13.
//  Copyright (c) 2013 mogui.it. All rights reserved.
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

#ifndef MDWamp_MDWampTest_h
#define MDWamp_MDWampTest_h

/*
 *  Wamp autobahn testsute server url,
 * launched by a simple wstest -d -m wampserver -w URL
 */
#define kMDWampTestsServerV1URL @"ws://localhost:9000"
/**
 *  Wamp Crossbar server url
 * launched with all defaults crossbar start
 */
#define kMDWampTestsServerV2URL @"ws://localhost:8080/ws"

/*
 * Define the time a single tests wait for a network call to end
 * Increase if test server response are slow
 */
#define kMDWampTestsNetworkWait 1

/**
 * Handler method to dispatch after some seconds
 * in order to wait for a network reply
 *
 * @param blockToRun - the block of code to run
 */
static inline void wait_for_network(void (^blockToRun)(void) ){
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kMDWampTestsNetworkWait * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), blockToRun);
}

#define kMDWampSerializationMock @"MDWampSerializationMock"

#import "MDWampClientDelegateMock.h"
#import "MDWampTransportMock.h"
#import "MDWampSerializationMock.h"

#endif
