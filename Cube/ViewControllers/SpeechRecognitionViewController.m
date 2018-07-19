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
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"
#import "DocFileDetails.h"

@interface SpeechRecognitionViewController ()

@end

@implementation SpeechRecognitionViewController
@synthesize audioEngine,request,recognitionTask,speechRecognizer,isStartedNewRequest, transcriptionStatusView,timerSeconds,startTranscriptionButton,stopTranscriptionButton,timerLabel,transcriptionStatusLabel,transcriptionTextLabel,audioFileName,transFIleImageVIew,transStopImageView,transRecordImageView,startLabel,stopLabel,docFileLabel,docFileButton,alertController;

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
 
    speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
    
    request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    //speechRecognizer = [[SFSpeechRecognizer alloc] init];

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
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    
    [self.tabBarController.tabBar setHidden:NO];

    self.navigationItem.hidesBackButton = true;

    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self addTranscriptionStatusAnimationView];
    
    self.timerSeconds = 59;
    
    [self disableStopAndDocOption];
    
    self.tabBarController.tabBar.hidden = true;
    
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
}

-(void)disableStopAndDocOption
{
    docFileLabel.alpha = 0.5;
    
    transFIleImageVIew.alpha = 0.5;
    
    [docFileButton setEnabled:false];
    
    
    stopLabel.alpha = 0.5;
    
    transStopImageView.alpha = 0.5;
    
    [stopTranscriptionButton setEnabled:false];
}

-(void)disableStartAndDocOption:(BOOL)disable
{
    if (disable == true)
    {
        transRecordImageView.alpha = 0.5;
        
        startLabel.alpha = 0.5;  //enable color
        
        [startTranscriptionButton setEnabled:false];
        
        
        [docFileButton setEnabled:false];
        
        transFIleImageVIew.alpha = 0.5;
        
        docFileLabel.alpha = 0.5;
    }
    else
    {
        transRecordImageView.alpha = 1.0;
        
        startLabel.alpha = 1.0;  //enable color
        
        [startTranscriptionButton setEnabled:true];
        
        
        [docFileButton setEnabled:true];
        
        transFIleImageVIew.alpha = 1.0;
        
        docFileLabel.alpha = 1.0;
    }
    
}

-(void)enableStopOption:(BOOL)enable
{
    if (enable == true)
    {
        [stopTranscriptionButton setEnabled:true];
        
        transStopImageView.alpha = 1.0;
        
        stopLabel.alpha = 1.0;
    }
    else
    {
        [stopTranscriptionButton setEnabled:false];
        
        transStopImageView.alpha = 0.5;
        
        stopLabel.alpha = 0.5;
    }
    
}
//-(void)addCricleViews
//{
//    float circlViewSizeAndWidth = self.view.frame.size.width*.18;
//    float startAndEndSpace = self.view.frame.size.width*.16;
//    float middleSpace = self.view.frame.size.width*0.07;
//
//    UIButton* startTranscriptionButton = [[UIButton alloc] initWithFrame:CGRectMake(startAndEndSpace, self.navigationController.navigationBar.frame.size.height+self.view.frame.size.width*0.05+10, circlViewSizeAndWidth, circlViewSizeAndWidth)];
//
//    UIButton* stopTranscriptionButton = [[UIButton alloc] initWithFrame:CGRectMake(startTranscriptionButton.frame.origin.x+startTranscriptionButton.frame.size.width+middleSpace, startTranscriptionButton.frame.origin.y, circlViewSizeAndWidth, circlViewSizeAndWidth)];
//
//    UIButton* createDocFileButton = [[UIButton alloc] initWithFrame:CGRectMake(stopTranscriptionButton.frame.origin.x+stopTranscriptionButton.frame.size.width+middleSpace, startTranscriptionButton.frame.origin.y, circlViewSizeAndWidth, circlViewSizeAndWidth)];
//
//    startTranscriptionButton.layer.cornerRadius = startTranscriptionButton.frame.size.width/2.0;
//    stopTranscriptionButton.layer.cornerRadius = startTranscriptionButton.frame.size.width/2.0;
//    createDocFileButton.layer.cornerRadius = startTranscriptionButton.frame.size.width/2.0;
//
//    startTranscriptionButton.layer.borderColor = [UIColor appOrangeColor].CGColor;
//    stopTranscriptionButton.layer.borderColor = [UIColor appOrangeColor].CGColor;
//    createDocFileButton.layer.borderColor = [UIColor appOrangeColor].CGColor;
//
//    startTranscriptionButton.layer.borderWidth = 3.0;
//    stopTranscriptionButton.layer.borderWidth = 3.0;
//    createDocFileButton.layer.borderWidth = 3.0;
//
//    [self.view addSubview:startTranscriptionButton];
//    [self.view addSubview:stopTranscriptionButton];
//    [self.view addSubview:createDocFileButton];
//
//    [startTranscriptionButton setBackgroundColor:[UIColor clearColor]];
//    [stopTranscriptionButton setBackgroundColor:[UIColor clearColor]];
//    [createDocFileButton setBackgroundColor:[UIColor clearColor]];
//
//    [startTranscriptionButton setImage:[UIImage imageNamed:@"RecordTab"] forState:UIControlStateNormal];
//    [stopTranscriptionButton setImage:[UIImage imageNamed:@"Stop"] forState:UIControlStateNormal];
//    [createDocFileButton setImage:[UIImage imageNamed:@"File"] forState:UIControlStateNormal];
//
//}
-(void)demoTimer
{
    demoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkState) userInfo:nil repeats:YES];
    
}
-(void)checkState
{
    NSLog(@"state is = %ld", (long)recognitionTask.state);
}


