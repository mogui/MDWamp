//
//  AppDelegate.h
//  MDWampDemo
//
//  Created by Niko Usai on 27/06/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDWamp.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MDWamp *wampConnection;
@end
