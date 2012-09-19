//
//  ViewController.h
//  MDWampTest
//
//  Created by pronk on 19/09/12.
//  Copyright (c) 2012 mogui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MDWamp/MDWamp.h>
@interface ViewController : UIViewController<MDWampRpcDelegate, MDWampEventDelegate, MDWampDelegate> {
	id wamp;
	UIButton *btn4;
}
@end