-(void)resetTranscription
{
    [self disableStopAndDocOption];

    [self startTranscriptionStatusViewAnimationToDown:false]; // animate trans status to upperside
    
    [startTranscriptionButton setTitle:@"Start Transcription" forState:UIControlStateNormal]; // chnage title dont remove this

    transRecordImageView.image = [UIImage imageNamed:@"TransRecord"];
    
    startLabel.text = @"Start";
    
    startTranscriptionButton.alpha = 1.0;
    
    [startTranscriptionButton setEnabled:true];
    
    isStartedNewRequest = false;
    
    transcriptionTextLabel.text = @"";
    
    timerSeconds = 59;
    
    if (self.capture != nil && [self.capture isRunning])
    {
        [self.capture stopRunning];
    }
    
    [audioEngine stop];
    
    [request endAudio];

    //[recognitionTask cancel];
    
    [newRequestTimer invalidate];
    
    transcriptionStatusLabel.text = @"Go ahead, I'm listening!";
    
    timerLabel.text = @"00:59";

    [self.previousTranscriptedArray removeAllObjects]; // remove  prev. trans. text
    
    [self.previousTranscriptedArray addObject:@""];
    
    [self hideRightBarButton:true];

}

-(void)hideRightBarButton:(BOOL)hide
{
    if (hide == true)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"TransReset"] style:UIBarButtonItemStylePlain target:self action:@selector(resetTranscription)];

    }
    
}


-(void)addTranscriptionStatusAnimationView
{
    UIView* keyWindow = [UIApplication sharedApplication].keyWindow;
    
   
    transcriptionStatusView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.05, -70, self.view.frame.size.width*0.8, 48)];
    
    transcriptionStatusView.tag = 3000;
    
   
    transcriptionStatusView.layer.cornerRadius = 4.0;
    
    transcriptionStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(transcriptionStatusView.frame.size.width*0.1, 5, transcriptionStatusView.frame.size.width*0.9, 30)];
    
    transcriptionStatusLabel.font = [UIFont systemFontOfSize:15];
    
    transcriptionStatusLabel.text = @"Go ahead, I'm listening!";
    
    transcriptionStatusLabel.textAlignment = NSTextAlignmentCenter;
    
