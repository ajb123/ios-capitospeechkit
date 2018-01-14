//
//  ToastMessages.h
//  FastFooty
//
//  Created by Darren Harris on 10/5/13.
//  Copyright (c) 2013 Capito Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CapitoSpeechKit/CapitoController.h>
#import "iToast.h"

@interface ToastMessage : NSObject

+ (iToast *) showErrorMessage:(NSError *)error;

+ (iToast *) showWarningMessage:(NSString *)message withResponseObject:(CapitoResponse *)response forNextView:(NSString *)title;

@end
