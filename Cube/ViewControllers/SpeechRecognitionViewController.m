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
@synthesize audioEngine,request,recognitionTask,speechRecognizer,isStartedNewRequest, transcriptionStatusView,timerSeconds,startTranscriptionButton,stopTranscriptionButton,timerLabel,transcriptionStatusLabel,transcriptionTextLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stopTranscriptionButton.hidden = true;

    self.transcriptionTextLabel.lineBreakMode = NSLineBreakByWordWrapping;

    self.previousTranscriptedArray = [NSMutableArray new];
    NSError* error;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];

    audioEngine = [[AVAudioEngine alloc] init];
 
    speechRecognizer = [[SFSpeechRecognizer alloc] init];
    
    request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
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
    
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ResumeTrans"] style:UIBarButtonItemStylePlain target:self action:@selector(resetTranscription)];
    
    
}

-(void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)resetTranscription
{
    [self startTranscriptionStatusViewAnimation:false];
    
    [startTranscriptionButton setTitle:@"Start Transcription" forState:UIControlStateNormal];

    startTranscriptionButton.alpha = 1.0;
    
    [startTranscriptionButton setEnabled:true];
    
    isStartedNewRequest = false;
    
    transcriptionTextLabel.text = @"";
    
    timerSeconds = 59;
    
    transcriptionStatusLabel.text = @"Go ahead, I'm listening!";
    
    [self.previousTranscriptedArray removeAllObjects]; // remove  prev. trans. text
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
    
    self.timerSeconds = 59;
}

-(void)addTranscriptionStatusAnimationView
{
    transcriptionStatusView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1, -60, self.view.frame.size.width*0.8, 48)];
    
    transcriptionStatusView.backgroundColor = [UIColor appOrangeColor];
    
    transcriptionStatusView.layer.cornerRadius = 4.0;
    
    transcriptionStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(transcriptionStatusView.frame.size.width*0.1, 5, transcriptionStatusView.frame.size.width*0.8, 20)];
    
    transcriptionStatusLabel.font = [UIFont systemFontOfSize:15];
    
    transcriptionStatusLabel.text = @"Go ahead, I'm listening!";
    
    transcriptionStatusLabel.textAlignment = NSTextAlignmentCenter;
    
    timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(transcriptionStatusView.frame.size.width/2-30, 30, 60, 15)];
    
    timerLabel.text = @"00:59";
    
    timerLabel.font = [UIFont systemFontOfSize:15];

    timerLabel.textAlignment = NSTextAlignmentCenter;
    
    [transcriptionStatusView addSubview:transcriptionStatusLabel];
    
    [transcriptionStatusView addSubview:timerLabel];
    
    [self.view addSubview:transcriptionStatusView];
    
}

-(void)startTranscriptionStatusViewAnimation:(BOOL)moveDown
{
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0.1 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        
        //            self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.1, self.view.frame.size.height*0.09, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);
        int moveDownDistance;
        if (moveDown == true)
        {
            moveDownDistance = 65;
        }
        else
        {
            moveDownDistance = -60;

        }
        self.transcriptionStatusView.frame = CGRectMake(self.view.frame.size.width*0.1, moveDownDistance, self.view.frame.size.width*0.8, 48);
        
    } completion:^(BOOL finished) {
        
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
                
                timerSeconds = 59;  // reset after resume

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
    [self startTranscriptionStatusViewAnimation:false];

    [self subStopLiveAudioTranscription];
    
}

-(void)subStopLiveAudioTranscription
{
    [self.startTranscriptionButton setEnabled:true];
    
    startTranscriptionButton.alpha = 1.0;
    
    if (self.capture != nil && [self.capture isRunning])
    {
        [self.capture stopRunning];
    }
    
    [audioEngine stop];
    
    [request endAudio];
    
    [recognitionTask cancel];
    
    [newRequestTimer invalidate];
    
    [self hideRightBarButton:false];
    
    

}

- (IBAction)segmentChanged:(UISegmentedControl*)sender
{
    if(sender.selectedSegmentIndex == 0)
    {
        self.stopTranscriptionButton.hidden = true;
        self.fileNameLabel.hidden = false;
        [self.startTranscriptionButton setTitle:@"Select File" forState:UIControlStateNormal];
        
    }
    else
    {
        self.stopTranscriptionButton.hidden = false;
        self.fileNameLabel.hidden = true;
        [self.startTranscriptionButton setTitle:@"Start Transcription" forState:UIControlStateNormal];
        
    }
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

-(void) transcribeLiveAudio
{    
//    AVAudioInputNode* inputNode = audioEngine.inputNode;
//
////    [inputNode removeTapOnBus:0];
//    //AVAudioFormat* recordingFormat = [inputNode inputFormatForBus:0];
//
//    [inputNode installTapOnBus:0 bufferSize:2048 format:[inputNode inputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when)
//    {
//        [self.request appendAudioPCMBuffer:buffer];
//    }];
//
//    [audioEngine prepare];
//
//    NSError* error;
//
//    [audioEngine startAndReturnError:&error];
//
    //[self createTaskRequest];
    
    self.request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    [speechRecognizer recognitionTaskWithRequest:self.request delegate:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self startCapture];
        [self startTranscriptionStatusViewAnimation:true];
        [self setTimer];

    });
    //request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    //recognitionTask = [speechRecognizer recognitionTaskWithRequest:request delegate:self];
    //[self startCapture];
