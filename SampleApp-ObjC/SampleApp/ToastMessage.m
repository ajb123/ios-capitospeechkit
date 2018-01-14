//
//  ToastMessages.m
//  FastFooty
//
//  Created by Darren Harris on 10/5/13.
//  Copyright (c) 2013 Capito Systems. All rights reserved.
//

#import "ToastMessage.h"
#import "iToast.h"

@implementation ToastMessage

+ (iToast *) showErrorMessage:(NSError *)error {
    NSString *message = [error localizedDescription];
    iToast *toast = [[[[iToast makeText:[NSString stringWithFormat:@"%@", message]]
       setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] setBgRed:255.0f];
    [toast show];
    return toast;
}

+ (iToast *) showWarningMessage:(NSString *)message withResponseObject:(CapitoResponse *)response forNextView:(NSString *)title {
    iToast *toast;
    if (response!=nil) {
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setValue:response forKey:@"response"];
        [info setValue:title forKey:@"title"];
        toast = [[[[iToast makeText:[NSString stringWithFormat:@"%@", message]]
            setGravity:iToastGravityCenter] setDuration:iToastDurationLong] setNotification:info];
    } else {
        toast = [[[iToast makeText:message]
            setGravity:iToastGravityCenter] setDuration:iToastDurationMedium];
    }

    [toast show];
    return toast;
}

@end
