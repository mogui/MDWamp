//
//  FirstViewController.m
//  MDWampDemo
//
//  Created by Niko Usai on 27/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "ConnectViewController.h"


@interface ConnectViewController () <UITextFieldDelegate, MDWampClientDelegate>
@property (assign) BOOL connected;
@end

@implementation ConnectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.connected) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connect:(id)sender {
    // CHECK empty fields
    if (!self.connected) {
        MDWampTransportWebSocket *tr = [[MDWampTransportWebSocket alloc] initWithServer:[NSURL URLWithString:self.hostField.text] protocolVersions:@[kMDWampVersion2JSON]];
        MDWamp *ws = [[MDWamp alloc] initWithTransport:tr realm:self.realmField.text delegate:self];
        [AppDel setWampConnection:ws];
        [ws connect];
    } else {
        MDWamp *ws = [AppDel wampConnection];
        [ws disconnect];
    }
}

- (void) mdwamp:(MDWamp*)wamp sessionEstablished:(NSDictionary*)info {

    self.connected = YES;
    [self.connectButton setTitle:@"DISCONNECT" forState:UIControlStateNormal];
    NSLog(@"serverd details: %@", info);
    [self.connectIcon setHighlighted:YES];
    self.serverDetails.text = [NSString stringWithFormat:@"\n"\
                               @"authid:\t %@\n"\
                               @"authmethod:\t %@\n"\
                               @"authrole:\t %@\n"\
                               @"roles:\t %@\n", info[@"authid"], info[@"authmethod"], info[@"authrole"], [[info[@"roles"] allKeys] componentsJoinedByString:@", "]];
}

- (void) mdwamp:(MDWamp *)wamp closedSession:(NSInteger)code reason:(NSString*)reason details:(NSDictionary *)details {
    [self.connectIcon setHighlighted:NO];
    self.connected = NO;
    self.serverDetails.text = reason;
    [self.connectButton setTitle:@"CONNECT" forState:UIControlStateNormal];
}

@end
