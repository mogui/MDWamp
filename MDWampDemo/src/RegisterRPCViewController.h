//
//  RegisterRPCViewController.h
//  MDWamp
//
//  Created by Niko Usai on 03/07/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterRPCViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *procedureName;

@property (weak, nonatomic) IBOutlet UISegmentedControl *procedureAction;
@property (weak, nonatomic) IBOutlet UITextView *textArea;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
- (IBAction)register:(id)sender;
@end