//    timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(transcriptionStatusLabel.frame.origin.x, transcriptionStatusLabel.frame.origin.y+transcriptionStatusLabel.frame.size.height, transcriptionStatusLabel.frame.size.width, 50)];

    timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(transcriptionStatusLabel.frame.origin.x, 30, transcriptionStatusLabel.frame.size.width, 20)];
    timerLabel.text = @"00:59";
    
    timerLabel.font = [UIFont systemFontOfSize:15];

    timerLabel.textAlignment = NSTextAlignmentCenter;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        transcriptionStatusView.frame = CGRectMake(self.view.frame.size.width*0.05, self.view.frame.size.height + 20, self.view.frame.size.width*0.8, 60);  // set animate view at bottom+20 of the view
        
        timerLabel.frame = CGRectMake(transcriptionStatusLabel.frame.origin.x, 35, transcriptionStatusLabel.frame.size.width, 50);
        
        transcriptionStatusView.backgroundColor = [UIColor whiteColor];
        
        self.startPauseDocBGView.layer.cornerRadius = 4.0;
        
        transcriptionStatusLabel.textColor = [UIColor lightGrayColor];
        
        timerLabel.textColor = [UIColor darkGrayColor];
        
//        transcriptionStatusLabel.frame = CGRectMake(transcriptionStatusView.frame.size.width*0.1, 5, transcriptionStatusView.frame.size.width*0.9, 20);
//
//        timerLabel.frame = CGRectMake(transcriptionStatusView.frame.size.width/2-30, 30, 60, 15);
        
        transcriptionStatusLabel.font = [UIFont systemFontOfSize:21];

        timerLabel.font = [UIFont systemFontOfSize:25];

//        self.startPauseDocBGView.backgroundColor = [UIColor appOrangeColor];
    }
    else
    {
        transcriptionStatusView.backgroundColor = [UIColor appOrangeColor];
        
    }
    
    [transcriptionStatusView addSubview:transcriptionStatusLabel];
    
    [transcriptionStatusView addSubview:timerLabel];
    
    
    [keyWindow addSubview:transcriptionStatusView];
    
}

-(void)startTranscriptionStatusViewAnimationToDown:(BOOL)moveDown
{

    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0.1 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        
        //            self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.1, self.view.frame.size.height*0.09, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);
        int moveDownDistance;
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            if (moveDown == true)
            {
                moveDownDistance = -110;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.startPauseDocBGView.backgroundColor = [UIColor appOrangeColor];

                });
            }
            else
            {
                moveDownDistance = 110;
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                    self.transcriptionStatusView.frame = CGRectMake(self.view.frame.size.width*0.05, self.view.frame.size.height + moveDownDistance, self.view.frame.size.width*0.9, 48);
            });
            
        }
        else
        {
            if (moveDown == true)
            {
                moveDownDistance = 15;
            }
            else
            {
                moveDownDistance = -60;
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.transcriptionStatusView.frame = CGRectMake(self.view.frame.size.width*0.05, moveDownDistance, self.view.frame.size.width*0.9, 48);
            });
            
        }
       
       
        
    } completion:^(BOOL finished) {
        
        timerLabel.text = @"00:59";
    }];
}

-(void)popViewController:(id)sender
{
    if (isTranscripting)
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Transcripting.." withMessage:@"Please stop the transcription" withCancelText:@"Ok" withOkText:@"" withAlertTag:1000];
    }
    else if (transcriptionTextLabel.text.length>0)
    {
        alertController = [UIAlertController alertControllerWithTitle:@"Transcription not saved!"
                                                              message:@"Save transcription as doc file?"
                                                       preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* actionCreate = [UIAlertAction actionWithTitle:@"Save"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action)
                                       {
                                           
                                           [self createSubDocFileButtonClicked];
                                       }]; //You can use a block here to handle a press on this button
        
        UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Don't save"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action)
                                       {
                                           //                                           [self.navigationController.tabBarController setSelectedIndex:0];
                                           

                                           [transcriptionStatusView removeFromSuperview];
                                           
                                           [self dismissViewControllerAnimated:true completion:nil];
                                           
                                           //                                           [self.navigationController popViewControllerAnimated:YES];
                                           
                                       }];
        
        [alertController addAction:actionCreate];
        
        [alertController addAction:actionCancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        //                [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:true completion:nil];
        //        [self.navigationController.tabBarController setSelectedIndex:0];
        
    }
    
}
- (IBAction)backButtonPressed:(id)sender
{
    [self popViewController:sender];
}

