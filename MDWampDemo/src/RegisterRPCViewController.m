//
//  RegisterRPCViewController.m
//  MDWamp
//
//  Created by Niko Usai on 03/07/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "RegisterRPCViewController.h"

@interface RegisterRPCViewController ()<UITextFieldDelegate>

@end

@implementation RegisterRPCViewController

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


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    //Keyboard becomes visible
    [textField resignFirstResponder];
    [self register:nil];
    return YES;
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

- (IBAction)register:(id)sender {
    
    
    [self.procedureName resignFirstResponder];
    self.textArea.text = @"";
    
    if(self.procedureAction.enabled) {
        
        [[AppDel wampConnection] registerRPC:self.procedureName.text procedure:^(MDWamp *client, MDWampInvocation *invocation) {
            
            if(self.procedureAction.selectedSegmentIndex == 0) {
                CGRect rect=self.view.bounds;
                UIGraphicsBeginImageContext(rect.size);
                
                CGContextRef context=UIGraphicsGetCurrentContext();
                
                [[AppDel window].layer renderInContext:context];
                
                UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                NSData * data = UIImagePNGRepresentation(image);
                NSString *b64 = [[NSString alloc] initWithData:[data base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength] encoding:NSUTF8StringEncoding];
                [client resultForInvocation:invocation arguments:@[b64] argumentsKw:nil];
            } else {
                [client resultForInvocation:invocation arguments:nil argumentsKw:@{
                            @"systemVersion": [[UIDevice currentDevice] systemVersion],
                            @"systemName": [[UIDevice currentDevice] systemName],
                            @"name": [[UIDevice currentDevice] name]
                            }];
            }
            

        } cancelHandler:nil registerResult:^(NSError *error) {
             
            if(error){
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                [av show];
            } else {
                self.textArea.text = @"Procedure registered!";
                self.procedureName.enabled = NO;
                self.procedureAction.enabled = NO;
                [self.registerButton setTitle:@"UNREGISTER" forState:UIControlStateNormal];
            }
        }];
    } else {
        [[AppDel wampConnection] unregisterRPC:self.procedureName.text result:^(NSError *error) {
            if(error){
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                [av show];
            } else {
                self.textArea.text = @"Successfully unregistered";
            }
        }];
        
        self.procedureName.enabled = YES;
        self.procedureAction.enabled = YES;
        [self.registerButton setTitle:@"Register" forState:UIControlStateNormal];
    }
}
@end
