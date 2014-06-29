//
//  SecondViewController.m
//  MDWampDemo
//
//  Created by Niko Usai on 27/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *messages;


@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.roomNameField.text = self.room;
    self.messages = [[NSMutableArray alloc] init];
    self.tableView.backgroundColor = UIColor.redColor;
    MDWamp *wamp = [AppDel wampConnection];
    [wamp subscribe:[NSString stringWithFormat:@"com.mogui.%@", [self.room stringByReplacingOccurrencesOfString:@" " withString:@"-"]] onEvent:^(MDWampEvent *payload) {
        if(payload.arguments && [payload.arguments count] > 0){
        
            // message arrives
            [self.messages addObject:payload.arguments[0]];
            [self.tableView reloadData];
        }
    } result:^(NSError *error) {
        if (error) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"!!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSLog(@"Connectd to chat");
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    if (indexPath.row % 2 == 0) {
        identifier = @"LeftCell";
    } else if (indexPath.row == 1) {
        identifier = @"RightCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    UILabel *name = (UILabel*)[cell viewWithTag:1];
    UILabel *text = (UILabel*)[cell viewWithTag:2];
    
    if (indexPath.row == 0 || ![self.messages[indexPath.row][@"nick"] isEqual:self.messages[indexPath.row-1][@"nick"]]) {
        name.text = self.messages[indexPath.row][@"nickname"];
    }
    
    text.text = self.messages[indexPath.row][@"text"];
    return cell;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    //Keyboard becomes visible
    self.inputControls.frame = CGRectMake(self.inputControls.frame.origin.x,
                                  self.inputControls.frame.origin.y - 215,
                                  self.inputControls.frame.size.width,
                                  self.inputControls.frame.size.height);   //resize
//    CGRect tv = self.tableView.frame;
//    tv.size.height = tv.size.height - 215 - 24;
//    self.tableView.frame = tv;
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.inputControls.frame = CGRectMake(self.inputControls.frame.origin.x,
                                          self.inputControls.frame.origin.y + 215,
                                          self.inputControls.frame.size.width,
                                          self.inputControls.frame.size.height); //resize
    CGRect tv = self.tableView.frame;
    tv.size.height = tv.size.height + 215 + 44;
    self.tableView.frame = tv;

    return YES;
}

- (IBAction)part:(id)sender {
    // unregister
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)send:(id)sender {
    if (![self.inputText.text isEqual:@""]) {
        NSDictionary *payload = @{@"nickname":self.nickname, @"text":self.inputText.text};
        
        [[AppDel wampConnection] publishTo:[NSString stringWithFormat:@"com.mogui.%@", [self.room stringByReplacingOccurrencesOfString:@" " withString:@"-"]] args:@[payload] kw:nil options:@{@"exclude_me":@NO} result:nil];
    }
}
@end
