//
//  MDWampTest.h
//  MDWamp
//
//  Created by Niko Usai on 13/12/13.
//  Copyright (c) 2013 mogui.it. All rights reserved.
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

#import "MDWampClientDelegateMock.h"
#import "MDWampTransportMock.h"
#import "MDWampSerializationMock.h"

#endif
