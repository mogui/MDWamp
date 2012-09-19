//
//  ViewController.m
//  MDWampTest
//
//  Created by pronk on 19/09/12.
//  Copyright (c) 2012 mogui. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if ([NSJSONSerialization class]) {
		NSLog(@"yes");
	} else {
		NSLog(@"NOOO");
	}
	
	
	[MDWamp setDebug:YES];
	
	wamp = [[MDWamp alloc] initWithUrl:@"ws://localhost:9000" delegate:self];
	[wamp setAutoreconnectMaxRetries:2];
	[wamp setShouldAutoreconnect:NO];
	[wamp connect];
	
	UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btn1 setTitle:@"RPC" forState:UIControlStateNormal];
	btn1.frame = CGRectMake(20, 20,200,30);
	[btn1 addTarget:self action:@selector(callRpc) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn1];
	
	UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btn2 setTitle:@"RPC 2" forState:UIControlStateNormal];
	btn2.frame = CGRectMake(20, 60, 200,30);
	[btn2 addTarget:self action:@selector(callRpc2) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn2];
	
	UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btn3 setTitle:@"Publish" forState:UIControlStateNormal];
	btn3.frame = CGRectMake(20, 100, 200,30);
	[btn3 addTarget:self action:@selector(publish) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn3];
	
	btn4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btn4 setTitle:@"Conenct" forState:UIControlStateNormal];
		[btn4 setTitle:@"Close" forState:UIControlStateSelected];
	btn4.frame = CGRectMake(20, 140, 200,30);
	[btn4 addTarget:self action:@selector(toggleConnect:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn4];
	
	/*
	UIButton *btn5 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btn5 setTitle:@"Reconnect" forState:UIControlStateNormal];
	btn5.frame = CGRectMake(20, 180, 200,30);
	[btn5 addTarget:self action:@selector(reconnect:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn5];
	*/
	
}



- (void)toggleConnect:(UIButton*)btn
{
	if (btn.selected) {
		[wamp disconnect];
	} else {
		[wamp reconnect];
	}
	
	
}
- (void)callRpc
{
	[wamp prefix:@"calc" uri:@"http://example.com/calc#"];
	[wamp call:@"calc:pots" withDelegate:self args:[NSNumber numberWithInt:8], nil];
}

- (void)callRpc2
{
	[wamp call:@"http://example.com/obj" withDelegate:self args:@"Stocazzo", nil];
}

#pragma mark - rpc delegate
- (void) onResult:(id)result forCalledUri:(NSString *)callUri
{
	NSLog(@"---------- YAY RESULT %@", result);
}
- (void) onError:(NSString *)errorUri description:(NSString*)errorDesc forCalledUri:(NSString *)callUri
{
	NSLog(@"---------- YAY CALL ERROR %@", errorDesc);
}


#pragma mark - pub/sub delegate
- (void) onEvent:(NSString *)topicUri eventObject:(id)object
{
	NSLog(@"---------- WEEEEEEE event received %@", object);
}

- (void) publish
{
	[wamp publish:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"niko", @"usai", nil],@"user", nil] toTopic:@"http://example.com/simple" excludeMe:NO];
}

- (void) onOpen
{
	[wamp subscribeTopic:@"http://example.com/simple" withDelegate:self];
	[btn4 setSelected:YES];
}
- (void) onClose:(int)code reason:(NSString *)reason
{
	[btn4 setSelected:NO];
	NSLog(@"wamp closed");
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
