//
//  FTViewController.m
//  FastTrains
//
//  Created by Darren Harris on 18/02/14.
//  Copyright (c) 2014 Capito Systems. All rights reserved.
//

#import "CAPViewController.h"
#import "SpokenToastMessage.h"
#import "UIButton+Extensions.h"
#import "CAPAppDelegate.h"
#import <CapitoSpeechKit/CAPSettings.h>

#define readyButton         @"rec2"
#define busyButton          @"rec1"

@interface CAPViewController ()

@end

@implementation CAPViewController

@synthesize microphone;

UIImage* readyImage;
UIImage* busyImage;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // pre-load images from bundle
    readyImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:readyButton ofType:@"png"]];
    busyImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:busyButton ofType:@"png"]];

    ActivityView *av = [[ActivityView alloc] initWithFrame:self.view.frame];
    self.activityView = av;
    [self.view addSubview:self.activityView];
    
    self.transcriptionLabel.font = [UIFont fontWithName:@"SegoeWP-Semibold" size:30.0f];
    [self.view sendSubviewToBack:self.transcriptionLabel];
    [self.view sendSubviewToBack:self.transcriptionView];

    [SpokenToastMessage setController:[CapitoController getInstance]];
    
    // Initialise and hide text control bar
    [self initialiseTextControlBar];
    
    // Set info text
    NSString *versionInfo = [self appVersionNumberDisplayString];
    
    NSMutableString *versionStr = [[NSMutableString alloc] initWithString:[self.infoText text]];
    [versionStr appendString:versionInfo];
    self.infoText.text = versionStr;
    self.infoText.font = [UIFont fontWithName:@"SegoeWP-Light" size:20.0f];
    self.infoText.textColor = [CAPAppDelegate textColor];
    
    [self.view sendSubviewToBack:self.transcriptionLabel];
    [self.view sendSubviewToBack:self.transcriptionView];
}

- (void) initialiseTextControlBar{
    self.textControlBar.hidden = YES;
    self.textControlBar.delegate = self;
    for (UIView *textBarSubview in [self.textControlBar subviews]) {
        
        if ([textBarSubview isKindOfClass:[UITextField class]]) {
            
            @try {
                
                [(UITextField *)textBarSubview setReturnKeyType:UIReturnKeyGo];
                [(UITextField *)textBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
            }
            @catch (NSException * e) {
                
                // ignore exception
            }
        }
    }
    self.textControlBar.alpha = 0.0;
}

-(void)onTextControlClick:(id)sender {
    // get the height of the search bar
    float ydelta = self.textControlBar.frame.size.height;
    CGFloat adelta = 1.0;
    // check if toolbar was visible or hidden before the animation
    BOOL isHidden = [self.textControlBar isHidden];
    
    // if search bar was visible set delta to negative value
    if (!isHidden) {
        adelta = 0.0;
        ydelta *= -1;
    } else {
        // if search bar was hidden then make it visible
        self.textControlBar.hidden = NO;
    }
    
    [UIView animateWithDuration:0.7
                          delay:0.2
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{self.textControlBar.alpha = adelta;}
                     completion:^(BOOL finished){
                         //if the bar was visible then hide it
                         if (!isHidden) {
                             self.textControlBar.hidden = YES;
                             [self.textControlBar resignFirstResponder];
                         }
                     }];
    

}

- (IBAction)onInfoClick:(id)sender {
    self.infoText.hidden^= YES;
}

- (IBAction)onMicrophoneClick:(id)sender {
    if (isRecording) {
        
        [[CapitoController getInstance] cancelTalking];
        
    } else {
        
        [[CapitoController getInstance] pushToTalk:self withDialogueContext:[self getContext]];
        self.transcriptionLabel.text = @"";
    }
}

- (NSString *)appVersionNumberDisplayString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [NSString stringWithFormat:@"%@.%@", majorVersion, minorVersion];
}


#pragma SearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.textControlBar resignFirstResponder];
    // Do the search...
    NSString *text = [searchBar text];
    NSLog(@"Sending text event: %@", text);
    [self onTextControlClick:nil];
    [self handleText:text];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)getContext {
    return nil;
}

