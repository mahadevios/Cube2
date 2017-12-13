//
//  SpeechRecognitionViewController.m
//  Cube
//
//  Created by mac on 24/11/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import "SpeechRecognitionViewController.h"
#import "SelectFileViewController.h"
#import "UIColor+ApplicationColors.h"

@interface SpeechRecognitionViewController ()

@end

@implementation SpeechRecognitionViewController
@synthesize audioEngine,request,recognitionTask,speechRecognizer,isStartedNewRequest, transcriptionStatusView,timerSeconds,startTranscriptionButton,stopTranscriptionButton,timerLabel,transcriptionStatusLabel,transcriptionTextLabel,audioFileName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.stopTranscriptionButton.hidden = true;// for prerecorded segment hide stop button
    
    
    self.transcriptionTextLabel.lineBreakMode = NSLineBreakByWordWrapping;

    self.previousTranscriptedArray = [NSMutableArray new]; // store one minute text to append next request
    
    [self.previousTranscriptedArray addObject:@""];
    
    NSError* error;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];

    audioEngine = [[AVAudioEngine alloc] init];
 
    speechRecognizer = [[SFSpeechRecognizer alloc] init];
    
    request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    speechRecognizer = [[SFSpeechRecognizer alloc] init];

    NSDictionary *audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                            [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                                                                            [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                                                                            [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                                                                            [NSNumber numberWithInt:128000], AVEncoderBitRateKey,
                                                                                             nil];
    NSURL* url = [self urlForFile:@"top1.wav"];
    audioFileName = [[AVAudioFile alloc] initForWriting:url settings:audioCompressionSettings error:nil];

    // Do any additional setup after loading the view.
    //[self transcribePreRecordedAudio];
    //[self authorizeAndTranscribe];
//    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
//        switch (status)
//        {
//            case SFSpeechRecognizerAuthorizationStatusAuthorized:
//                //[self transcribeLiveAudio];
//                [self transcribePreRecordedAudio];
//                break;
//            case SFSpeechRecognizerAuthorizationStatusDenied:
//
//                break;
//            case SFSpeechRecognizerAuthorizationStatusRestricted:
//
//                break;
//            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
//
//                break;
//            default:
//                break;
//        }
//    }];
 
    self.navigationItem.title = @"Speech Transcription";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    
    [self.tabBarController.tabBar setHidden:YES];

    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ResumeTrans"] style:UIBarButtonItemStylePlain target:self action:@selector(resetTranscription)];
    
    
}

-(void)demoTimer
{
    demoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkState) userInfo:nil repeats:YES];
    
}
-(void)checkState
{
    NSLog(@"state is = %ld", (long)recognitionTask.state);
}
-(void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)resetTranscription
{
    [self startTranscriptionStatusViewAnimationToDown:false]; // animate trans status to upperside
    
    [startTranscriptionButton setTitle:@"Start Transcription" forState:UIControlStateNormal]; // chnage title

    startTranscriptionButton.alpha = 1.0;
    
    [startTranscriptionButton setEnabled:true];
    
    isStartedNewRequest = false;
    
    transcriptionTextLabel.text = @"";
    
    timerSeconds = 60;
    
    if (self.capture != nil && [self.capture isRunning])
    {
        [self.capture stopRunning];
    }
    
    [audioEngine stop];
    
    [request endAudio];
    
    //[recognitionTask cancel];
    
    [newRequestTimer invalidate];
    
    transcriptionStatusLabel.text = @"Go ahead, I'm listening!";
    
    [self.previousTranscriptedArray removeAllObjects]; // remove  prev. trans. text
    
    [self.previousTranscriptedArray addObject:@""];
    
}

-(void)hideRightBarButton:(BOOL)hide
{
    if (hide == true)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ResumeTrans"] style:UIBarButtonItemStylePlain target:self action:@selector(resetTranscription)];

    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self addTranscriptionStatusAnimationView];
    
    self.timerSeconds = 60;
}

