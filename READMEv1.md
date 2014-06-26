# What is it MDWamp ?

MDWamp is a client side objective-C implementation of the WebSocket subprotocol [WAMP][wamp_link].
It uses [SocketRocket][socket_rocket] as WebSocket Protocol implementation.

With this library and with a server [implementation of WAMP protocol][wamp_impl] you can bring Real-time notification not only for a web app (as WebSocket was created for) but also on your mobile App, just like an inner-app Apple Push Notifcation Service, avoiding the hassle of long polling request to the server for getting new things.

WAMP in its creator words is:

> an open WebSocket subprotocol that provides two asynchronous messaging patterns: RPC and PubSub.

but what are RPC and PubSub? here's a [nice and neat explanation][faq] if you have doubts.


## Changes

### 1.1.0

- Added OSX framework target
- dropped iOS 4 compatibility now iOS >= 5.0 is required
- added block callback for connection, rpc and pub/sub messages
- removed RPC and Event delegates (now they only works with blocks)
- added unit test

## Installation

### OSX
- By using [CocoaPods][cocoapods], just add to your Podfile

    pod 'MDWamp'

- Use MDWamp.framework
Build the framework target of the project, just be sure to `git submodule init && git submodule update` to get the SocketRocket dependancy (see test part for more info)


# iOS
I'm [sick and tired of iOS shitting support for distributing libraries][staticlibpost] so just cocoapods support for ya:
Just add this to your Podfile

    pod "MDWamp"



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

### Publish to a topic] this json object `{"user" : ["foo", "bar"]}`:

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
If you want to run the tests you have to add the SocketRockt dependancy this is handled by using submodules so:

- clone the repository: `git clone git@github.com:mogui/MDWamp.git`
- `cd MDWamp`
- run a `git submodule init && git submodule update` inside the MDWamp cloned directory to init the SocketRocket dependancy.

Once everything compiles smoothly, you need a WAMP server to test against.
The creator of the specification also have a nice test suite tool [autobahn test suite](http://autobahn.ws/testsuite/installation/) (it's for WebSocket in general not only WAMP)
The WAMP part though is undere heavy development nowdays for the new specification (WAMP v2) and not everuyhting works as it should, so temporarily, and just for the sake of the test, I suggest you to install it from my fork [over here](https://github.com/mogui/AutobahnTestSuite)
As for everything python I suggest to make a `virtualenv`

    git clone git://github.com/mogui/AutobahnTestSuite.git
    cd AutobahnTestSuite
    git checkout mdwamp
    cd autobahntestsuite
    python setup.py install

Finally you can start the test server:

    wstest -d -m wampserver -w ws://localhost:9000

and run the test target from Xcode.

##Authors
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
[staticlibpost]: http://blog.mogui.it/iOS-3rd-packaging.html