#pragma mark SpeechDelegate protocol implementation
- (void) speechControllerDidBeginRecording {
    NSLog(@"speechControllerDidBeginRecording");
    isRecording = TRUE;
    [microphone setImage:busyImage forState:UIControlStateNormal];
    [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.1];
}

- (void) speechControllerDidFinishRecording {
    NSLog(@"speechControllerDidFinishRecording");
    isRecording = FALSE;
    [microphone setImage:readyImage forState:UIControlStateNormal];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVUMeter) object:nil];
}

- (void) speechControllerProcessing:(CapitoTranscription *)capTranscription suggestion:(NSString *)suggestion {
    NSLog(@"speechControllerProcessing");
    
    if ([capTranscription.transcriptions count] > 0) {
        //self.suggestionsButton.hidden = false;
    }
    
    [self.activityView setMessage:@"Processing..."];
    [self.activityView show];
    self.transcriptionLabel.text = [NSString stringWithFormat:@"\"%@\"", capTranscription.firstResult];
}

- (void) speechControllerDidFinishWithResults:(CapitoResponse *)response {
    NSLog(@"speechControllerDidFinishWithResults");
    [self handleResponse:response];
}

- (void) speechControllerDidFinishWithError:(NSError *)error {
    NSLog(@"speechControllerDidFinishWithError");
    [self.activityView hide];
    [ToastMessage showErrorMessage:error];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVUMeter) object:nil];
}

#pragma mark TextDelegate protocol implementation
- (void) textControllerDidFinishWithResults:(CapitoResponse *)response {
    NSLog(@"textControllerDidFinishWithResults");
    [self handleResponse:response];
    self.transcriptionLabel.text = [NSString stringWithFormat:@"\"%@\"", self.textControlBar.text];
}

- (void) textControllerDidFinishWithError:(NSError *)error {
    NSLog(@"textControllerDidFinishWithError");
    [self.activityView hide];
    [ToastMessage showErrorMessage:error];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVUMeter) object:nil];
}

#pragma mark TouchDelegate protocol implementation
- (void) touchControllerDidFinishWithResults:(CapitoResponse *)response {
    NSLog(@"touchControllerDidFinishWithResults");
    [self.activityView hide];
    [self handleResponse:response];
}

- (void) touchControllerDidFinishWithError:(NSError *)error {
    NSLog(@"touchControllerDidFinishWithError");
    [self.activityView hide];
    [ToastMessage showErrorMessage:error];
}

- (void)handleText:(NSString *)textEvent {
    [self.activityView setMessage:@"Processing..."];
    [self.activityView show];
    [[CapitoController getInstance]       text:self
                     input:textEvent
       withDialogueContext:[self getContext]];
}

- (void) handleResponse:(CapitoResponse *)response {
    [self.activityView hide];
    if ([response.messageType isEqualToString:@"WARNING"]) {
        NSLog(@"Got warning message back with response code %@", response.responseCode);
        BOOL includeResponseObject = (response.data != nil && [response.data count]>0) && !([[CapitoController getInstance] isLastEventTouch]);
        if (includeResponseObject) 	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleToastResponse:) name:@"toast" object:nil];
        [SpokenToastMessage showWarningMessage:response.message withResponseObject:nil forNextView:nil];
    } else {
        [self bootstrapView:response];
    }
}

- (void) handleToastResponse: (NSNotification*) notification {
    NSDictionary* userInfo = notification.userInfo;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (userInfo!=nil) {
        CapitoResponse *response = [userInfo objectForKey:@"response"];
        [self bootstrapView:response];
    }
}

- (void) bootstrapView:(CapitoResponse *)response{
    // process response
    NSLog(@"Response Code: %@", response.responseCode);
    NSLog(@"Message Text: %@", response.message);
    NSLog(@"Context: %@", response.context);
    NSLog(@"Data: %@", response.data);
    // This is where the app-specific code should be placed to handle the response from the Capito Cloud
}

- (void)updateVUMeter{
    float audioLevel = [CapitoController getInstance].audioLevel;
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"addSoundMeterItem" object:[NSString stringWithFormat:@"%f", audioLevel]];
    [self performSelector:@selector(updateVUMeter) withObject:nil afterDelay:0.05];
}


#pragma lock portrait
   
-(BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