- (IBAction)startLiveAudioTranscription:(UIButton*)sender
{
    
    if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Start Transcription"] || [[sender titleForState:UIControlStateNormal]  isEqual: @"Resume"])
    {
        if ([[AppPreferences sharedAppPreferences] isReachable])
        {
            //self.stopTranscriptionButton.hidden = false;
            isTranscripting = true;
            
            [newRequestTimer invalidate];
            
            [self disableStartAndDocOption:true];
            
            [self enableStopOption:true];
            
            if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Resume"])
            {
                isStartedNewRequest = true; // set true for resume and using dis append text in delegate
                
                timerSeconds = 59;  // reset after resume

            }

            
            [self authorizeAndTranscribe:sender];
            
            
            transcriptionStatusLabel.text = @"Go ahead, I'm listening";
            
            
        }
        else
        {
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
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
    
    timerSeconds = 59;
    
    

}

-(void)subStopLiveAudioTranscription
{

    [self disableStartAndDocOption:false];
    
    [self enableStopOption:false];
    
    [startTranscriptionButton setTitle:@"Resume" forState:UIControlStateNormal];

    transRecordImageView.image = [UIImage imageNamed:@"TransResume"];
    
    startLabel.text = @"Resume";
    
    if (self.capture != nil && [self.capture isRunning])
    {
        [self.capture stopRunning];
    }
    
    [audioEngine stop];
    
    [request endAudio];
    
    
    //[recognitionTask cancel];
    
    //[newRequestTimer invalidate];
    
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
    NSLog(@"Task cancelled");
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
    
//    [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
    isTranscripting = false;

    [recognitionTask cancel];
    
    [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
    
    [self.previousTranscriptedArray replaceObjectAtIndex:0 withObject: self.transcriptionTextLabel.text];
    NSLog(@"3");
    NSLog(@"Finished sucessfully");
    [self disableStartAndDocOption:false];
    
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"sample" object:nil];//to pause and remove audio player

    

}

//-(void)startNewTrans
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        self.numOfTrimFiles = self.numOfTrimFiles - 1;
//        self.recNum = self.recNum + 1;
//        //    self.recFileName = [NSString stringWithFormat:@"%@%d",self.recFileName,self.recNum];
//
//        if (self.numOfTrimFiles>0)
//        {
//            [self transcribePreRecordedAudio];
//
//        }        //[self transcribeLiveAudio];
//    });
//
//
//}

-(void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult
{
    NSLog(@"4");
    SFTranscription* transcription = recognitionResult.bestTranscription;
    NSString* formattedString =  transcription.formattedString;
    
    if(recognitionResult.isFinal)
    {
         [recognitionTask cancel];
        
        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

    }
   
    
    
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
                        
                        //[self transcribePreRecordedAudio];
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
    if (timerSeconds == -10)
    {
        isTranscripting = false;
        
        [recognitionTask cancel];
        
        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
    }
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                      
                       
                       if (timerSeconds == 0)
                       {
                           //[newRequestTimer invalidate];
                           
                          // [self startTranscriptionStatusViewAnimationToDown:false];

                           
                           BOOL isFinishing = [recognitionTask isFinishing];

                          
                           [self subStopLiveAudioTranscription];
                           
                           [recognitionTask finish];

//                           [self disableStartAndDocOption:false];

                           [startTranscriptionButton setTitle:@"Resume" forState:UIControlStateNormal];
                           
                           transRecordImageView.image = [UIImage imageNamed:@"TransResume"];
                           
                           startLabel.text = @"Resume";
                           
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
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp3"];
    
    //self.recFileName = [NSString stringWithFormat:@"%@%d",self.recFileName,self.recNum];

   // NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",self.recFileName]];

    
    filePath = [filePath stringByAppendingPathExtension:@"m4a"];
//    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp3"];
    //NSString* filePath = [[NSBundle mainBundle] pathForResource:@"CallCsample1" ofType:@"mp3"];


    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       //NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,self.fileNameLabel.text]];
                       
                       //speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
                       
                       //request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
                       
                       NSURL* url = [[NSURL alloc] initFileURLWithPath:filePath];
                       
                       self.urlRequest = [[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
                       
                       NSLocale* locale = [speechRecognizer locale];
                       
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
    //AVAudioFile* file = [[AVAudioFile alloc] init];
    
    
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
- (IBAction)createDocFileButtonClicked:(id)sender
{
    if (transcriptionTextLabel.text.length > 100)
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"File Size" withMessage:@"File size is too small to save" withCancelText:@"Cancel" withOkText:@"Ok" withAlertTag:1000];
    }
    else
    {
        alertController = [UIAlertController alertControllerWithTitle:@"Create Doc File?"
                                                              message:@"Are you sure to create doc file of below text?"
                                                       preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* actionCreate = [UIAlertAction actionWithTitle:@"Create"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        
                        [self createSubDocFileButtonClicked];
                    }]; //You can use a block here to handle a press on this button
        
        UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action)
                                       {
                                           
                                       }];
        
        [alertController addAction:actionCreate];
        
        [alertController addAction:actionCancel];

        [self presentViewController:alertController animated:YES completion:nil];
    
    }
       
    
}

-(void)createSubDocFileButtonClicked
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       //NSLog(@"Reachable");
                       //[[AppPreferences sharedAppPreferences] showHudWithTitle:@"Creating Doc File" detailText:@"Please wait.."];
                       BOOL isWritten = [self createDocFile];
                       
                       if (isWritten == true)
                       {
                           [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Doc File Created" withMessage:@"Doc file created successfully, check doc files in alert tab" withCancelText:@"Ok" withOkText:nil withAlertTag:1000];
                           
                           [self resetTranscription];
                       }
                       //[[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
                       
                   });
    
}
-(BOOL)createDocFile
{
    long todaysSerialNumberCount;
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString* todaysDate = [dateFormatter stringFromDate:[NSDate new]];
    
    NSString* storedTodaysDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"TodaysDateForVSR"];
    
    
    if ([todaysDate isEqualToString:storedTodaysDate])
    {
        todaysSerialNumberCount = [[[NSUserDefaults standardUserDefaults] valueForKey:@"todaysDocSerialNumberCount"] longLongValue];
        
        todaysSerialNumberCount++;
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",todaysSerialNumberCount] forKey:@"todaysDocSerialNumberCount"];

    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:todaysDate forKey:@"TodaysDateForVSR"];
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"todaysDocSerialNumberCount"];
        NSString* countString=[[NSUserDefaults standardUserDefaults] valueForKey:@"todaysDocSerialNumberCount"];
        todaysSerialNumberCount = [countString longLongValue];
        
        todaysSerialNumberCount++;
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",todaysSerialNumberCount] forKey:@"todaysDocSerialNumberCount"];

    }
    
    todaysDate=[todaysDate stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString* fileNamePrefix;
    
    fileNamePrefix=[[NSUserDefaults standardUserDefaults] valueForKey:@"FileNamePrefix"];
    //fileNamePrefix = [[NSUserDefaults standardUserDefaults] valueForKey:@"fileNamePrefix"];
    
    NSString* docFileName=[NSString stringWithFormat:@"%@%@-%02ldVRS",fileNamePrefix,todaysDate,todaysSerialNumberCount];
    
    BOOL isWritten = [self checkAndCreateDocFile:docFileName];
    
    if (isWritten == true)
    {
        DocFileDetails* docFileDetails = [DocFileDetails new];
        
        docFileDetails.docFileName = docFileName;
        
        docFileDetails.audioFileName = docFileName;
        
        docFileDetails.uploadStatus = NOUPLOAD;
        
        docFileDetails.deleteStatus = NODELETE;
        
        docFileDetails.createdDate = [[APIManager sharedManager] getDateAndTimeString];
        
        docFileDetails.uploadDate = @"";
        
        [[Database shareddatabase] addDocFileInDB:docFileDetails];
    }
    
    return isWritten;

}
-(BOOL)checkAndCreateDocFile:(NSString*)docFileName
{
    NSError* error;
    
    NSString* folderPath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:DOC_VRS_FILES_FOLDER_NAME]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath])
        
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    
    
