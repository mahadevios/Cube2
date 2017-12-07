//
//  SpeechRecognitionViewController.h
//  Cube
//
//  Created by mac on 24/11/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Speech/Speech.h>
#import "CommonDelegate.h"

@interface SpeechRecognitionViewController : UIViewController<SFSpeechRecognitionTaskDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,CommonDelegate>
{
    NSTimer* newRequestTimer;
}
@property(nonatomic, strong)AVAudioEngine* audioEngine;
@property(nonatomic, strong)SFSpeechRecognizer* speechRecognizer;
@property(nonatomic, strong)SFSpeechAudioBufferRecognitionRequest* request;
@property(nonatomic, strong)SFSpeechURLRecognitionRequest* urlRequest;

@property(nonatomic, strong)SFSpeechRecognitionTask* recognitionTask;
@property(nonatomic, strong)AVCaptureSession* capture;
@property(nonatomic, strong)NSMutableArray* previousTranscriptedArray;
@property(nonatomic, strong)UIView* transcriptionStatusView;
@property(nonatomic, strong)UILabel* timerLabel;
@property(nonatomic, strong)UILabel* transcriptionStatusLabel;
@property(nonatomic)BOOL isStartedNewRequest;
@property(nonatomic)int timerSeconds;
@property(nonatomic, strong)AVAudioFile* audioFileName;

- (IBAction)startLiveAudioTranscription:(id)sender;
- (IBAction)stopLiveAudioTranscription:(id)sender;
- (IBAction)segmentChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *startTranscriptionButton;
@property (weak, nonatomic) IBOutlet UIButton *stopTranscriptionButton;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *transcriptionTextLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollVIew;

@end
