//
//  FirstViewController.h
//  MDWampDemo
//
//  Created by Niko Usai on 27/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *hostField;
@property (weak, nonatomic) IBOutlet UITextField *realmField;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UITextView *serverDetails;
@property (weak, nonatomic) IBOutlet UIButton *connectIcon;


- (IBAction)connect:(id)sender;
@end
