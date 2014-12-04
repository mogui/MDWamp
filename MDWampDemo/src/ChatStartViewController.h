//
//  ChatStartViewController.h
//  MDWamp
//
//  Created by Niko Usai on 27/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatStartViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *roomField;
@property (weak, nonatomic) IBOutlet UITextField *nickField;

- (IBAction)join:(id)sender;
@end
