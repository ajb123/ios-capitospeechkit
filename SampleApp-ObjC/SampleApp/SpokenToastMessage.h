//
//  SpokenToastMessage.h
//  FastFooty
//
//  Created by Darren Harris on 11/7/13.
//  Copyright (c) 2013 Capito Systems. All rights reserved.
//

#import "ToastMessage.h"

@interface SpokenToastMessage : ToastMessage <ToastDelegate>

+(void) setController:(CapitoController *)controller;

@end
