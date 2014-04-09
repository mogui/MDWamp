//
//  MDWampClientDelegateMock.m
//  MDWamp
//
//  Created by Niko Usai on 13/12/13.
//  Copyright (c) 2013 mogui.it. All rights reserved.
//

#import "MDWampClientDelegateMock.h"

@implementation MDWampClientDelegateMock

- (void) onOpen
{
    self.onOpenCalled = YES;
    if(self.onOpenCallback){
        self.onOpenCallback();
    }
}

- (void) onClose:(NSInteger)code reason:(NSString *)reason details:(NSDictionary*)details
{
    self.onCloseCalled = YES;
}

- (void) onAuthReqWithAnswer:(NSString *)answer
{
    self.onAuthReqWithAnswerCalled = YES;
}

- (void) onAuthSignWithSignature:(NSString *)signature
{
    self.onAuthSignWithSignatureCalled = YES;
}

- (void) onAuthWithAnswer:(NSString *)answer
{
    self.onAuthWithAnswerCalled = YES;
}

- (void) onAuthFailForCall:(NSString *)procCall withError:(NSString *)errorDetails
{
    self.onAuthFailForCallCalled = YES;
}
@end
