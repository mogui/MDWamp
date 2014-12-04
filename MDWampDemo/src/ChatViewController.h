//
//  SecondViewController.h
//  MDWampDemo
//
//  Created by Niko Usai on 27/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *roomNameField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *inputText;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *room;
@property (weak, nonatomic) IBOutlet UIView *inputControls;
- (IBAction)part:(id)sender;
- (IBAction)send:(id)sender;

@end
