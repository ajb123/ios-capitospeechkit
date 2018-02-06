//
//  FTViewController.h
//  FastTrains
//
//  Created by Darren Harris on 18/02/14.
//  Copyright (c) 2014 Capito Systems. All rights reserved.
//

@import UIKit;
@import CapitoSpeechKit;

@interface CAPViewController : UIViewController <SpeechDelegate, TouchDelegate, TextDelegate, UISearchBarDelegate> {
    BOOL isRecording;
    CapitoController *controller;
}

@property (strong, nonatomic) IBOutlet UIButton *microphone;
@property (strong, nonatomic) IBOutlet UITextView *transcriptionView;
@property (weak, nonatomic) IBOutlet UIButton *info;
@property (weak, nonatomic) IBOutlet UISearchBar *textControlBar;
@property (weak, nonatomic) IBOutlet UIButton *textControl;
@property (weak, nonatomic) IBOutlet UITextView *infoText;
@property (weak, nonatomic) IBOutlet UILabel *transcriptionLabel;

- (IBAction)onMicrophoneClick:(id)sender;
- (IBAction)onTextControlClick:(id)sender;
- (IBAction)onInfoClick:(id)sender;

@end
