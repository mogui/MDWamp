# What is it MDWamp ?

MDWamp is a client side objective-C implementation of the WebSocket subprotocol [WAMP][wamp_link].  
It use [SocketRocket][socket_rocket] as WebSocket Protocol implementation.

With this library and with a server [implementation of WAMP protocol][wamp_impl] you can bring Real-time notification not only for a web app (as WebSocket was created for) but also on your mobile App, just like an inner-app Apple Push Notifcation Service, avoiding the hassle of long polling request to the server for getting new things.

It is distributed as a iOS Fake Framework, a hack to bundle a staic library as a Framework on iOS (courtesy of the [nice work of kstenerud][ios_fake_framework_link] ) which simplify how you have to integrate this code into your existing app.

## Installation

You have two main option to integrate the lib in your project:

- Building it from source
- Download a pre-compiled framework

For both option notice that the library will use the native `NSJSONSerialization` to manage json objects, which is only available on iOS 5 and above, but the library is still compatible with iOS 4.x by switching to a runtime support to [JSONKit][jsonkit]. 

But in order for this fallback to work you **must manually include JSONKit by yourself** within the project, otherwise the lib will Raise an Exception (trick thanks to viewing [Luke Redpath][luke]'s code).

### Building from source

*(from [iOS Universal Framework Mk 7](https://github.com/kstenerud/iOS-Universal-Framework#building-your-ios-framework))*

1. Select your framework's scheme (any of its targets will do).
2. (optional) Set the "Run" configuration in the scheme editor. It's set to Debug by default but you'll probably want to change it to "Release" when you're ready to distribute your framework.
3. Build the framework (both "iOS device" and "Simulator" destinations will build the same universal binary, so it doesn't matter which you select).
4. Select your framework under "Products", then show in Finder.
5. Drag the `MDWamp.framework` folder in your project
6. Use it in your code by `#import <MDWamp/MDWamp.h>`

### pre-compiled framework

1. Download latest zip from [here](https://dl.dropbox.com/u/143623815/MDWamp/MDWamp.framework-1.0.zip)
2. Unzip it
3. Drag the `MDWamp.framework` folder in your project
4. Use it in your code by `#import <MDWamp/MDWamp.h>`

## Getting Started

WAMP in its creator words is:

> an open WebSocket subprotocol that provides two asynchronous messaging patterns: RPC and PubSub.

but what are RPC and PubSub? they give a [nice and neat explanation][faq] if you have doubts

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

### usage examples
The Header files of `MDWamp` class and of the Delegates are all well commented so the API is trivial, anyway here are some usage examples

*Call a remote procedure:*

	[wamp call:@"http://example.com/calc#add" withDelegate:self args:[NSNumber numberWithInt:8],[NSNumber numberWithInt:8], nil];

*Receive the call result / error by implementing the delegates method:*

	- (void) onResult:(id)result forCalledUri:(NSString *)callUri;
	- (void) onError:(NSString *)errorUri description:(NSString*)errorDesc forCalledUri:(NSString *)callUri;

*Publish to a topic a this json object `{"user" : ["foo", "bar"]}`:*

	[wamp publish:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil],@"user", nil] toTopic:@"http://example.com/simple" excludeMe:NO];

*Subscribe to a Topic:*

	[wamp subscribeTopic:@"http://example.com/simple" withDelegate:self];

*And receive Events from that topic implementing tis delegate metod:*
	
	- (void) onEvent:(NSString *)topicUri eventObject:(id)object;

*Authenticate using WAMP-CRA:*

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


## Copyright
Copyright © 2012 Niko Usai. See LICENSE for details.   
WAMP and is trademark of [Tavendo GmbH][tavendo].

[wamp_link]: http://wamp.ws/
[wamp_impl]: http://wamp.ws/implementations
[jsonkit]: https://github.com/johnezang/JSONKit
[luke]: https://github.com/lukeredpath
[ios_fake_framework_link]: https://github.com/kstenerud/iOS-Universal-Framework
[lib_pusher]: https://github.com/lukeredpath/libPusher
[socket_rocket]: https://github.com/square/SocketRocket
[downpage]: http://github.com/mogui/MDWamp/downloads]
[faq]: http://wamp.ws/faq#rpc
[tavendo]: http://www.tavendo.de/