-(void)addTranscriptionStatusAnimationView
{
    UIView* keyWindow = [UIApplication sharedApplication].keyWindow;
    
    transcriptionStatusView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.05, -70, self.view.frame.size.width*0.8, 48)];
    
    transcriptionStatusView.tag = 3000;
    
    transcriptionStatusView.backgroundColor = [UIColor appOrangeColor];
    
    transcriptionStatusView.layer.cornerRadius = 4.0;
    
    transcriptionStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(transcriptionStatusView.frame.size.width*0.1, 5, transcriptionStatusView.frame.size.width*0.9, 20)];
    
    transcriptionStatusLabel.font = [UIFont systemFontOfSize:15];
    
    transcriptionStatusLabel.text = @"Go ahead, I'm listening!";
    
    transcriptionStatusLabel.textAlignment = NSTextAlignmentCenter;
    
    timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(transcriptionStatusView.frame.size.width/2-30, 30, 60, 15)];
    
    timerLabel.text = @"00:60";
    
    timerLabel.font = [UIFont systemFontOfSize:15];

    timerLabel.textAlignment = NSTextAlignmentCenter;
    
    [transcriptionStatusView addSubview:transcriptionStatusLabel];
    
    [transcriptionStatusView addSubview:timerLabel];
    
    [keyWindow addSubview:transcriptionStatusView];
    
}

