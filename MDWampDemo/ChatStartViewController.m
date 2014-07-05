//
//  ChatStartViewController.m
//  MDWamp
//
//  Created by Niko Usai on 27/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "ChatStartViewController.h"
#import "ChatViewController.h"
@interface ChatStartViewController ()

@end

@implementation ChatStartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void) viewDidAppear:(BOOL)animated
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![[AppDel wampConnection] isConnected]) {
            
            self.tabBarController.selectedViewController = self.tabBarController.viewControllers[0];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"!!" message:@"You must first connect!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
        }

    });
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChatViewController *vc = segue.destinationViewController;
    vc.room = self.roomField.text;
    vc.nickname = self.nickField.text;
}

- (IBAction)join:(id)sender {
}
@end
