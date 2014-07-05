//
//  CallRPCViewController.h
//  MDWamp
//
//  Created by Niko Usai on 04/07/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallRPCViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *procedureName;
@property (weak, nonatomic) IBOutlet UITextView *resultText;
- (IBAction)callProcedure:(id)sender;
@end
