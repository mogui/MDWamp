# What is it MDWamp ?

MDWamp is a client side objective-C implementation of the WebSocket subprotocol [WAMP][wamp_link].  
It use [SocketRocket][socket_rocket] as WebSocket Protocol implementation.

With this library and with a server [implementation of WAMP protocol][wamp_impl] you can bring Real-time notification not only for a web app (as WebSocket was created for) but also on your mobile App, just like an inner-app Apple Push Notifcation Service, avoiding the hassle of long polling request to the server for getting new things.

WAMP in its creator words is:

> an open WebSocket subprotocol that provides two asynchronous messaging patterns: RPC and PubSub.

but what are RPC and PubSub? they give a [nice and neat explanation][faq] if you have doubts


## Changes

### 1.1.0

- Added OSX framework target
- dropped iOS 4 compatibility now iOS >= 5.0 is required
- added block callback for connection, rpc and pub/sub messages
- removed RPC and Event delegates (now they only works with blocks)
- added unit test

## Installation with CocoaPods

[CocoaPods][cocoapods] is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries.
Just add this to your Podfile
	pod "MDwamp" 

## Installation from source

- clone the repository: `git clone git@github.com:mogui/MDWamp.git`
- run a `git submodule init && git submodule update` inside the MDWamp directory to clone the SocketRocket dependancy
- Add MDWamp.xcodeproj as a subproject of your project or in your workspace.
- Use libMDwamp (iOS) or MDWamp.framework (OS X) target as a dependancy 
- Add `-ObjC` to your **other linker flags** option
- Link your app against these dependancies:
	- libicucore.dylib
	- CFNetwork.framework
	- Security.framework
	- Foundation.framework
- Depending on how you configure your project you may need to `#import` either `<MDWamp/MDWamp.h>` or `"MDWamp.h"`

## API

MDWamp is made of a main class `MDWamp` that does all the work it makes connection to the server and expose methods to publish an receive events to and from a topic, and to call Rempte Procedure.

You start a connection initing an MDWamp object, and by setting some features like auto reconnect:
	
	// if you want debug log set this to YES, default is NO
	[MDWamp setDebug:YES];
	
	MDWamp *wamp = [[MDWamp alloc] initWithUrl:@"ws://localhost:9000" delegate:self];

	// set if MDWAMP should automatically try to reconnect after a network fail default YES
	[wamp setShouldAutoreconnect:YES];
	
	// set number of times it tries to autoreconnect after a fail
	[wamp setAutoreconnectMaxRetries:2];
	
	// set seconds between each reconnection try
	[wamp setAutoreconnectDelay:5];


when your done and you want to fire the connection:

	[wamp connect];

to disconnect:

	[wamp disconnect];

You can optionally implement two methods in the delegate you've setted when initing MDWamp

- `- (void) onOpen;`   
Called when client connect to the server
- `- (void) onClose:(int)code reason:(NSString *)reason;`    
Called when client disconnect from the server

You can also provide similar callback instead of using the delegate:

	@property (nonatomic, copy) void (^onConnectionOpen)(MDWamp *client);
	@property (nonatomic, copy) void (^onConnectionClose)(MDWamp *client, NSInteger code, NSString *reason);

The Header files of `MDWamp` class and of the Delegates are all well commented so the API is trivial, anyway here are some usage examples

### Call a remote procedure:

	[_wc call:@"http://example.com/simple/calc#add" complete:^(NSString *callURI, id result, NSError *error) {
	    if (error== nil) {
	        // do something with result
	    } else {
	        // handle the error
	    }
	} args:@2, @3, nil];

### Publish to a topic a this json object `{"user" : ["foo", "bar"]}`:

	[wamp publish:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil],@"user", nil] toTopic:@"http://example.com/simple" excludeMe:NO];

### Subscribe to a Topic and handle received events:

	[client subscribeTopic:@"http://example.com/simple/simple" onEvent:^(id payload) {
        // do something with the payload
    }];

### Authenticate using WAMP-CRA:

	- (void) onOpen
	{
	    [wamp authReqWithAppKey:appKey andExtra:nil];
	}

	- (void) onAuthReqWithAnswer:(NSString *)answer
	{	    
	    [wamp authSignChallenge:answer withSecret:appSecret];
	}

	- (void) onAuthSignWithSignature:(NSString *)signature
	{
	    [wamp authWithSignature:signature];
	}

	// then you have these callbakcs
	- (void) onAuthWithAnswer:(NSString *)answer;
	- (void) onAuthFailForCall:(NSString *)procCall withError:(NSError *)error;

### Authenticate using WAMP-CRA (Block-based):

	- (void) onOpen
	{
		[wamp authWithKey:key Secret:secret Extra:nil 
			Success:^(NSString *answer) {
				NSLog(@"Authenticated");
    		} Error:^(NSString *procCall, NSString *errorURI, NSString *errorDetails) {
        		NSLog(@"Auth Fail:%@:%@",errorURI,errorDetails);
    		}
	   	];
	}


## Test
to run the unit test you have to install [autobahn test suite](http://autobahn.ws/testsuite/installation/) and run the test server this way:

	wstest -d -m wampserver -w ws://localhost:9000

then you can run the test target.

## Authors
- [mogui](https://github.com/mogui/)
- [cvanderschuere](https://github.com/cvanderschuere)
- [JohnFricker](https://github.com/JohnFricker)

## Copyright
Copyright © 2012 Niko Usai. See LICENSE for details.   
WAMP is trademark of [Tavendo GmbH][tavendo].

[wamp_link]: http://wamp.ws/
[wamp_impl]: http://wamp.ws/implementations
[cocoapods]: http://cocoapods.org/
[luke]: https://github.com/lukeredpath
[ios_fake_framework_link]: https://github.com/kstenerud/iOS-Universal-Framework
[lib_pusher]: https://github.com/lukeredpath/libPusher
[socket_rocket]: https://github.com/square/SocketRocket
[downpage]: http://github.com/mogui/MDWamp/downloads]
[faq]: http://wamp.ws/faq#rpc
[tavendo]: http://www.tavendo.de/
