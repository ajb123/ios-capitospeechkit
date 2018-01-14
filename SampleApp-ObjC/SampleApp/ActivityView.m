//
//  ActivityView.m
//  TestFramework
//
//  Created by Darren Harris on 5/16/13.
//  Copyright (c) 2013 Capito Systems. All rights reserved.
//

#import "ActivityView.h"


@implementation ActivityView

@synthesize message;
@synthesize messageLabel, activityIndicatorView;


- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
        [self addSubViews];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.hidden = YES;
        transitioning = NO;
    }
    
	return self;
}

/**
 * Draw the view.
 */
- (void)drawRect:(CGRect)rect {
	
	[[UIColor colorWithWhite:0.1 alpha:0.8] set];
	UIRectFill(rect);
}

- (void)addSubViews {	
    const CGFloat DEFAULTLABELWIDTH = 280.0;
    const CGFloat DEFAULTLABELHEIGHT = 60.0;
	CGRect labelFrame = CGRectMake(0, 0, DEFAULTLABELWIDTH, DEFAULTLABELHEIGHT);
	
	if (!self.messageLabel) {
		UILabel *ml = [[UILabel alloc] initWithFrame:labelFrame];
		ml.textColor = [UIColor whiteColor];
		ml.backgroundColor = [UIColor clearColor];
		ml.textAlignment = NSTextAlignmentCenter;
		ml.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
		ml.numberOfLines = 0;
		ml.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		self.messageLabel = ml;
		[self addSubview:messageLabel];
	}
	
	if (!self.activityIndicatorView) {
		UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		aiView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		self.activityIndicatorView = aiView;
		[self addSubview:activityIndicatorView];
	}	
}


- (void) show {
    const CGFloat DEFAULTLABELWIDTH = 280.0;
    const CGFloat DEFAULTLABELHEIGHT = 60.0;
    CGRect labelFrame = CGRectMake(0, 0, DEFAULTLABELWIDTH, DEFAULTLABELHEIGHT);
	
	if (message) {
		self.messageLabel.text = message;
	} else {
		self.messageLabel.text = @"Loading...";
	}

	[activityIndicatorView startAnimating];
	CGFloat totalHeight = messageLabel.frame.size.height + activityIndicatorView.frame.size.height;
	
	labelFrame.origin.x = floor(0.5 * (self.frame.size.width - DEFAULTLABELWIDTH));
	labelFrame.origin.y = floor(0.4 * (self.frame.size.height - totalHeight));
	if (labelFrame.origin.y < 0 || labelFrame.origin.y > 350) {
		labelFrame.origin.y = 200;
	}
	
	// update the frames
	messageLabel.frame = labelFrame;
	CGRect activityIndicatorRect = activityIndicatorView.frame;
	activityIndicatorRect.origin.x = 0.5 * (self.frame.size.width - activityIndicatorRect.size.width);
	activityIndicatorRect.origin.y = messageLabel.frame.origin.y + messageLabel.frame.size.height;
	activityIndicatorView.frame = activityIndicatorRect;
	
	// Set up the fade-in animation
	if (!transitioning) {
		[self.superview bringSubviewToFront:self];
		[self fadeIn];
	}
}


/**
 * Animates the view out from the superview. As the view is removed from the superview, it will be released.
 */
- (void) hide {
	
	// Set up the fade-out animation
	[self fadeOut];
}



- (void)fadeIn {
	
	// First create a CATransition object to describe the transition
	CATransition *transition = [CATransition animation];
	
	// Animate over 3/4 of a second
	transition.duration = 0.25;

	// using the ease in/out timing function
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	// set transition type
	transition.subtype = kCATransitionReveal;
	
	// Finally, to avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
	// -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
	transitioning = YES;
	transition.delegate = self;
	
	// Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
	[self.superview.layer addAnimation:transition forKey:nil];
	
	self.hidden = NO;
}


- (void)fadeOut {
	
	// First create a CATransition object to describe the transition
	CATransition *transition = [CATransition animation];
	
	// Animate over 3/4 of a second
	transition.duration = 0.25;
	
	// using the ease in/out timing function
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	// set transition type
	transition.subtype = kCATransitionFade;
	
	// Finally, to avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
	// -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
	transitioning = YES;
	transition.delegate = self;
	
	// Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
	[self.superview.layer addAnimation:transition forKey:nil];
	
	self.hidden = YES;
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished {
	
	if (finished) {
		transitioning = NO;
	}
}

@end