-(void)startTranscriptionStatusViewAnimationToDown:(BOOL)moveDown
{
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0.1 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        
        //            self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.1, self.view.frame.size.height*0.09, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);
        int moveDownDistance;
        if (moveDown == true)
        {
            moveDownDistance = 15;
        }
        else
        {
            moveDownDistance = -60;

        }
        self.transcriptionStatusView.frame = CGRectMake(self.view.frame.size.width*0.05, moveDownDistance, self.view.frame.size.width*0.9, 48);
        
    } completion:^(BOOL finished) {
        
        timerLabel.text = @"00:60";
    }];
}
- (IBAction)startLiveAudioTranscription:(UIButton*)sender
{
    
    if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Start Transcription"] || [[sender titleForState:UIControlStateNormal]  isEqual: @"Resume"])
    {
        if ([[AppPreferences sharedAppPreferences] isReachable])
        {
            self.stopTranscriptionButton.hidden = false;
        
            if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Resume"])
            {
                isStartedNewRequest = true; // set true for resume and using dis append text in delegate
                
                timerSeconds = 60;  // reset after resume

            }

            
            [self authorizeAndTranscribe:sender];
            
            [self.startTranscriptionButton setEnabled:false];
            
            startTranscriptionButton.alpha = 0.5;
            
            transcriptionStatusLabel.text = @"Go ahead, I'm listening";
            
            
        }
        else
        {
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }
    else
    if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Transcript File"])

    {
        if ([[AppPreferences sharedAppPreferences] isReachable])
        {
            [self authorizeAndTranscribe:sender];
        
        }
        else
        {
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
       
    }
    else
    {
        SelectFileViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectFileViewController"];
        
        vc.delegate = self;
        
        [self presentViewController:vc animated:YES completion:nil];
    }
        
    
    
}

- (IBAction)stopLiveAudioTranscription:(id)sender
{

    [self subStopLiveAudioTranscription];
    
    [self hideRightBarButton:false];
    
    timerSeconds = 60;
    
    

}

-(void)subStopLiveAudioTranscription
{
    [self.startTranscriptionButton setEnabled:true];
    
    startTranscriptionButton.alpha = 1.0;
    
    [startTranscriptionButton setTitle:@"Resume" forState:UIControlStateNormal];

    if (self.capture != nil && [self.capture isRunning])
    {
        [self.capture stopRunning];
    }
    
    [audioEngine stop];
    
    [request endAudio];
    
    
    //[recognitionTask cancel];
    
    [newRequestTimer invalidate];
    
    //UIView* keyWindow = [UIApplication sharedApplication].keyWindow;

    [self startTranscriptionStatusViewAnimationToDown:false];   //remove animation
    
    audioFileName = nil; // to save the recorded file

}

- (IBAction)segmentChanged:(UISegmentedControl*)sender
{
//    if(sender.selectedSegmentIndex == 0)
//    {
//        self.stopTranscriptionButton.hidden = true;
//        self.fileNameLabel.hidden = false;
//        [self.startTranscriptionButton setTitle:@"Select File" forState:UIControlStateNormal];
//
//    }
//    else
//    {
        self.stopTranscriptionButton.hidden = false;
      //  self.fileNameLabel.hidden = true;
      //  [self.startTranscriptionButton setTitle:@"Start Transcription" forState:UIControlStateNormal];
        
   // }
}


-(void) transcribeLiveAudio
{    


   // [audioEngine stop];
    
    [request endAudio];
    
    [recognitionTask cancel];
    
    recognitionTask = nil;
// with delegate
    request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];


    dispatch_async(dispatch_get_main_queue(), ^{

       
        //[self startCapture];
        [self recordUsingTap];
        [self startTranscriptionStatusViewAnimationToDown:true];
        [self setTimer];
        //[self demoTimer];
        
        recognitionTask = [speechRecognizer recognitionTaskWithRequest:self.request delegate:self];

    });
    

    
    //request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    


}

//-(void)createTaskRequest
//{
//    request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
//
//    recognitionTask = [speechRecognizer recognitionTaskWithRequest:request delegate:self];
//
//}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    [self.request appendAudioSampleBuffer:sampleBuffer];
    
//    NSError* error;
//    bool isWr = [audioFileName writeFromBuffer:sampleBuffer error:&error];
//
//    [self.request appendAudioPCMBuffer:sampleBuffer];
    
//    if (timerSeconds == 1)
//    {
 //       audioFileName = nil;
//    }
//    NSError* error;
//
//    NSURL* audioExportURL = [self urlForFile:@"sample234.m4a"];
//    AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:audioExportURL fileType:AVFileTypeAppleM4A error:&error];
//
//    AudioChannelLayout channelLayout;
//    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
//    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
//    NSDictionary *audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                              [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
//                                              [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
//                                              [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
//                                              [NSNumber numberWithInt:128000], AVEncoderBitRateKey,
//                                               nil];
//
//    AVAssetWriterInput *writerAudioInput;
//
//
//
//    writerAudioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
//
//    writerAudioInput.expectsMediaDataInRealTime = YES;
//
//    if ([writer canAddInput:writerAudioInput]) {
//        [writer addInput:writerAudioInput];
//    } else {
//        NSLog(@"ERROR ADDING AUDIO");
//    }
//
//    [writer startWriting];
//
//    CMTime time = kCMTimeZero;
//
//    [writer startSessionAtSourceTime:time];
//
//    if([writerAudioInput isReadyForMoreMediaData])
//    {
//       bool isAppended = [writerAudioInput appendSampleBuffer:sampleBuffer];
//
//        NSLog(@"%d",isAppended);
//    }
//    AVAssetWriterStatus status = [writer status];
//
//    NSLog(@"%@", writer.error.localizedFailureReason);
//    NSLog(@"%@", writer.error.localizedDescription);
//
//    NSLog(@"%ld",status);

}
-(void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task
{
    
}

-(void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task
{
    NSLog(@"1");
}

-(void)speechRecognitionTaskFinishedReadingAudio:(SFSpeechRecognitionTask *)task
{
    [[AppPreferences sharedAppPreferences] showHudWithTitle:@"Transcripting" detailText:@"Please wait.."];
    
    NSLog(@"2");
}

-(void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully
{
//    if ([self.capture isRunning])
//    {
//        [self transcribeLiveAudio];
//        isStartedNewRequest = true;
//    }
    
    [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
    [self.previousTranscriptedArray replaceObjectAtIndex:0 withObject: self.transcriptionTextLabel.text];
    NSLog(@"3");
    NSLog(@"Finished sucessfully");
}

-(void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult
{
    NSLog(@"4");
    SFTranscription* transcription = recognitionResult.bestTranscription;
    NSString* formattedString =  transcription.formattedString;
    
    
    [recognitionTask cancel];
    
    
//    if (self.previousTranscriptedArray.count > 0)
//    {
//        NSString* previousTranscriptedText = [self.previousTranscriptedArray objectAtIndex:0];
//
//        NSString* newComposedString;
//
//        newComposedString = [previousTranscriptedText stringByAppendingString:[NSString stringWithFormat:@" %@",formattedString]];
//
//        [self.previousTranscriptedArray replaceObjectAtIndex:0 withObject:newComposedString];
//
//
//    }
//    else
//    {
//        [self.previousTranscriptedArray addObject:[NSString stringWithFormat:@"%@ ",formattedString]];
//    }
    
}

-(void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription
{
    NSLog(@"5");
    
    if (transcription != nil)
    {
        //NSLog(@"%@", transcription.formattedString);
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           //NSLog(@"Reachable");
                          
                           //NSString* formattedString =  transcription.formattedString;
                           
                           if (isStartedNewRequest == true)
                           {
                               NSString* text = [self.previousTranscriptedArray objectAtIndex:0];
                               
                               self.transcriptionTextLabel.text = [text stringByAppendingString:[NSString stringWithFormat:@" %@",transcription.formattedString]];
                               
                               // [self.previousTranscriptedArray replaceObjectAtIndex:0 withObject: self.transcriptionTextLabel.text];
                               
                               
                           }
                           else
                           {
                               [self.previousTranscriptedArray replaceObjectAtIndex:0 withObject:transcription.formattedString];
                               
                               self.transcriptionTextLabel.text = [self.previousTranscriptedArray objectAtIndex:0];
                               
                               //[self.previousTranscriptedArray replaceObjectAtIndex:0 withObject: self.transcriptionTextLabel.text];
                               
                           }
                           
                           CGSize maximumLabelSize = CGSizeMake(96, FLT_MAX);
                           
                           
                           CGSize expectedLabelSize = [self.transcriptionTextLabel.text sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
                           
                           self.scrollVIew.contentSize = expectedLabelSize;
                           
//                           if (self.previousTranscriptedArray.count > 0)
//                           {
//                               NSString* previousTranscriptedText = [self.previousTranscriptedArray objectAtIndex:0];
//
//                               NSString* updatedTranscriptedText = [previousTranscriptedText stringByAppendingString:[NSString stringWithFormat:@"%@",formattedString]];
//
//                               CGSize maximumLabelSize = CGSizeMake(96, FLT_MAX);
//
//                               CGSize expectedLabelSize = [updatedTranscriptedText sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
//
//                               self.transcriptionTextLabel.text = updatedTranscriptedText;
//
//                               self.scrollVIew.contentSize = expectedLabelSize;
//
//
//                           }
//                           else
//                           {
//                               self.transcriptionTextLabel.text = transcription.formattedString;
//                           }
                       });
    }
}





-(void)authorizeAndTranscribe:(UIButton*)sender
{
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status)
        {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                
                

                if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Start Transcription"] || [[sender titleForState:UIControlStateNormal]  isEqual: @"Resume"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        [self transcribeLiveAudio];
                    });
                   
                    
                    
                    
                }
                else
                    if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Transcript File"])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self transcribePreRecordedAudio];

                        });
                    }
                
                //[self transcribePreRecordedAudio];
                break;
                
            case SFSpeechRecognizerAuthorizationStatusDenied:
                
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                
                break;
            default:
                break;
        }
    }];
    
}

