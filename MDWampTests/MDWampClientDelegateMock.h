//
//  MDWampClientDelegateMock.h
//  MDWamp
//
//  Created by Niko Usai on 13/12/13.
//  Copyright (c) 2013 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDWampClientDelegate.h"

@interface MDWampClientDelegateMock : NSObject <MDWampClientDelegate>

@property (assign) BOOL onOpenCalled;
@property (assign) BOOL onCloseCalled;
@property (assign) BOOL onAuthReqWithAnswerCalled;
@property (assign) BOOL onAuthSignWithSignatureCalled;
@property (assign) BOOL onAuthWithAnswerCalled;
@property (assign) BOOL onAuthFailForCallCalled;
@property (nonatomic, copy) void (^onOpenCallback)(void);

@end
