//
//  ViewController.m
//  testcrossbar
//
//  Created by Niko Usai on 18/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "ViewController.h"
#import "MDWamp.h"

@interface ViewController () <MDWampClientDelegate>
@property (nonatomic, strong) MDWamp *wamp;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    MDWampTransportWebSocket *websocket = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:@"ws://localhost:8080/ws"] protocolVersions:@[kMDWampVersion2]];
    _wamp = [[MDWamp alloc] initWithTransport:websocket realm:@"realm1" delegate:self];
    [_wamp connect];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) mdwamp:(MDWamp*)wamp sessionEstablished:(NSDictionary*)info {
    NSLog(@"connected %@", info);
    [wamp call:@"com.hello.hello" args:nil kwArgs:nil complete:^(MDWampResult *result, NSError *error) {
        NSLog(@"---> %@, errror: %@", result.result, error);
    }];
//    [wamp subscribe:@"com.hello.hello2" onEvent:^(MDWampEvent *payload) {
//        NSLog(@"received an event %@", payload.arguments);
//        
//    } result:^(NSError *error) {
//        NSLog(@"subscribe ok? %@", error);
//    }];
}

- (void) mdwamp:(MDWamp *)wamp closedSession:(NSInteger)code reason:(NSString*)reason details:(NSDictionary *)details {
    NSLog(@"closed session");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publishShit:(id)sender {
    [_wamp publishTo:@"com.hello.hello2" args:@[self.pubText.text] kw:nil options:@{@"acknowledge":@YES, @"exclude_me":@NO} result:^(NSError *error) {
        NSLog(@"published? %@", error);
    }];
}
@end
