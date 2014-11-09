//
//  CallRPCViewController.m
//  MDWamp
//
//  Created by Niko Usai on 04/07/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "CallRPCViewController.h"

@interface CallRPCViewController () <UITextFieldDelegate> {
    UIImageView *tmpIv;
}

@end

@implementation CallRPCViewController

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


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    //Keyboard becomes visible
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)callProcedure:(id)sender {
    if (tmpIv) {
        [tmpIv removeFromSuperview];
    }

    [[AppDel wampConnection] call:self.procedureName.text args:nil kwArgs:nil options:nil complete:^(MDWampResult *result, NSError *error) {
        self.resultText.text = @"";
        if (error) {
            self.resultText.text = error.localizedDescription;
            return;
        }
        
        if (result.argumentsKw) { // is the device info
            NSString *res = [NSString stringWithFormat:@"name: %@\nos: %@ %@", result.argumentsKw[@"name"], result.argumentsKw[@"systemName"], result.argumentsKw[@"systemVersion"]];
            self.resultText.text = res;
        } else { // else is the screenshot
            // NOTICE: in a real world application you will make
            // a sort of application protocol with this messages to differ the response or you just know what procedures returns :P
            NSString *arr = result.result;
            NSData *decoded = [[NSData alloc] initWithBase64EncodedString:arr options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *img = [UIImage imageWithData:decoded];
            tmpIv = [[UIImageView alloc] initWithFrame:self.resultText.frame];
            tmpIv.contentMode = UIViewContentModeScaleAspectFit;
            tmpIv.image = img;
            [UIView transitionWithView:self.view duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^ {
                                [self.view addSubview:tmpIv];
                            } completion:nil];
            
        }
    }];
    
}
@end
