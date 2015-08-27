develop [![Build Status](https://travis-ci.org/mogui/MDWamp.svg?branch=develop)](https://travis-ci.org/mogui/MDWamp)
master [![Build Status](https://travis-ci.org/mogui/MDWamp.svg?branch=master)](https://travis-ci.org/mogui/MDWamp)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# What is it?

MDWamp is a client side objective-C implementation of the WebSocket subprotocol [WAMP][wamp_link] (v2).  

With this library and with a server [implementation of WAMP protocol][wamp_impl] you can bring Real-time notification not only for a web app (as WebSocket was created for) but also on your mobile App, just like an inner-app Apple Push Notifcation Service, avoiding the hassle of long polling request to the server for getting new things.

WAMP in its creator words is:

> WAMP is an open WebSocket subprotocol that provides two application messaging patterns in one unified protocol:
Remote Procedure Calls + Publish & Subscribe.   
> Using WAMP you can build distributed systems out of application components which are loosely coupled and communicate in (soft) real-time.

It uses well known and maintained libraries for low level connections: [SocketRocket][socket_rocket] and [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket).


## Installation

### OSX
- By using [CocoaPods][cocoapods], just add to your Podfile   
	`pod 'MDWamp'`

- Use MDWamp.framework  
Build the framework target of the project, just be sure to `git submodule init && git submodule update` to get the dependancies


### iOS
I'm [sick and tired of iOS shitting support for distributing libraries][staticlibpost] *(hopefully with Xcode 6 all will change !!)*   
so just cocoapods support for ya:
Just add this to your Podfile

	pod "MDWamp" 


## Demo App

The Xcode project has a `MDWampDemo` target that is an iOS Application that you can run (better on two or more device / simulator) and explore.   
It expects a [crossbar.io](http://crossbar.io/) server running on the local machine with the config file under the demo folder.   
Having it [installed](https://github.com/crossbario/crossbar/wiki/Quick-Start) just cd in `demo` directory and run `crossbar start`.

By looking at the simple code of the application you can see sample usage of the library and have a taste of the capability of the WAMP protocol.


## API

MDWamp is made of a main class `MDWamp` that does all the work, it makes connection to the server and expose methods to publish an receive events to and from a topic, and to call Rempte Procedure.

To instantiate it you must specify a transport (since WAMP can support different transports) in accord to the server you're connecting to.   

Right now two transports are implemented `WebSocket` and `raw sockets`

*Note that the object `MDWamp` must be a retained property or ARC will get rid of it ahead of time.*

First you have to choose a transport (ie. WebSocket) and init the `MDWamp` object with it:
	
	MDWampTransportWebSocket *websocket = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080/ws"] protocolVersions:@[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json]];   
	
    _wamp = [[MDWamp alloc] initWithTransport:websocket realm:@"realm1" delegate:self];


when your done and you want to fire the connection:

	[wamp connect];

to disconnect:

	[wamp disconnect];

You can optionally implement two methods in the delegate you've setted when initing MDWamp:

	// Called when client has connected to the server
	- (void) mdwamp:(MDWamp*)wamp sessionEstablished:(NSDictionary*)info;
	
	// Called when client disconnect from the server
	- (void) mdwamp:(MDWamp *)wamp closedSession:(NSInteger)code reason:(NSString*)reason details:(NSDictionary *)details;


You can also provide similar callback instead of using the delegate:

	@property (nonatomic, copy) void (^onSessionEstablished)(MDWamp *client, NSDictionary *info);
	@property (nonatomic, copy) void (^onSessionClosed)(MDWamp *client, NSInteger code, NSString *reason, NSDictionary *details);

The Header files of `MDWamp` class and of the Delegates are all well commented so the API is trivial. Anyway here are some common usage examples

### Call a remote procedure:
	
	[wamp call:@"com.hello.hello" args:nil kwArgs:nil complete:^(MDWampResult *result, NSError *error) {
        if (error== nil) {
	        // do something with result object
	    } else {
	        // handle the error
	    }
    }];
	
### Publish to a topic this json object `{"user" : ["foo", "bar"]}`:

	[_wamp publishTo:@"com.topic.hello" args:nil kw:@{@"user":@[@"foo", @"bar"]} options:@{@"acknowledge":@YES, @"exclude_me":@NO} result:^(NSError *error) {
		
		// if acknowledge is TRUE this callback will be called to notify the successful publishing
        NSLog(@"published? %@", (error==nil)?@"YES":@"NO");
    }];

### Subscribe to a Topic and handle received events:

	[wamp subscribe:@"com.topic.hello" onEvent:^(MDWampEvent *payload) {
        
        // do something with the payload of the event
        NSLog(@"received an event %@", payload.arguments);
        
    } result:^(NSError *error) {
        NSLog(@"subscribe ok? %@", (error==nil)?@"YES":@"NO");
    }];


## Tests

If you want to run the tests you have to install dependancies by using submodules so:

- clone the repository: `git clone git@github.com:mogui/MDWamp.git`
- `cd MDWamp`
- run a `git submodule init && git submodule update` inside the MDWamp cloned directory to init the SocketRocket and msgpack-objectivec dependancy.

Everything should build straight away

You can run Unit Test on `MDWamp` target without any other dependancy, BUT the tests aginst MDWampTransportWebSocket won't be run.

If you want to run the full test suite (with also code coverage) you want to run tests on `MDWamp+crossbar.io+covarege` target.

To do that you need to install an instance of crossbar.io and start it, leave all the things with default settings it will be ok

	pip install crossbar[msgpack]
	crossbar init
	crossbar start

Enjoy :)


## Changes 

### 2.2.0

Implemented Stable Features of Advanced protocol

- Transport
    - RawSocket Transport (old spec - to be updated)
    - LongPoll Transport (Doesn't make sense on mobile)
- Publish & Subscribe
    - Subscriber Black- and Whitelisting
    - Publisher Exclusion 
    - Publisher Identification 
- Remote Procedure Calls
    - Caller Identification
    - Progressive Call Results
    - Canceling Calls
- Authentication
    - TLS Certificate-based Authentication (SocketRocket)
    - WAMP Challenge-Response Authentication
    - One Time Token Authentication


### 2.1.0
- added RawSocketTransport
- added iOS Test application target
- Removed mdwamp version 1 related code
- Refactoring of some part of the codebase to not handle anymore version 1/2 differences


### 2.0.0

- Addopted WAMP v2 [basic protocol](https://github.com/tavendo/WAMP/blob/master/spec/basic.md)
- new library interface, due to protocol changes
- decoupled architecture to give flexibility over new transport and serializations
- dropped iOS 5 compatibility now iOS >= 6.1 is required
- not yet supported backword compatibility with WAMP v1

### 1.1.0

- Added OSX framework target
- dropped iOS 4 compatibility now iOS >= 5.0 is required
- added block callback for connection, rpc and pub/sub messages
- removed RPC and Event delegates (now they only works with blocks)
- added unit test

## Roadmap

- <strike>make an iOS App Target in the project to show all the features</strike>
- <strike>implement raw socket transport </strike>
- implement the [advanced protocol](https://github.com/tavendo/WAMP/blob/master/spec/advanced.md) spec
-  make the library also a Server Library integrating with GCDWebServer



##Authors
- [mogui](https://github.com/mogui/)
- [several contributors](https://github.com/mogui/MDWamp/graphs/contributors)

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
[staticlibpost]: http://blog.mogui.it/iOS-3rd-packaging.html
