//
//  SpokenToastMessage.m
//  FastFooty
//
//  Created by Darren Harris on 11/7/13.
//  Copyright (c) 2013 Capito Systems. All rights reserved.
//

#import "SpokenToastMessage.h"
#import "iToast.h"

@implementation SpokenToastMessage

CapitoController *controller;

+ (iToast *) showWarningMessage:(NSString *)message withResponseObject:(CapitoResponse *)response forNextView:(NSString *)title {
    iToast *toast = [super showWarningMessage:message withResponseObject:response forNextView:title];

    NSString *text;
    if (response!=nil) {
        text  = [[NSString alloc] initWithFormat:@"%@. Click on the message to go to the %@ screen.", message, title];
    } else {
        text  = message;
    }
    
    if (controller!=nil && text !=nil) {
        [toast setDelegate:[self self]];
        [controller textToSpeech:text];        
    }
    
    return toast;
}

+ (void) setController:(CapitoController *)_controller{
    controller = _controller;
}

+ (void) toastWillDisappear{
    NSLog(@"toastWillDisappear");
    if (controller != nil) {
        [controller cancelTextToSpeech];
    }
}

@end