//    NSString* homeDirectoryFileName = [sharedAudioFilePathString lastPathComponent];//store on same name as shared file name
//
//    homeDirectoryFileName=[homeDirectoryFileName stringByDeletingPathExtension];
    NSString* docFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@",DOC_VRS_FILES_FOLDER_NAME,docFileName]];
    
    docFilePath = [docFilePath stringByAppendingFormat:@".txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:docFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:docFilePath error:nil];
    }
    
//    BOOL isWritten1 = [[self.transcriptionTextLabel.text dataUsingEncoding:NSUTF8StringEncoding] writeToFile:docFilePath atomically:true];
    BOOL isWritten1 = [[@"Testing Text" dataUsingEncoding:NSUTF8StringEncoding] writeToFile:docFilePath atomically:true];

    //BOOL isWritten = [self.transcriptionTextLabel.text writeToFile:docFilePath atomically:true encoding:NSUTF8StringEncoding error:&error];
    
    return isWritten1;
}

//- (void)trimAudio
//{
//
//
//
//    NSString* dirPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",self.recFileName]];
//
//    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:self.recFileName ofType:@"mp3"];
//
//    NSURL* audioFileInput = [NSURL fileURLWithPath:bundlePath];
//
//    NSURL *audioFileOutput = [NSURL fileURLWithPath:dirPath];
//
//    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
//
//
//    NSError* err;
//
//    BOOL copied = [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:dirPath error:&err];
//
//    NSString* file2 = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",self.recFileName]];
//
//
//    AVAudioPlayer* player= [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileOutput error:&err];
//
//    float duration = player.duration;
//
//    self.numOfTrimFiles = duration/59;
//
//    for (float i = 0, j=1; i<=duration; i=i+59,j++)
//    {
//        float vocalStartMarker = i;
//
//        float vocalEndMarker = i+59;
//
//        int k = j;
//
//        file2 = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@%d",self.recFileName, k]];
//
//        file2 = [file2 stringByAppendingPathExtension:@"m4a"];
//
//        NSURL *audioFileOutput = [NSURL fileURLWithPath:file2];
//
//        [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
//
//        if (!audioFileInput || !audioFileOutput)
//        {
//
//        }
//
//        [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
//
//        AVAsset *asset = [AVAsset assetWithURL:audioFileInput];
//
//        AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
//                                                                                presetName:AVAssetExportPresetAppleM4A];
//
//        if (exportSession == nil)
//        {
//
//        }
//
//        CMTime startTime = CMTimeMake((int)(floor(vocalStartMarker * 100)), 100);
//        CMTime stopTime = CMTimeMake((int)(ceil(vocalEndMarker * 100)), 100);
//        CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
//
//        exportSession.outputURL = audioFileOutput;
//        exportSession.outputFileType = AVFileTypeAppleM4A;
//        exportSession.timeRange = exportTimeRange;
//
//        [exportSession exportAsynchronouslyWithCompletionHandler:^
//         {
//             if (AVAssetExportSessionStatusCompleted == exportSession.status)
//             {
//                 // It worked!
//                 NSLog(@"suuucess");
//             }
//             else if (AVAssetExportSessionStatusFailed == exportSession.status)
//             {
//                 NSLog(@"failed");
//
//                 // It failed...
//             }
//         }];
//
//    }
//
//}

@end

