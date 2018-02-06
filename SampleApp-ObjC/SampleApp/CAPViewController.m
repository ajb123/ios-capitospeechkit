//
//  FTViewController.m
//  FastTrains
//
//  Created by Darren Harris on 18/02/14.
//  Copyright (c) 2014 Capito Systems. All rights reserved.
//

@import CapitoSpeechKit;
@import MBProgressHUD;
@import TWMessageBarManager;

#import "CAPViewController.h"

#define readyButton         @"rec2"
#define busyButton          @"rec1"

@interface CAPViewController ()

@end

@implementation CAPViewController

@synthesize microphone;

UIImage* readyImage;
UIImage* busyImage;

- (void)viewDidLoad {
    [super viewDidLoad];

    // pre-load images from bundle
    readyImage = [UIImage imageNamed:readyButton];
    busyImage = [UIImage imageNamed:busyButton];

    // Initialise and hide text control bar
    [self initialiseTextControlBar];
    
    // Set info text
    NSMutableString *versionStr = [[NSMutableString alloc] initWithString:[self.infoText text]];
    [versionStr appendString:[self appVersionNumberDisplayString]];
    self.infoText.text = versionStr;
    
    [self.view sendSubviewToBack:self.transcriptionLabel];
    [self.view sendSubviewToBack:self.transcriptionView];
}

- (void)initialiseTextControlBar {
    self.textControlBar.hidden = YES;
    self.textControlBar.delegate = self;    
    self.textControlBar.alpha = 0.0;
}

- (void)onTextControlClick:(id)sender {
    // get the height of the search bar
    CGFloat adelta = 1.0;
    // check if toolbar was visible or hidden before the animation
    BOOL isHidden = [self.textControlBar isHidden];
    
    // if search bar was visible set delta to negative value
    if (!isHidden) {
        adelta = 0.0;
    } else {
        // if search bar was hidden then make it visible
        self.textControlBar.hidden = NO;
    }
    
    [UIView animateWithDuration:0.7 delay:0.2 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.textControlBar.alpha = adelta;
        
    } completion:^(BOOL finished) {
        if (!isHidden) {
            self.textControlBar.hidden = YES;
            [self.textControlBar resignFirstResponder];
        }
    }];
}

- (IBAction)onInfoClick:(id)sender {
    self.infoText.hidden ^= YES;
}

- (IBAction)onMicrophoneClick:(id)sender {
    if (isRecording) {
        [[CapitoController getInstance] cancelTalking];
    } else {
        [[CapitoController getInstance] pushToTalk:self withDialogueContext:nil];
        self.transcriptionLabel.text = @"";
    }
}

- (NSString *)appVersionNumberDisplayString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [NSString stringWithFormat:@"%@.%@", majorVersion, minorVersion];
}

#pragma mark Processing HUD

- (void)showProcessingHUDWithText:(NSString *)hudText {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.minShowTime = 1.0f;
    hud.label.text = @"Processing...";
    hud.detailsLabel.text = hudText;
}
- (void)hideProcessingHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (void)showErrorAler:(NSError *)error {
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:error.code == 0 ? @"Speech not recognised" : @"Error"
                                                   description:error.localizedDescription
                                                          type:TWMessageBarMessageTypeError
                                                      duration:6.0f];
}

#pragma SearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.textControlBar resignFirstResponder];
    // Do the search...
    NSString *text = [searchBar text];
    NSLog(@"Sending text event: %@", text);
    [self onTextControlClick:nil];
    [self handleText:text];
}

#pragma mark SpeechDelegate protocol implementation

- (void)speechControllerDidBeginRecording {
    isRecording = TRUE;
    [microphone setImage:busyImage forState:UIControlStateNormal];
}

- (void)speechControllerDidFinishRecording {
    isRecording = FALSE;
    [microphone setImage:readyImage forState:UIControlStateNormal];
}

- (void)speechControllerProcessing:(CapitoTranscription *)capTranscription suggestion:(NSString *)suggestion {
    [self showProcessingHUDWithText:@"Processing..."];
    
    self.transcriptionLabel.text = [NSString stringWithFormat:@"\"%@\"", [capTranscription.firstResult stringByReplacingOccurrencesOfString:@" | " withString:@" "]];
}

- (void)speechControllerDidFinishWithResults:(CapitoResponse *)response {
    NSLog(@"speechControllerDidFinishWithResults");
    [self handleResponse:response];
}

- (void)speechControllerDidFinishWithError:(NSError *)error {
    [self hideProcessingHUD];
    [self showErrorAler:error];
}

#pragma mark TextDelegate protocol implementation

- (void)textControllerDidFinishWithResults:(CapitoResponse *)response {
    NSLog(@"textControllerDidFinishWithResults");
    [self handleResponse:response];
    self.transcriptionLabel.text = [NSString stringWithFormat:@"\"%@\"", self.textControlBar.text];
}

- (void)textControllerDidFinishWithError:(NSError *)error {
    NSLog(@"textControllerDidFinishWithError");
    [self hideProcessingHUD];
    [self showErrorAler:error];
}

#pragma mark TouchDelegate protocol implementation

- (void)touchControllerDidFinishWithResults:(CapitoResponse *)response {
    NSLog(@"touchControllerDidFinishWithResults");
    [self hideProcessingHUD];
    [self handleResponse:response];
}

- (void)touchControllerDidFinishWithError:(NSError *)error {
    NSLog(@"touchControllerDidFinishWithError");
    [self hideProcessingHUD];
    [self showErrorAler:error];
}

- (void)handleText:(NSString *)textEvent {
    [self showProcessingHUDWithText:@"Processing..."];
    
    [[CapitoController getInstance] text:self input:textEvent withDialogueContext:nil];
}

- (void)handleResponse:(CapitoResponse *)response {
    [self hideProcessingHUD];
    [self bootstrapView:response];
}

- (void)bootstrapView:(CapitoResponse *)response {
    // process response
    NSLog(@"Response Code: %@", response.responseCode);
    NSLog(@"Message Text: %@", response.message);
    NSLog(@"Context: %@", response.context);
    NSLog(@"Data: %@", response.data);
    // This is where the app-specific code should be placed to handle the response from the Capito Cloud
}

@end
