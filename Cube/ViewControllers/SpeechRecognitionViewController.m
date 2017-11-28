//
//  SpeechRecognitionViewController.m
//  Cube
//
//  Created by mac on 24/11/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import "SpeechRecognitionViewController.h"
#import "SelectFileViewController.h"

@interface SpeechRecognitionViewController ()

@end

@implementation SpeechRecognitionViewController
@synthesize audioEngine,request,recognitionTask,speechRecognizer;

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
 
}

- (IBAction)startLiveAudioTranscription:(UIButton*)sender
{
    
    if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Start Transcription"])
    {
        self.stopTranscriptionButton.hidden = false;
        
        [self authorizeAndTranscribe:sender];
    }
    else
        if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Transcript File"])

    {
        // select file code
        
        [self authorizeAndTranscribe:sender];

       
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
    if (self.capture != nil && [self.capture isRunning])
    {
        [self.capture stopRunning];
    }
    
    [audioEngine stop];
    
    [request endAudio];
    
    [recognitionTask cancel];
    
    
    
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
        [self transcribeLiveAudio];
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
        
        NSString* newComposedString = [previousTranscriptedText stringByAppendingString:[NSString stringWithFormat:@"%@",formattedString]];
        
        [self.previousTranscriptedArray replaceObjectAtIndex:0 withObject:newComposedString];
    }
    else
    {
        [self.previousTranscriptedArray addObject:formattedString];
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
                if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Start Transcription"])
                {
                    [self transcribeLiveAudio];
                }
                else
                    if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Transcript File"])
                    {
                        [self transcribePreRecordedAudio];
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