-(void)setTimer
{
    newRequestTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    
}

-(void)updateTime:(id) sender
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if (timerSeconds == 0)
                       {
                           [newRequestTimer invalidate];
                           
                          // [self startTranscriptionStatusViewAnimationToDown:false];

                           [self subStopLiveAudioTranscription];
                           
                           [startTranscriptionButton setEnabled:true];
                           
                           startTranscriptionButton.alpha = 1.0;

                           [startTranscriptionButton setTitle:@"Resume" forState:UIControlStateNormal];
                           
                           transcriptionStatusLabel.text = @"Press Resume to continue";
                           
                           [self hideRightBarButton:false];
                         
                           audioFileName = nil; // to save the recorded file
                           //isStartedNewRequest = true;

                           //[self.previousTranscriptedArray replaceObjectAtIndex:0 withObject:self.transcriptionTextLabel.text];

                       }
                       else
                       {
                           --timerSeconds;
                           
                           timerLabel.text = [NSString stringWithFormat:@"00:%02d",timerSeconds];
                       }
                       
                   });
    
   
    
}

- (void)startCapture
{
    NSError *error;
    self.capture = [[AVCaptureSession alloc] init];
    AVCaptureDevice *audioDev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (audioDev == nil){
        NSLog(@"Couldn't create audio capture device");
        return ;
    }
    
    // create mic device
    AVCaptureDeviceInput *audioIn = [AVCaptureDeviceInput deviceInputWithDevice:audioDev error:&error];
    if (error != nil){
        NSLog(@"Couldn't create audio input");
        return ;
    }
    
    // add mic device in capture object
    if ([self.capture canAddInput:audioIn] == NO){
        NSLog(@"Couldn't add audio input");
        return ;
    }
    [self.capture addInput:audioIn];
    // export audio data
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    if ([self.capture canAddOutput:audioOutput] == NO){
        NSLog(@"Couldn't add audio output");
        return ;
    }
    [self.capture addOutput:audioOutput];
    [audioOutput connectionWithMediaType:AVMediaTypeAudio];

    [self.capture startRunning];
}


-(void)setFileName:(NSString *)fileName
{
    //self.fileNameLabel.text = fileName;
    
    [self.startTranscriptionButton setTitle:@"Transcript File" forState:UIControlStateNormal];
    
}


