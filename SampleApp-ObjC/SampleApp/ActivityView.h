//
//  ActivityView.m
//  TestFramework
//
//  Created by Darren Harris on 5/16/13.
//  Copyright (c) 2013 Capito Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ActivityView : UIView {	
	NSString* message;	
	UILabel *messageLabel;
	UIActivityIndicatorView *activityIndicatorView;	
	BOOL transitioning;
}

@property (nonatomic, retain) NSString* message;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

- (void)addSubViews;
- (void)show;
- (void)hide;
- (void)fadeIn;
- (void)fadeOut;

@end
