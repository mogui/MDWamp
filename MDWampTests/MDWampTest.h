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
#define kMDWampTestsServerURL @"ws://localhost:9000"


/*
 * Define the time a single tests wait for a network call to end
 * Increase if test server response are slow
 */
#define kMDWampTestsNetworkWait 1

/*
 *  Asyncronous Tests, blocks macro thanks to:
 *  http://dadabeatnik.wordpress.com/2013/09/12/xcode-and-asynchronous-unit-testing/
 */

// Set the flag for a block completion handler
#define StartBlock() __block BOOL waitingForBlock = YES

// Set the flag to stop the loop
#define EndBlock() waitingForBlock = NO

// Wait and loop until flag is set
#define WaitUntilBlockCompletes() WaitWhile(waitingForBlock)

// Macro - Wait for condition to be NO/false in blocks and asynchronous calls
#define WaitWhile(condition) \
do { \
while(condition) { \
[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]; \
} \
} while(0)

#include "MDWampClientDelegateMock.h"

#endif