-(void)withoutDelegateTrans
{
    AVAudioInputNode* inputNode = audioEngine.inputNode;
    
    [inputNode removeTapOnBus:0];
    //AVAudioFormat* recordingFormat = [inputNode inputFormatForBus:0];
    
    [inputNode installTapOnBus:0 bufferSize:2048 format:[inputNode inputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when)
     {
         [self.request appendAudioPCMBuffer:buffer];
     }];
    
    [audioEngine prepare];
    
    NSError* error;
    
    [audioEngine startAndReturnError:&error];
    
    request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    [self startTranscriptionStatusViewAnimationToDown:true];
    
    [self setTimer];
    
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        SFTranscription* transcription = result.bestTranscription;
        
        if (transcription != nil)
        {
            //NSLog(@"%@", transcription.formattedString);
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               
                               
                               if (isStartedNewRequest == true)
                               {
                                   NSString* text = [self.previousTranscriptedArray objectAtIndex:0];
                                   
                                   self.transcriptionTextLabel.text = [text stringByAppendingString:[NSString stringWithFormat:@" %@",transcription.formattedString]];
                                   
                                   // [self.previousTranscriptedArray replaceObjectAtIndex:0 withObject: self.transcriptionTextLabel.text];
                                   
                                   
                               }
                               else
                               {
                                   [self.previousTranscriptedArray replaceObjectAtIndex:0 withObject:transcription.formattedString];
                                   self.transcriptionTextLabel.text = [self.previousTranscriptedArray objectAtIndex:0];
                                   
                               }
                               
                               CGSize maximumLabelSize = CGSizeMake(96, FLT_MAX);
                               
                               
                               CGSize expectedLabelSize = [self.transcriptionTextLabel.text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
                               
                               self.scrollVIew.contentSize = expectedLabelSize;
                               
                           });
        }
        
    }];
    
    
    
}

-(void)recordUsingTap
{
    AVAudioInputNode* inputNode = audioEngine.inputNode;
    
    [inputNode removeTapOnBus:0];
    //AVAudioFormat* recordingFormat = [inputNode inputFormatForBus:0];
    
    [inputNode installTapOnBus:0 bufferSize:2048 format:[inputNode inputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when)
     {
         // code to record the audio.
//         NSError* error;
//         bool isWr = [audioFileName writeFromBuffer:buffer error:&error];
//
         if (buffer == nil)
         {
             [recognitionTask cancel];
         }
         [self.request appendAudioPCMBuffer:buffer];
//
//         if (timerSeconds == 1)
//         {
//             audioFileName = nil;
//         }
     }];
    
    [audioEngine prepare];
    
    NSError* error;
    
    [audioEngine startAndReturnError:&error];
    
}
-(void) transcribePreRecordedAudio
{
    //NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sample1" ofType:@"wav"];
    
    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,self.fileNameLabel.text]];
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       //NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,self.fileNameLabel.text]];
                       
                       NSURL* url = [[NSURL alloc] initFileURLWithPath:filePath];
                       
                       self.urlRequest = [[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
                       
                       [speechRecognizer recognitionTaskWithRequest:self.urlRequest delegate:self];
                       
                       //        [speechRecognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error)
                       //         {
                       //             SFTranscription* transcription = result.bestTranscription;
                       //
                       //             CGSize maximumLabelSize = CGSizeMake(96, FLT_MAX);
                       //
                       //             //            CGSize expectedLabelSize = [feedObject.detailMessage sizeWithFont:feedText.font constrainedToSize:maximumLabelSize lineBreakMode:feedText.lineBreakMode];
                       //             CGSize expectedLabelSize = [transcription.formattedString sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
                       //
                       //             self.transcriptionTextLabel.text = transcription.formattedString;
                       //
                       //             self.scrollVIew.contentSize = expectedLabelSize;
                       //             //NSLog(@"%@", transcription.formattedString);
                       //         }];
                   });
    
    
    
    //    NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"es-MX"];
    //    speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:local];
    //    NSString* path = [[NSBundle mainBundle] pathForResource:@"sample1" ofType:@"wav"];
    //    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    //    if(!speechRecognizer.isAvailable)
    //        NSLog(@"speechRecognizer is not available, maybe it has no internet connection");
    //    SFSpeechURLRecognitionRequest *urlRequest = [[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
    //    urlRequest.shouldReportPartialResults = YES; // YES if animate writting
    //    [speechRecognizer recognitionTaskWithRequest: urlRequest resultHandler:  ^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error)
    //     {
    //         NSString *transcriptText = result.bestTranscription.formattedString;
    //         if(!error)
    //         {
    //             NSLog(@"transcriptText");
    //         }
    //     }];
}

-(NSURL*)urlForFile:(NSString*)fileName
{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSURL* url = [NSURL fileURLWithPath:filePath];
    AVAudioFile* file = [[AVAudioFile alloc] init];
    
    
    return url;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end