//    recognitionTask = [speechRecognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
//        SFTranscription* transcription = result.bestTranscription;
//
//        if (transcription != nil)
//        {
//            //NSLog(@"%@", transcription.formattedString);
//            dispatch_async(dispatch_get_main_queue(), ^
//                           {
//                               //NSLog(@"Reachable");
//                               self.transcriptionTextLabel.text = transcription.formattedString;
//                           });
//        }
//
//    }];
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
   NSLog(@"2");
}

-(void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully
{
    if ([self.capture isRunning])
    {
        //[self transcribeLiveAudio];
//        isStartedNewRequest = true;
    }
    

//    NSLog(@"3");
//    NSLog(@"Finished sucessfully");
}

-(void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult
{
   // NSLog(@"4");
    SFTranscription* transcription = recognitionResult.bestTranscription;
    NSString* formattedString =  transcription.formattedString;
    if (self.previousTranscriptedArray.count > 0)
    {
        NSString* previousTranscriptedText = [self.previousTranscriptedArray objectAtIndex:0];
        
        NSString* newComposedString;
        if (isStartedNewRequest == true)
        {
            newComposedString = [previousTranscriptedText stringByAppendingString:[NSString stringWithFormat:@" %@",formattedString]];
            isStartedNewRequest = false;
        }
        else
        {
            newComposedString = [previousTranscriptedText stringByAppendingString:[NSString stringWithFormat:@"%@",formattedString]];
        }
        
        [self.previousTranscriptedArray replaceObjectAtIndex:0 withObject:newComposedString];

        
    }
    else
    {
        [self.previousTranscriptedArray addObject:[NSString stringWithFormat:@"%@ ",formattedString]];
    }
    
//    if (transcription != nil)
//    {
//        //NSLog(@"%@", transcription.formattedString);
//        dispatch_async(dispatch_get_main_queue(), ^
//                       {
//                           //NSLog(@"Reachable");
//                           self.transcriptionTextLabel.text = transcription.formattedString;
//                       });
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
                           NSString* formattedString =  transcription.formattedString;

                           if (self.previousTranscriptedArray.count > 0)
                           {
                               NSString* previousTranscriptedText = [self.previousTranscriptedArray objectAtIndex:0];
                               
                               NSString* updatedTranscriptedText = [previousTranscriptedText stringByAppendingString:[NSString stringWithFormat:@"%@",formattedString]];
                               
//                               CGSize size = [updatedTranscriptedText sizeWithFont:[UIFont systemFontOfSize:15] forWidth:self.view.frame.size.width*0.8 lineBreakMode:NSLineBreakByWordWrapping];
                               
                               CGSize maximumLabelSize = CGSizeMake(96, FLT_MAX);
                               
                               //            CGSize expectedLabelSize = [feedObject.detailMessage sizeWithFont:feedText.font constrainedToSize:maximumLabelSize lineBreakMode:feedText.lineBreakMode];
                               CGSize expectedLabelSize = [updatedTranscriptedText sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
                               
                               self.transcriptionTextLabel.text = updatedTranscriptedText;
                               
                               self.scrollVIew.contentSize = expectedLabelSize;

                               
                           }
                           else
                           {
                               self.transcriptionTextLabel.text = transcription.formattedString;
                           }
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
                           
                           [self startTranscriptionStatusViewAnimation:false];

                           [self subStopLiveAudioTranscription];
                           
                           [startTranscriptionButton setEnabled:true];
                           
                           startTranscriptionButton.alpha = 1.0;

                           [startTranscriptionButton setTitle:@"Resume" forState:UIControlStateNormal];
                           
                           transcriptionStatusLabel.text = @"Press Resume to continue transcription";
                           
                           [self hideRightBarButton:false];
                         
                           isStartedNewRequest = true;

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
    self.fileNameLabel.text = fileName;
    
    [self.startTranscriptionButton setTitle:@"Transcript File" forState:UIControlStateNormal];
    
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
