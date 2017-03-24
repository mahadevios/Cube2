//
//  InCompleteRecordViewController.m
//  Cube
//
//  Created by mac on 24/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//http://stackoverflow.com/questions/9846653/starting-avassetexportsession-in-the-background       //avmutable does not work in background

#import "InCompleteRecordViewController.h"
#import "DepartMent.h"
#define IMPEDE_PLAYBACK NO
extern OSStatus DoConvertFile(CFURLRef sourceURL, CFURLRef destinationURL, OSType outputFormat, Float64 outputSampleRate);

@interface InCompleteRecordViewController ()

@end

@implementation InCompleteRecordViewController
@synthesize player, recorder, recordedAudioFileName, recordedAudioURL,recordCreatedDateString,existingAudioFileName,existingAudioDate,existingAudioDepartmentName,playerAudioURL,hud,hud1,deleteButton,stopNewImageView,stopNewButton,stopLabel,animatedImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    popupView=[[UIView alloc]init];
    obj=[[PopUpCustomView alloc]init];
    
    //tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disMissPopView:)];
    //tap.delegate=self;
    [[self.view viewWithTag:701] setHidden:YES];
    [[self.view viewWithTag:702] setHidden:YES];
    db=[Database shareddatabase];
    if (!IMPEDE_PLAYBACK)
    {
        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryRecord];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseRecordingFromBackGround) name:NOTIFICATION_PAUSE_RECORDING
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideDeleteButton) name:NOTIFICATION_FILE_UPLOAD_API
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteRecordin) name:NOTIFICATION_DELETE_RECORDING
                                               object:nil];
}

-(void)deleteRecordin
{

    bsackUpAudioFileName=existingAudioFileName;
   [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@backup.wav",AUDIO_FILES_FOLDER_NAME,bsackUpAudioFileName]];
 }

-(void)pauseRecordingFromBackGround
{
    isRecordingStarted=YES;
    recordingPauseAndExit=YES;
//    [recorder pause];
    [recorder stop];
    UIView* startRecordingView = [self.view viewWithTag:303];
    
    UIImageView* startRecordingImageView = [startRecordingView viewWithTag:403];
    
    [stopTimer invalidate];
    
    UILabel* recordOrPauseLabel = [self.view viewWithTag:603];
    
    recordOrPauseLabel.text = @"Resume";
    
   UIImageView* animatedImageView= [self.view viewWithTag:1001];
    [animatedImageView stopAnimating];
    animatedImageView.image=[UIImage imageNamed:@"SoundWave-3"];
    
    if ( [startRecordingImageView.image isEqual:[UIImage imageNamed:@"PauseNew"]] &&  !recordingPausedOrStoped)
    {
        //[self performSelectorInBackground:@selector(composeAudio) withObject:nil];
        //[[UIApplication sharedApplication] beginBackgroundTaskWithName:@"composeAudio" expirationHandler:nil];
        
         [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-15, (startRecordingView.frame.size.height/2)-16, 30, 32)];
        
        recordingPausedOrStoped=YES;
        UIApplication*    appl = [UIApplication sharedApplication];
       task = [appl beginBackgroundTaskWithExpirationHandler:^{
            [appl endBackgroundTask:task];
            task = UIBackgroundTaskInvalid;
        }];
        // Start the long-running task and return immediately.
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // Do the work associated with the task.
            [self performSelectorOnMainThread:@selector(showHud) withObject:nil waitUntilDone:NO];

           // [self performSelector:@selector(composeAudio) withObject:nil afterDelay:0.0];
            [self composeAudio];
            
           // NSLog(@"Started background task timeremaining = %f", [appl backgroundTimeRemaining]);
           
          
           
        });
  
    }
    

    startRecordingImageView.image=[UIImage imageNamed:@"ResumeNew"];
    
}

-(void)hideDeleteButton
{
    if (recorder.isRecording)
    {
        [[self.view viewWithTag:701] setHidden:YES];
        [[self.view viewWithTag:702] setHidden:YES];
    }
    else
    {
       
            [[self.view viewWithTag:701] setHidden:NO];
            [[self.view viewWithTag:702] setHidden:NO];
      
    }
    
}
-(void)showHud
{
    [hud hideAnimated:NO];
    hud.minSize = CGSizeMake(150.f, 100.f);
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"Saving audio..";
    hud.detailsLabel.text = @"Please wait";

}
-(void)viewWillAppear:(BOOL)animated
{
    [AppPreferences sharedAppPreferences].isRecordView=NO;
    
    if (![APIManager sharedManager].userSettingsOpened)
    {
        i=0;
   
        audioDurationLAbel=[self.view viewWithTag:104];
        
        audioDurationLAbel.text=self.audioDuration;
        
        NSArray* audioMinutesAndSecondsArray= [self.audioDuration componentsSeparatedByString:@":"];
        
        timerHour= [[audioMinutesAndSecondsArray objectAtIndex:0]intValue];
        
        timerMinutes=[[audioMinutesAndSecondsArray objectAtIndex:1]intValue];
        
        timerSeconds=[[audioMinutesAndSecondsArray objectAtIndex:2]intValue];
        
        
        audioDurationLAbel.text=[NSString stringWithFormat:@"%02d:%02d:%02d",timerHour,timerMinutes,timerSeconds];
        
        
       //    UIView* stopView= [self.view viewWithTag:201];
//    [self performSelector:@selector(addView:) withObject:stopView afterDelay:0.02];
//    
//    UIView* pauseView= [self.view viewWithTag:202];
//    [self performSelector:@selector(addView:) withObject:pauseView afterDelay:0.02];
    
        UIView* startRecordingView1= [self.view viewWithTag:203];
        
        [self performSelector:@selector(addView:) withObject:startRecordingView1 afterDelay:0.02];
        

    //set and show recording file name when view will appear
        NSDate *date = [[NSDate alloc] init];
        NSTimeInterval seconds = [date timeIntervalSinceReferenceDate];
        long milliseconds = seconds*1000;
        recordedAudioFileName = [NSString stringWithFormat:@"%ld", milliseconds];
    
        UIView* startRecordingView= [self.view viewWithTag:303];
        UIImageView* counterLabel= [startRecordingView viewWithTag:503];
        [counterLabel setHidden:NO];
    

    
        UILabel* fileNameLabel= [self.view viewWithTag:101];
        fileNameLabel.text=[NSString stringWithFormat:@"%@",existingAudioFileName];
        recordedAudioFileName=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] valueForKey:RECORD_ABBREVIATION],recordedAudioFileName];
    
        UILabel* transferredByLabel= [self.view viewWithTag:102];
        transferredByLabel.text=existingAudioDepartmentName;
    
        UILabel* dateLabel= [self.view viewWithTag:103];
        dateLabel.text=existingAudioDate;
    
        [[self.view viewWithTag:504] setHidden:YES];
        
       
    
        recordingPausedOrStoped=YES;
    //    [UIApplication sharedApplication].idleTimerDisabled = NO;


    
//        UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x+30, recordingStatusLabel.frame.origin.y+recordingStatusLabel.frame.size.height+self.view.frame.size.height*0.08, self.view.frame.size.width-60, 30)];
        
        
        
        animatedImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"SoundWave-1"],
                                         [UIImage imageNamed:@"SoundWave-2"],
                                         [UIImage imageNamed:@"SoundWave-3"],
                                         nil];
       
        animatedImageView.animationDuration = 1.0f;
        animatedImageView.animationRepeatCount = 0;
        animatedImageView.image=[UIImage imageNamed:@"SoundWave-3"];

        animatedImageView.userInteractionEnabled=YES;
        
        
        double screenHeight =  [[UIScreen mainScreen] bounds].size.height;
        
        [self.view addSubview: animatedImageView];
        
        if (screenHeight<481)
        {
            UIImageView* animatedImageViewCopy;
            
           animatedImageViewCopy = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1, animatedImageView.frame.origin.y-50,  self.view.frame.size.width*0.85, 15)];
            
            animatedImageViewCopy.animationImages = [NSArray arrayWithObjects:
                                                 [UIImage imageNamed:@"SoundWave-1"],
                                                 [UIImage imageNamed:@"SoundWave-2"],
                                                 [UIImage imageNamed:@"SoundWave-3"],
                                                 nil];
            
            animatedImageViewCopy.animationDuration = 1.0f;
            animatedImageViewCopy.animationRepeatCount = 0;
            animatedImageViewCopy.image=[UIImage imageNamed:@"SoundWave-3"];
            
            animatedImageViewCopy.userInteractionEnabled=YES;
            animatedImageView.tag=0;

            animatedImageViewCopy.tag=1001;
            
            animatedImageViewCopy.backgroundColor = [UIColor redColor];
            [animatedImageView setHidden:YES];
            
            [self.view addSubview:animatedImageViewCopy];
        }
        else
        {
            animatedImageView.tag=1001;
        }

        //    [self performSelector:@selector(audioRecord) withObject:nil afterDelay:0.5];
        NSString* dictationTimeString= [[NSUserDefaults standardUserDefaults] valueForKey:SAVE_DICTATION_WAITING_SETTING];
        NSArray* minutesAndValueArray= [dictationTimeString componentsSeparatedByString:@" "];
        if (minutesAndValueArray.count < 1)
        {
            return;
        }
        minutesValue= [[minutesAndValueArray objectAtIndex:0]intValue];
        
        
        UIImageView*  startRecordingImageView= [startRecordingView viewWithTag:403];
        
        startRecordingImageView.image=[UIImage imageNamed:@"PauseNew"];
        
        
        startRecordingImageView  = [startRecordingView viewWithTag:403];
        
        [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-18, 18, 36)];


    //    [UIApplication sharedApplication].idleTimerDisabled = NO;

        NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    
        [[NSUserDefaults standardUserDefaults] setObject:data1 forKey:SELECTED_DEPARTMENT_NAME_COPY];
        
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    NSError* error1;

    bsackUpAudioFileName=existingAudioFileName;
    
      [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@backup.wav",AUDIO_FILES_FOLDER_NAME,bsackUpAudioFileName]] error:&error1];
    NSString* backUpPath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@backup.wav",AUDIO_FILES_FOLDER_NAME,bsackUpAudioFileName]];
    
    
    [[NSFileManager defaultManager] copyItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,self.existingAudioFileName]] toPath:backUpPath error:&error1];

}
-(void)viewWillDisappear:(BOOL)animated
{
    if( [APIManager sharedManager].userSettingsClosed)
    {
        [APIManager sharedManager].userSettingsOpened=NO;
    }
    if (![APIManager sharedManager].userSettingsOpened)
    {
    UIView* startRecordingView= [self.view viewWithTag:303];
    UILabel* recordingStatusLabel=[self.view viewWithTag:99];
    recordingStatusLabel.text=@"Tap on recording to start recording your audio";
    startRecordingView.backgroundColor=[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1];
    UIImageView* startRecordingImageView= [startRecordingView viewWithTag:403];
    UIImageView* counterLabel= [startRecordingView viewWithTag:503];
    
    [startRecordingImageView setHidden:NO];
    [counterLabel setHidden:YES];
    
    UIView* stopRecordingCircleView = [self.view viewWithTag:301];
    UIView* pauseRecordingCircleView =  [self.view viewWithTag:302];
    
    UILabel* stopRecordingLabel=[self.view viewWithTag:601];
    UILabel* pauseRecordingLabel=[self.view viewWithTag:602];
    UILabel* recordingLabel=[self.view viewWithTag:603];
    
    [stopRecordingCircleView setHidden:NO];
    [pauseRecordingCircleView setHidden:NO];
    [stopRecordingLabel setHidden:NO];
    [pauseRecordingLabel setHidden:NO];
    [recordingLabel setHidden:NO];
    
    startRecordingImageView.image=[UIImage imageNamed:@"Record"];
    startRecordingImageView.frame=CGRectMake((startRecordingView.frame.size.width/2)-15, (startRecordingView.frame.size.height/2)-25, 30, 50);
    
    UIView* animatedView=  [self.view viewWithTag:98];
    [animatedView removeFromSuperview];
    [player stop];
  //  [UIApplication sharedApplication].idleTimerDisabled = NO;
    [stopTimer invalidate];
    }
    
    
}


#pragma mark: DismissPopUpTableView
-(void)disMissPopView:(id)sender
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:504] removeFromSuperview];
    
}
#pragma mark: DismissTransparentView
-(void)dismissPopView:(id)sender
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    
}
//addCircleViews
#pragma mark: Add custom CircleViews

-(void)addView:(UIView*)sender
{
    if (sender.tag==203)//Greater width for middle circle
    {
        double screenHeight =  [[UIScreen mainScreen] bounds].size.height;
        
        if (screenHeight==480)
        {
            [self setRoundedView:sender toDiameter:sender.frame.size.width];
            
        }
        else
        [self setRoundedView:sender toDiameter:sender.frame.size.width+20];
    }
    else
        [self setRoundedView:sender toDiameter:sender.frame.size.width];
}

-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
{
    circleView=[[UIView alloc]init];
   // NSLog(@"%f",self.view.frame.size.width);
   // NSLog(@"%f",roundedView.frame.origin.x);;
    
    CGRect newFrame;
    if (roundedView.tag==203)
    {
        double screenHeight =  [[UIScreen mainScreen] bounds].size.height;
        
        if (screenHeight==480)
        {
            newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y-10, newSize, newSize);
            
        }
        else
        newFrame = CGRectMake(roundedView.frame.origin.x-10, roundedView.frame.origin.y-10, newSize, newSize);
        
    }
    else
        newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    
    circleView.frame = newFrame;
    circleView.layer.cornerRadius = newSize / 2.0;
    circleView.tag=roundedView.tag+100;
    
    UIButton* viewClickbutton=[[UIButton alloc]init];
    viewClickbutton.frame=CGRectMake(0, 0, newSize, newSize);//button:subview of view hence 0,0
    
    UIImageView* startStopPauseImageview=[[UIImageView alloc]init];
    
    //--------set Images within the circle,add respective viewClickbutton targets-------//
    
//    if (roundedView.tag==201)
//    {
//        startStopPauseImageview.image=[UIImage imageNamed:@"Stop"];
//        startStopPauseImageview.frame=CGRectMake((circleView.frame.size.width/2)-15, (circleView.frame.size.height/2)-8, 15, 15);
//        
//        circleView.backgroundColor=[UIColor grayColor];
//        
//        [viewClickbutton addTarget:self action:@selector(setStopRecordingView:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    if (roundedView.tag==202)
//    {
//        startStopPauseImageview.image=[UIImage imageNamed:@"Play"];
//        startStopPauseImageview.frame=CGRectMake((newSize/2), (newSize/2)-8, 15, 15);
//        startStopPauseImageview.tag=roundedView.tag+200;
//        
//        circleView.backgroundColor=[UIColor grayColor];
//        [viewClickbutton addTarget:self action:@selector(setPauseRecordingView:) forControlEvents:UIControlEventTouchUpInside];
//        
//    }
    
    if (roundedView.tag==203)
    {
       // startStopPauseImageview.image=[UIImage imageNamed:@"Record"];
//       [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-15, (startRecordingView.frame.size.height/2)-16, 30, 32)];
        startStopPauseImageview.frame=CGRectMake((circleView.frame.size.width/2)-15, (circleView.frame.size.height/2)-16, 30, 32);
        startStopPauseImageview.tag=roundedView.tag+200;
        startStopPauseImageview.image=[UIImage imageNamed:@"ResumeNew"];
        circleView.layer.borderColor = [UIColor whiteColor].CGColor;
        circleView.layer.borderWidth = 3.0f;
        circleView.backgroundColor=[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1];
        //audioDurationLAbel.frame=CGRectMake(circleView.frame.size.width/2-50, circleView.frame.size.height/2-10, 100, 20);
        
        audioDurationLAbel= [self.view viewWithTag:104];
        
       // [audioDurationLAbel setHidden:YES];
        

        audioDurationLAbel.textAlignment=NSTextAlignmentCenter;
        //audioDurationLAbel.font=[UIFont systemFontOfSize:20];
        //audioDurationLAbel.textColor=[UIColor whiteColor];
        //[circleView addSubview:audioDurationLAbel];
        [viewClickbutton addTarget:self action:@selector(setStartRecordingView:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    //----------------------------------//
    
    [circleView addSubview:viewClickbutton];
    [circleView addSubview:startStopPauseImageview];
    [self.view addSubview:circleView];
}
-(void)setTimer
{
    stopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(updateTimer)
                                               userInfo:nil
                                                repeats:YES];
}

-(void)updateTimer
{
    ++dictationTimerSeconds;
    
    // minutesValue=1;
    if (dictationTimerSeconds==60*minutesValue)
    {
        recordingPausedOrStoped=YES;
        UIImageView* animatedView= [self.view viewWithTag:1001];
//        double screenHeight =  [[UIScreen mainScreen] bounds].size.height;
//        
//        if (screenHeight<481)
//        {
//
        UILabel* recordOrPauseLabel = [self.view viewWithTag:603];
        
        recordOrPauseLabel.text = @"Resume";
//        }
        [animatedView stopAnimating];
        animatedView.image=[UIImage imageNamed:@"SoundWave-3"];

        [self pauseRecording];
     //   [UIApplication sharedApplication].idleTimerDisabled = NO;
        
    }
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    ++timerSeconds;
    if (timerSeconds==60)
    {
        timerSeconds=0;
        ++timerMinutes;
    }
    
    if (timerMinutes==60)
    {
        timerSeconds=0;
        timerMinutes=0;
        ++timerHour;
    }
    
   

    audioDurationLAbel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",timerHour,timerMinutes,timerSeconds];
    

    if(![self.view viewWithTag:701].hidden && recorder.isRecording)
    {
        [[self.view viewWithTag:701] setHidden:YES];
        [[self.view viewWithTag:702] setHidden:YES];
    }

}

-(void)setStopRecordingView:(UIButton*)sender
{
   
//   [self addAnimatedView];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:CONFIRM_BEFORE_SAVING_SETTING])
    {
       // [self performSelectorOnMainThread:@selector(showHud) withObject:nil waitUntilDone:YES];
        UIImageView* animatedImageView=[self.view viewWithTag:1001];
        
        [animatedImageView stopAnimating];
        animatedImageView.image=[UIImage imageNamed:@"SoundWave-3"];
        
        UILabel* RecordingLabel = [self.view viewWithTag:603];
        
        [RecordingLabel removeFromSuperview];
        
        [stopNewImageView removeFromSuperview];
        
        [stopNewButton removeFromSuperview];
        
        [stopLabel removeFromSuperview];
        
        [[self.view viewWithTag:99] removeFromSuperview]; //remove recording status label
        
        [animatedImageView removeFromSuperview];


        hud.minSize = CGSizeMake(150.f, 100.f);
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Saving audio..";
        hud.detailsLabel.text = @"Please wait";
        [self stopRecordingViewSettingSupport];
    }
    else
    {
        alertController = [UIAlertController alertControllerWithTitle:@""
                                                              message:@"Do you want to stop recording?"
                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
                            [animatedImageView stopAnimating];
                            animatedImageView.image=[UIImage imageNamed:@"SoundWave-3"];
                            
                            UILabel* RecordingLabel = [self.view viewWithTag:603];
                            
                            [RecordingLabel removeFromSuperview];
                            
                            [stopNewImageView removeFromSuperview];
                            
                            [stopNewButton removeFromSuperview];
                            
                            [stopLabel removeFromSuperview];
                            
                            [[self.view viewWithTag:99] removeFromSuperview]; //remove recording status label
                            
                            [animatedImageView removeFromSuperview];

                            hud.minSize = CGSizeMake(150.f, 100.f);
                            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                            hud.mode = MBProgressHUDModeIndeterminate;
                            hud.label.text = @"Saving audio..";
                            hud.detailsLabel.text = @"Please wait";
                            [self stopRecordingViewSettingSupport];
                            
                        }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionDelete];
        
        
        actionCancel = [UIAlertAction actionWithTitle:@"No"
                                                style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction * action)
                        {
                            [alertController dismissViewControllerAnimated:YES completion:nil];
                            
                        }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionCancel];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }

    
}

-(void)stopRecordingViewSettingSupport
{
    UIView* stopRecordingView = [self.view viewWithTag:301];
    UIView* pauseRecordingView =  [self.view viewWithTag:302];
    
    [[self.view viewWithTag:701] setHidden:NO];
    [[self.view viewWithTag:702] setHidden:NO];
    
    UIView* startRecordingView =  [self.view viewWithTag:303];
    
    [stopRecordingView setHidden:YES];
    [pauseRecordingView setHidden:YES];
    
    
    
    //        UILabel* recordingStatusLabel= [self.view viewWithTag:99];
    UILabel* stopRecordingLabel=[self.view viewWithTag:601];
    UILabel* pauseRecordingLabel=[self.view viewWithTag:602];
    UILabel* RecordingLabel=[self.view viewWithTag:603];
    
    
    recordingPausedOrStoped=YES;
    
    [stopRecordingView setHidden:YES];
    [pauseRecordingView setHidden:YES];
    [stopRecordingLabel setHidden:YES];
    [pauseRecordingLabel setHidden:YES];
    [RecordingLabel setHidden:YES];
    
    startRecordingView.backgroundColor=[UIColor blackColor];
    UIImageView* startRecordingImageView= [startRecordingView viewWithTag:403];
    [startRecordingImageView setHidden:NO];
    [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-9, 18, 18)];
    startRecordingImageView.image=[UIImage imageNamed:@"Play"];
    
    

    [self stopRecording];
    
    double screenHeight =  [[UIScreen mainScreen] bounds].size.height;
    
    if (screenHeight<481)
    {
        
        circleView.frame = CGRectMake(circleView.frame.origin.x, circleView.frame.origin.y-20, circleView.frame.size.width, circleView.frame.size.height);
    }

    recordingStopped=YES;
    
    if (!recordingPauseAndExit)
    {

        [self performSelector:@selector(composeAudio) withObject:nil afterDelay:0.0];

        //[self composeAudio];
        [self prepareAudioPlayer];
    }
    else
    {

        [self performSelector:@selector(setCompressAudio) withObject:nil afterDelay:0.0];

       // [self setCompressAudio];

    }
    
    [self updateAudioRecordToDatabase];

   // [self performSelector:@selector(addAnimatedView) withObject:nil afterDelay:0.0];
    [self addAnimatedView];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:BACK_TO_HOME_AFTER_DICTATION])
    {
        //[[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }


}
-(void)setPauseRecordingView:(UIButton*)sender
{
    UIView* pauseView=  [self.view viewWithTag:302];
    UIImageView* pauseImageView= [pauseView viewWithTag:402];
    if ( [pauseImageView.image isEqual:[UIImage imageNamed:@"Pause"]])
    {
        UIImageView* animatedView= [self.view viewWithTag:1001];
        [animatedView stopAnimating];
        animatedView.image=[UIImage imageNamed:@"SoundWave-3"];

        hud.minSize = CGSizeMake(150.f, 100.f);
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Saving audio..";
        hud.detailsLabel.text = @"Please wait";
        
        
        [self pauseRecording];
        //[self pauseRecording];
        recordingPausedOrStoped=YES;
        [stopTimer invalidate];
        pauseImageView.image=[UIImage imageNamed:@"Play"];
    }         
    else
    {
        recordingPauseAndExit=NO;
        recordingPausedOrStoped=NO;
        UIImageView* animatedView= [self.view viewWithTag:1001];
        [animatedView startAnimating];

        [self audioRecord];
        [stopTimer invalidate];
        [self setTimer];
        [self startRecorderAfterPrepareed];
        [UIApplication sharedApplication].idleTimerDisabled = YES;

        //[self performSelector:@selector(startRecorderAfterPrepareed) withObject:nil afterDelay:0.3];
        //[self performSelectorOnMainThread:@selector(startRecorderAfterPrepareed) withObject:nil waitUntilDone:YES];

        pauseImageView.image=[UIImage imageNamed:@"Pause"];
    }
    
    // pauseImageView.image=[UIImage imageNamed:@"play"];
}
-(void)setStartRecordingView:(UIButton*)sender
{
    
    UIView* startRecordingView= [self.view viewWithTag:303];
    
    
    
    if ([startRecordingView.backgroundColor isEqual:[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1]] || [startRecordingView.backgroundColor isEqual:[UIColor blackColor]])
    {
//------------------------------to hide th preious labels--------------------------------------------------//

        
        
//------------------------------to hide th preious labels--------------------------------------------------//

        if ([startRecordingView.backgroundColor isEqual:[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1]])
        {
            
           
//                UIImageView* animatedImageView= [self.view viewWithTag:1001];
//                [animatedImageView stopAnimating];
//                animatedImageView.image=[UIImage imageNamed:@"SoundWave-3"];
//                hud.minSize = CGSizeMake(150.f, 100.f);
//                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                hud.mode = MBProgressHUDModeIndeterminate;
//                hud.label.text = @"Saving audio..";
//                hud.detailsLabel.text = @"Please wait";
//                //[self performSelector:@selector(showHud) withObject:nil afterDelay:0.0];
//                //[self performSelector:@selector(showHud) withObject:nil afterDelay:0.0];
//
//                [self startRecordingViewSettingSupport];
                
            UIImageView* startRecordingImageView;
            
            startRecordingImageView  = [startRecordingView viewWithTag:403];
                
                if ( [startRecordingImageView.image isEqual:[UIImage imageNamed:@"PauseNew"]])
                {
                    UIImageView* animatedView= [self.view viewWithTag:1001];
                    [animatedView stopAnimating];
                    animatedView.image=[UIImage imageNamed:@"SoundWave-3"];
                    
                    hud.minSize = CGSizeMake(150.f, 100.f);
                    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeIndeterminate;
                    hud.label.text = @"Saving audio..";
                    hud.detailsLabel.text = @"Please wait";
                    
                    
                    [self pauseRecording];
                    
                    UILabel* recordOrPauseLabel = [self.view viewWithTag:603];
                    
                    recordOrPauseLabel.text = @"Resume";
                    //[self pauseRecording];
                    recordingPausedOrStoped=YES;
                    [stopTimer invalidate];
                    startRecordingImageView.image=[UIImage imageNamed:@"ResumeNew"];
                    
                     [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-15, (startRecordingView.frame.size.height/2)-16, 30, 32)];
                }
                else
                {
                    recordingPauseAndExit=NO;
                    recordingPausedOrStoped=NO;
                    UIImageView* animatedView= [self.view viewWithTag:1001];
                    [animatedView startAnimating];
                    
                    [self audioRecord];
                    [stopTimer invalidate];
                    
                    UILabel* recordOrPauseLabel = [self.view viewWithTag:603];
                    
                    recordOrPauseLabel.text = @"Pause";
                    
                    [self setTimer];
                    [self startRecorderAfterPrepareed];
                    [UIApplication sharedApplication].idleTimerDisabled = YES;
                    
                    //[self performSelector:@selector(startRecorderAfterPrepareed) withObject:nil afterDelay:0.3];
                    //[self performSelectorOnMainThread:@selector(startRecorderAfterPrepareed) withObject:nil waitUntilDone:YES];
                     [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-18, 18, 36)];
                    
                    startRecordingImageView.image=[UIImage imageNamed:@"PauseNew"];
                }
                

                 
               
                
            
        }
//------------------------------if circle bg color is back then setting to play the recording--------------------------------------------------//
    else
    {
        startRecordingView.backgroundColor=[UIColor blackColor];
        UIImageView* startRecordingImageView= [startRecordingView viewWithTag:403];
        [startRecordingImageView setHidden:NO];
        [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-9, 18, 18)];
        
//--------------------------------if image is play then play recording--------------------------------//
        
        if ([startRecordingImageView.image isEqual:[UIImage imageNamed:@"Play"]])
        {
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSliderTime:) userInfo:nil repeats:YES];
            [self prepareAudioPlayer];
            [self playRecording];
            
            startRecordingImageView.image=[UIImage imageNamed:@"Pause"];
            
        }
        
//--------------------------------if image is play then play recording--------------------------------//
        
//--------------------------------if image is pause then pause recording--------------------------------//
        else
        {
            [player pause];
            startRecordingImageView.image=[UIImage imageNamed:@"Play"];
        }
//--------------------------------if image is pause then pause recording--------------------------------//
        
       
    }
//------------------------------if circle bg color is back then setting to play the recording--------------------------------------------------//

        
        
}
    
}

-(void)startRecordingViewSettingSupport
{
    UIView* startRecordingView= [self.view viewWithTag:303];
    UIView* stopRecordingView = [self.view viewWithTag:301];
    UIView* pauseRecordingView =  [self.view viewWithTag:302];
    UILabel* stopRecordingLabel=[self.view viewWithTag:601];
    UILabel* pauseRecordingLabel=[self.view viewWithTag:602];
    UILabel* RecordingLabel=[self.view viewWithTag:603];
    UIImageView* startRecordingImageView;
    [stopRecordingView setHidden:YES];
    [pauseRecordingView setHidden:YES];
    [stopRecordingLabel setHidden:YES];
    [pauseRecordingLabel setHidden:YES];
    [RecordingLabel setHidden:YES];
    [[self.view viewWithTag:701] setHidden:NO];
    [[self.view viewWithTag:702] setHidden:NO];
    //------------------------------to stop the recording--------------------------------------------------//
//    UIImageView* animatedImageView= [self.view viewWithTag:1001];
//    [animatedImageView stopAnimating];
//    animatedImageView.image=[UIImage imageNamed:@"SoundWave-3"];
    
    [audioDurationLAbel removeFromSuperview];
    [self stopRecording];
    recordingPausedOrStoped=YES;
    recordingStopped=YES;
    
    //------------------------------to stop the recording--------------------------------------------------//
    
    //------------------------------to save(compose) and compressed the recording if it is not paused and saved--------------------------------------------------//
    
    if (!recordingPauseAndExit)
    {

        [self performSelector:@selector(composeAudio) withObject:nil afterDelay:0.0];
       
    }
    else
    {

        [self performSelector:@selector(setCompressAudio) withObject:nil afterDelay:0.0];

    }
    
    
    //------------------------------to save(compose) and compressed the recording if it is not paused and saved--------------------------------------------------//
    
    
    //------------------------------for alert badge count--------------------------------------------------//
    
    int count= [db getCountOfTransfersOfDicatationStatus:@"RecordingPause"];
    
    [[Database shareddatabase] getlistOfimportedFilesAudioDetailsArray:5];//get count of imported non transferred files
    
    int importedFileCount=[AppPreferences sharedAppPreferences].importedFilesAudioDetailsArray.count;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",count+importedFileCount] forKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    
    NSString* alertCount=[[NSUserDefaults standardUserDefaults] valueForKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    
    UIViewController *alertViewController = [self.tabBarController.viewControllers objectAtIndex:3];
    
    if ([alertCount isEqualToString:@"0"])
    {
        alertViewController.tabBarItem.badgeValue =nil;
    }
    else
        alertViewController.tabBarItem.badgeValue = [[NSUserDefaults standardUserDefaults] valueForKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    
    //------------------------------for alert badge count--------------------------------------------------//
    
    //------------------------------for animated view show and to set player timing--------------------------------------------------//
    startRecordingView.backgroundColor=[UIColor blackColor];
    startRecordingImageView= [startRecordingView viewWithTag:403];
    [startRecordingImageView setHidden:NO];
    [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-9, 18, 18)];
    startRecordingImageView.image=[UIImage imageNamed:@"Play"];
    
    [self prepareAudioPlayer];
    audioRecordSlider.maximumValue = player.duration;
    
    if (![[self.view viewWithTag:98] isDescendantOfView:self.view])
    {
        
//        [self performSelector:@selector(addAnimatedView) withObject:nil afterDelay:0.0];
        [self addAnimatedView];
    }
    //------------------------------for animated view show and to set player timing--------------------------------------------------//
    
    
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:BACK_TO_HOME_AFTER_DICTATION])
    {
        //[[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }


}
-(void)addAnimatedView
{
    [self prepareAudioPlayer];
    UIView* animatedView=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2)];
    animatedView.tag=98;
    
    audioRecordSlider=[[UISlider alloc]initWithFrame:CGRectMake(animatedView.frame.size.width*0.14,animatedView.frame.size.height*0.01 , animatedView.frame.size.width*0.7, 30)];
    [audioRecordSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    //audioRecordSlider.minimumValue = 0.0;
    audioRecordSlider.tag=197;
    audioRecordSlider.userInteractionEnabled=NO;
    UIButton* uploadAudioButton=[[UIButton alloc]initWithFrame:CGRectMake(animatedView.frame.size.width*0.1, animatedView.frame.size.height*0.2, animatedView.frame.size.width*0.8, 36)];
    uploadAudioButton.backgroundColor=[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1];
    uploadAudioButton.userInteractionEnabled=YES;
    [uploadAudioButton setTitle:@"Upload Recording" forState:UIControlStateNormal];
    uploadAudioButton.titleLabel.font = [UIFont systemFontOfSize: 15];
    uploadAudioButton.tag=198;
    uploadAudioButton.userInteractionEnabled=NO;
    
    [uploadAudioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    uploadAudioButton.layer.cornerRadius=5.0f;
    [uploadAudioButton addTarget:self action:@selector(uploadAudio:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton* uploadLaterButton=[[UIButton alloc]initWithFrame:CGRectMake(animatedView.frame.size.width*0.1, uploadAudioButton.frame.origin.y+uploadAudioButton.frame.size.height+10, uploadAudioButton.frame.size.width*0.48, 36)];
    uploadLaterButton.backgroundColor=[UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
    [uploadLaterButton setTitle:@"Upload Later" forState:UIControlStateNormal];
    uploadLaterButton.titleLabel.font = [UIFont systemFontOfSize: 15];
    [uploadLaterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    uploadLaterButton.layer.cornerRadius=5.0f;
    [uploadLaterButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    uploadLaterButton.tag=199;
    uploadLaterButton.userInteractionEnabled=NO;
    
    UIButton* recordNewButton=[[UIButton alloc]initWithFrame:CGRectMake(uploadLaterButton.frame.origin.x+uploadLaterButton.frame.size.width+uploadAudioButton.frame.size.width*0.04, uploadAudioButton.frame.origin.y+uploadAudioButton.frame.size.height+10, uploadAudioButton.frame.size.width*0.48, 36)];
    recordNewButton.backgroundColor=[UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
    [recordNewButton setTitle:@"Record New" forState:UIControlStateNormal];
    recordNewButton.titleLabel.font = [UIFont systemFontOfSize: 15];
    [recordNewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    recordNewButton.layer.cornerRadius=5.0f;
    [recordNewButton addTarget:self action:@selector(presentRecordView) forControlEvents:UIControlEventTouchUpInside];
    recordNewButton.tag=196;
    recordNewButton.userInteractionEnabled=NO;
    
    [self prepareAudioPlayer];
    audioRecordSlider.continuous = YES;
    audioRecordSlider.maximumValue=player.duration;
    int currentTime=player.duration;
    int minutes=currentTime/60;
    int seconds=currentTime%60;


    currentDuration=[[UILabel alloc]initWithFrame:CGRectMake(uploadAudioButton.frame.origin.x, animatedView.frame.size.height*0.1, 80, 20)];
    totalDuration=[[UILabel alloc]initWithFrame:CGRectMake(uploadAudioButton.frame.origin.x+uploadAudioButton.frame.size.width-80, animatedView.frame.size.height*0.1, 80, 20)];
    currentDuration.textAlignment=NSTextAlignmentLeft;
    totalDuration.textAlignment=NSTextAlignmentRight;

    totalDuration.text=[NSString stringWithFormat:@"%02d:%02d",minutes,seconds];//for slider label time label
    currentDuration.text=[NSString stringWithFormat:@"00:00"];//for slider label time label
    
    if (minutes>99)//foe more than 99 min show time in 3 digits
    {
        currentDuration.text=[NSString stringWithFormat:@"%03d:%02d",minutes,seconds];//for slider label time label
        
    }
    [animatedView addSubview:audioRecordSlider];
    [animatedView addSubview:uploadAudioButton];
    [animatedView addSubview:uploadLaterButton];
    [animatedView addSubview:recordNewButton];
    [animatedView addSubview:currentDuration];
    [animatedView addSubview:totalDuration];
    
    animatedView.backgroundColor=[UIColor whiteColor];
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         animatedView.frame = CGRectMake(0, self.view.frame.size.height*0.6, self.view.frame.size.width, self.view.frame.size.height/2);
                     }
                     completion:^(BOOL finished){
                     }];
    [self.view addSubview:animatedView];
   // [self hideHud1];
   // [self performSelector:@selector(hideHud) withObject:nil afterDelay:1.0];
    //[self performSelectorOnMainThread:@selector(hideHud1) withObject:nil waitUntilDone:NO];

}

-(void)dismissView
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)presentRecordView
{
   // recordingNew=YES;
    [AppPreferences sharedAppPreferences].selectedTabBarIndex=3;
    [AppPreferences sharedAppPreferences].recordNew=YES;
    [self dismissViewControllerAnimated:NO completion:nil];

   // [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"] animated:YES completion:nil];

}
#pragma mark:AudioSlider actions

-(void)sliderValueChanged
{
    player.currentTime = audioRecordSlider.value;
    
}

-(void)updateSliderTime:(UISlider*)sender
{
    audioRecordSlider.value = player.currentTime;
    int currentTime=player.currentTime;
    int minutes=currentTime/60;
    int seconds=currentTime%60;
    currentDuration.text=[NSString stringWithFormat:@"%02d:%02d",minutes,seconds];//for slider label time label

    if (minutes>99)//foe more than 99 min show time in 3 digits
    {
        currentDuration.text=[NSString stringWithFormat:@"%03d:%02d",minutes,seconds];//for slider label time label
        
    }

}


#pragma mark:Navigation bar items actions

- (IBAction)deleteButtonPressed:(id)sender
{
    
    
    alertController = [UIAlertController alertControllerWithTitle:@"Delete?"
                                                          message:DELETE_MESSAGE
                                                   preferredStyle:UIAlertControllerStyleAlert];
    actionDelete = [UIAlertAction actionWithTitle:@"Delete"
                                            style:UIAlertActionStyleDestructive
                                          handler:^(UIAlertAction * action)
                    {
                        //APIManager* app=[APIManager sharedManager];
                        NSString* dateAndTimeString=[app getDateAndTimeString];
                        [db updateAudioFileStatus:@"RecordingDelete" fileName:existingAudioFileName dateAndTime:dateAndTimeString];
                        [app deleteFile:[NSString stringWithFormat:@"%@backup",existingAudioFileName]];

                        BOOL deleted1= [app deleteFile:existingAudioFileName];

                        if (deleted1)
                        {
                            //[[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];//for recordtabarControlr ref to dismiss current view
                            [self dismissViewControllerAnimated:YES completion:nil];
                            
                        }
                        
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionDelete];
    
    
    actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * action)
                    {
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                        
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (IBAction)backButtonPressed:(id)sender
{
    if (!recordingPausedOrStoped)
    {
        alertController = [UIAlertController alertControllerWithTitle:PAUSE_STOP_MESSAGE
                                                              message:@""
                                                       preferredStyle:UIAlertControllerStyleAlert];
        actionDelete = [UIAlertAction actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
                            [alertController dismissViewControllerAnimated:YES completion:nil];
                            
                        }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionDelete];
        
        
        [self presentViewController:alertController animated:YES completion:nil];

    }
    else
    if (recordingPauseAndExit)
    {
        NSError* error1;
         [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@copy.wav",AUDIO_FILES_FOLDER_NAME,self.recordedAudioFileName]] error:&error1];
                [self performSelector:@selector(disMis) withObject:nil afterDelay:0.5];

        //[self saveAudioRecordToDatabase];
    }
    else
    {
        NSError* error1;
        [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@copy.wav",AUDIO_FILES_FOLDER_NAME,self.recordedAudioFileName]] error:&error1];
        [self disMis];
    }
}
-(void)disMis
{
    [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismis"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)moreButtonPressed:(id)sender
{
    
    if ([[self.view viewWithTag:98] isDescendantOfView:self.view])
    {
        NSArray* subViewArray=[NSArray arrayWithObjects:@"User Settings", nil];
        editPopUp=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-170, self.view.frame.origin.y+20, 160, 40) andSubViews:subViewArray :self];
        [[[UIApplication sharedApplication] keyWindow] addSubview:editPopUp];
    }
    else
    {
        NSArray* subViewArray=[NSArray arrayWithObjects:@"Edit Department", nil];
        editPopUp=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-170, self.view.frame.origin.y+20, 160, 40) andSubViews:subViewArray :self];
        // editPopUp.tag=888;
        [[[UIApplication sharedApplication] keyWindow] addSubview:editPopUp];
    }

    
}
-(void)UserSettings
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    [APIManager sharedManager].userSettingsOpened=YES;
    [APIManager sharedManager].userSettingsClosed=NO;
    [self presentViewController:[self.storyboard  instantiateViewControllerWithIdentifier:@"UserSettingsViewController"] animated:YES completion:nil];
}

-(void)uploadAudio:(UIButton*)sender
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
    alertController = [UIAlertController alertControllerWithTitle:TRANSFER_MESSAGE
                                                          message:@""
                                                   preferredStyle:UIAlertControllerStyleAlert];
    actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        
                        //                        NSDictionary* audiorecordDict= [app.awaitingFileTransferNamesArray objectAtIndex:self.selectedRow];
                        //                        NSString* filName=[audiorecordDict valueForKey:@"RecordItemName"];
                        //                        [transferDictationButton setHidden:YES];
                        //                        [deleteDictationButton setHidden:YES];
                        [[self.view viewWithTag:701] setHidden:YES];
                        [[self.view viewWithTag:702] setHidden:YES];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                          //Database* db=  [Database shareddatabase];
                            [db updateAudioFileStatus:@"RecordingFileUpload" fileName:self.existingAudioFileName];
                                                        [app uploadFileToServer:self.existingAudioFileName];
                            sender.userInteractionEnabled=NO;
                            deleteButton.userInteractionEnabled=NO;
                           // [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
                            
                            [self dismissViewControllerAnimated:YES completion:nil];
                            
                            
                        });
                        
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionDelete];
    
    
    actionCancel = [UIAlertAction actionWithTitle:@"No"
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * action)
                    {
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                        
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}
else
{
    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
}


}

-(void)EditDepartment
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    CGRect frame=CGRectMake(10.0f, self.view.center.y-150, self.view.frame.size.width - 20.0f, 200.0f);
    UITableView* tab= [obj tableView:self frame:frame];
    [popupView addSubview:tab];
    //[popupView addGestureRecognizer:tap];
    [popupView setFrame:[[UIScreen mainScreen] bounds]];
    //[popupView addSubview:[self.view viewWithTag:504]];
    UIView *buttonsBkView = [[UIView alloc] initWithFrame:CGRectMake(tab.frame.origin.x, tab.frame.origin.y + tab.frame.size.height, tab.frame.size.width, 70.0f)];
    buttonsBkView.backgroundColor = [UIColor whiteColor];
    [popupView addSubview:buttonsBkView];
    
    UIButton* cancelButton=[[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-200, 20.0f, 80, 30)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //[cancelButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* saveButton=[[UIButton alloc]initWithFrame:CGRectMake(cancelButton.frame.origin.x+cancelButton.frame.size.width+16, 20.0f, 80, 30)];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //[saveButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [saveButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonsBkView addSubview:cancelButton];
    [buttonsBkView addSubview:saveButton];
    
    
    popupView.tag=504;
    [popupView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:popupView];

    
}

#pragma mark:Gesture recogniser delegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (editPopUp.superview != nil)
    {
        if (![touch.view isEqual:editPopUp])
        {
            return NO;
        }
        
        return YES;
    }
    if (![touch.view isEqual:popupView])
    {
        return NO;
    }
    
    return YES; // handle the touch

}

#pragma mark:Audio recorder and player custom and delegtaes methods

-(void)audioRecord
{
//    [recorder recordForDuration:60];
    
    
   
        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
   
    
    NSString* filePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:AUDIO_FILES_FOLDER_NAME]];
    NSError* error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    
    NSArray* pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               AUDIO_FILES_FOLDER_NAME,
                               [NSString stringWithFormat:@"%@copy.wav",recordedAudioFileName],
                               nil];
    
    recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // settings for the recorder
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    // initiate recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:recordedAudioURL settings:recordSetting error:&error];
    [recorder prepareToRecord];
}
-(void)startRecorderAfterPrepareed
{
//    [stopTimer invalidate];
//    [self setTimer];

    [recorder record];
}
-(void)pauseRecording
{
    recordingPauseAndExit=YES;
    [recorder pause];
    [recorder stop];
    
    [stopTimer invalidate];
    
    UIView* startRecordingView= [self.view viewWithTag:303];
    
    UIImageView* startRecordingImageView;
    
    startRecordingImageView  = [startRecordingView viewWithTag:403];

     [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-15, (startRecordingView.frame.size.height/2)-16, 30, 32)];
    
    startRecordingImageView.image=[UIImage imageNamed:@"ResumeNew"];
    
   // [self setCompressAudio];
    
    // run audio file code in a background thread
// [  self performSelectorInBackground:(@selector(convertAudio)) withObject:nil];
    
    
    [self composeAudio];

    
    
}
-(void)setCompressAudio
{
    NSString* filePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:AUDIO_FILES_FOLDER_NAME]];
    NSString *source=[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",existingAudioFileName]];
    
    // NSString *source = [[NSBundle mainBundle] pathForResource:@"sourceALAC" ofType:@"caf"];
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    destinationFilePath= [[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:AUDIO_FILES_FOLDER_NAME]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@compressed.wav",existingAudioFileName]];
    //destinationFilePath = [[NSString alloc] initWithFormat: @"%@/output.caf", documentsDirectory];
    destinationURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)destinationFilePath, kCFURLPOSIXPathStyle, false);
    sourceURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)source, kCFURLPOSIXPathStyle, false);
    NSError* erro;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAudioProcessing error:&erro];
    
    if (erro)
    {
        printf("Setting the AVAudioSessionCategoryAudioProcessing Category failed! %ld\n", (long)erro.code);
        [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
        //[self performSelectorOnMainThread:@selector(hideHud1) withObject:nil waitUntilDone:NO];

        return;
    }
    
    
    
    // run audio file code in a background thread
   // [self performSelector:@selector(convertAudio) withObject:nil afterDelay:0.0f];
    //[self performSelectorOnMainThread:@selector(convertAudio) withObject:nil waitUntilDone:YES];
    [self convertAudio];
    
    
    
   
    
}

- (void)convertAudio
{
    //[self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
    //[self performSelectorOnMainThread:@selector(showHud) withObject:nil waitUntilDone:NO];

    outputFormat = kAudioFormatLinearPCM;
    sampleRate = 0;
    OSStatus error = DoConvertFile(sourceURL, destinationURL, outputFormat, sampleRate);
    NSError* error1;
    NSString* destinationPath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,self.existingAudioFileName]];
    NSString* sourcePath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@compressed.wav",AUDIO_FILES_FOLDER_NAME,existingAudioFileName]];
    if (error)
    {
        [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
       // [self performSelectorOnMainThread:@selector(hideHud1) withObject:nil waitUntilDone:NO];

                // delete output file if it exists since an error was returned during the conversion process
        if ([[NSFileManager defaultManager] fileExistsAtPath:destinationFilePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:destinationFilePath error:nil];
        }
       
         [[NSFileManager defaultManager] moveItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@copy.wav",AUDIO_FILES_FOLDER_NAME,self.recordedAudioFileName]] toPath:destinationPath error:&error1];
        printf("DoConvertFile failed! %d\n", (int)error);
    }
    else
    {
       // NSLog(@"Converted");
         [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@copy.wav",AUDIO_FILES_FOLDER_NAME,self.recordedAudioFileName]] error:&error1];
       
        [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:&error1];

       [[NSFileManager defaultManager] moveItemAtPath:sourcePath toPath:destinationPath error:&error1];
        [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@backup.wav",AUDIO_FILES_FOLDER_NAME,self.existingAudioFileName]] error:&error1];
        //[self prepareAudioPlayer];
               [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
       // [self performSelectorOnMainThread:@selector(hideHud1) withObject:nil waitUntilDone:NO];
//[self performSelectorOnMainThread:@selector(hideHud1) withObject:nil waitUntilDone:NO];

    }
    UIView* animatedViewCopy=[self.view viewWithTag:98];
    UIButton* slider=[animatedViewCopy viewWithTag:197];
    
    UIButton* uploadButton=[animatedViewCopy viewWithTag:198];
    UIButton* uploadLetter=[animatedViewCopy viewWithTag:199];
    UIButton* recordNew=[animatedViewCopy viewWithTag:196];

    uploadButton.userInteractionEnabled=YES;
    uploadLetter.userInteractionEnabled=YES;
    slider.userInteractionEnabled=YES;
    recordNew.userInteractionEnabled=YES;

}


-(void)stopRecording
{

    [audioDurationLAbel removeFromSuperview];
    [recorder stop];
    app=[APIManager sharedManager];
    [self updateAudioRecordToDatabase];
    app.awaitingFileTransferCount= [db getCountOfTransfersOfDicatationStatus:@"RecordingComplete"];
    int count= [db getCountOfTransfersOfDicatationStatus:@"RecordingPause"];
    
    [[Database shareddatabase] getlistOfimportedFilesAudioDetailsArray:5];//get count of imported non transferred files
    
    int importedFileCount=[AppPreferences sharedAppPreferences].importedFilesAudioDetailsArray.count;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",count+importedFileCount] forKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    
    NSString* alertCount=[[NSUserDefaults standardUserDefaults] valueForKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    
    UIViewController *alertViewController = [self.tabBarController.viewControllers objectAtIndex:3];
    
    if ([alertCount isEqualToString:@"0"])
    {
        alertViewController.tabBarItem.badgeValue =nil;
    }
    else
        alertViewController.tabBarItem.badgeValue = [[NSUserDefaults standardUserDefaults] valueForKey:INCOMPLETE_TRANSFER_COUNT_BADGE];//    UIViewController *alertViewController = [self.tabBarController.viewControllers objectAtIndex:3];
//    
//    alertViewController.tabBarItem.badgeValue = [[NSUserDefaults standardUserDefaults] valueForKey:INCOMPLETE_TRANSFER_COUNT_BADGE];



}

-(void)prepareAudioPlayer
{
    if (!IMPEDE_PLAYBACK)
    {
        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayback];
    }
    [recorder stop];
    NSError *audioError;
    
    NSArray* pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               AUDIO_FILES_FOLDER_NAME,
                               [NSString stringWithFormat:@"%@.wav", existingAudioFileName],
                               nil];
    
    playerAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:playerAudioURL error:&audioError];
    audioRecordSlider.maximumValue = player.duration;
    player.currentTime = audioRecordSlider.value;
    
    player.delegate = self;
    [player prepareToPlay];
    
}
-(void)playRecording
{
            circleViewTimerSeconds=0;
        circleViewTimerMinutes=0;
        
        int totalMinutes=  player.duration/60;
        int total=  player.duration;
        int totalSeconds= total%60;
        totalDuration.text=[NSString stringWithFormat:@"%02d:%02d",totalMinutes,totalSeconds];
    
    if (totalMinutes>99)//foe more than 99 min show time in 3 digits
    {
        currentDuration.text=[NSString stringWithFormat:@"%03d:%02d",totalMinutes,totalSeconds];//for slider label time label
        
    }

        [self setTimer];
        [player play];
   
}

//-(NSString*)getDateAndTimeString
//{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = DATE_TIME_FORMAT;
//    recordCreatedDateString = [formatter stringFromDate:[NSDate date]];
//    return recordCreatedDateString;
//}

-(void)updateAudioRecordToDatabase
{
       [db updateAudioFileName:existingAudioFileName dictationStatus:@"RecordingComplete"];
    //    if (recordingPauseAndExit)
    //    {
    // }
    
    
}

-(void)composeAudio
{
    NSError* error1;
    
//    bool moved=  [[NSFileManager defaultManager] moveItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,existingAudioFileName]] toPath:backUpPath error:&error1];
    bsackUpAudioFileName=existingAudioFileName;
    
// backup: if get killed while saving the record
    NSString* backUpPath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@backup.wav",AUDIO_FILES_FOLDER_NAME,bsackUpAudioFileName]];
     [[NSFileManager defaultManager] removeItemAtPath:backUpPath error:&error1];
    
     [[NSFileManager defaultManager] copyItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,self.existingAudioFileName]] toPath:backUpPath error:&error1];
  //
    AVMutableComposition* composition = [AVMutableComposition composition];
    AVMutableCompositionTrack* appendedAudioTrack =
    [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                             preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // Grab the two audio tracks that need to be appended
    NSArray* pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               AUDIO_FILES_FOLDER_NAME,
                               [NSString stringWithFormat:@"%@.wav", self.existingAudioFileName],
                               nil];
    
    NSURL* existingFileUrl = [NSURL fileURLWithPathComponents:pathComponents];
    
    AVURLAsset* originalAsset = [[AVURLAsset alloc]
                                 initWithURL:existingFileUrl options:nil];
    AVURLAsset* newAsset = [[AVURLAsset alloc]
                            initWithURL:recordedAudioURL options:nil];
    
    NSError* error = nil;
    
    // Grab the first audio track and insert it into our appendedAudioTrack
    NSArray *originalTrack = [originalAsset tracksWithMediaType:AVMediaTypeAudio];
    
    if (originalTrack.count <= 0)
    {
        [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];

        return;
    }
    
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, originalAsset.duration);
    [appendedAudioTrack insertTimeRange:timeRange
                                ofTrack:[originalTrack objectAtIndex:0]
                                 atTime:kCMTimeZero
                                  error:&error];
    if (error)
    {
        [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];

        return;
    }
    
    // Grab the second audio track and insert it at the end of the first one
    NSArray *newTrack = [newAsset tracksWithMediaType:AVMediaTypeAudio];
    
    if (newTrack.count <= 0)
    {
        [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
        [self setCompressAudio];
        return;
    }
    
    timeRange = CMTimeRangeMake(kCMTimeZero, newAsset.duration);
    [appendedAudioTrack insertTimeRange:timeRange
                                ofTrack:[newTrack objectAtIndex:0]
                                 atTime:originalAsset.duration
                                  error:&error];
    
    if (error)
    {
        // do something
        [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
        return;
    }
    
    // Create a new audio file using the appendedAudioTrack
    AVAssetExportSession* exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetPassthrough];
    if (!exportSession)
    {
        // do something
        [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];

        return;
    }
    
    
    
        NSString* destpath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,existingAudioFileName]];
        [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@co.wav",AUDIO_FILES_FOLDER_NAME,existingAudioFileName]] error:&error];
        exportSession.outputURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@co.wav",AUDIO_FILES_FOLDER_NAME,existingAudioFileName]]];//composed audio url,later on this will be deleted
   // export.outputFileType = AVFileTypeWAVE;

        exportSession.outputFileType = AVFileTypeWAVE;
//    AVFileTypeAppleM4A
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        // exported successfully?
        NSError* error;
        if (exportSession.status==AVAssetExportSessionStatusCompleted)
        {
            //first remove the existing file
            [[NSFileManager defaultManager] removeItemAtPath:destpath error:&error];
            //then move compossed file to existingAudioFile
             bool moved=  [[NSFileManager defaultManager] moveItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@co.wav",AUDIO_FILES_FOLDER_NAME,existingAudioFileName]] toPath:destpath error:&error];
        
            if (moved)
            {
                //remove the composed file copy
                [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@co.wav",AUDIO_FILES_FOLDER_NAME,existingAudioFileName]] error:&error];
                //remove the recorded audio
                [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,recordedAudioFileName]] error:&error];
                
                
                // backup: if get killed while saving the record
                NSString* backUpPath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@backup.wav",AUDIO_FILES_FOLDER_NAME,bsackUpAudioFileName]];
                
                // remove previous backup file if any
                [[NSFileManager defaultManager] removeItemAtPath:backUpPath error:&error];
                
                // keep compose file backup to backupPath
                 [[NSFileManager defaultManager] copyItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,self.existingAudioFileName]] toPath:backUpPath error:&error];
                

                [self prepareAudioPlayer];
                
                [db updateAudioFileName:existingAudioFileName duration:player.duration];
                if (!IMPEDE_PLAYBACK)
                {
                    [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryRecord];
                }

                if (recordingStopped)
                {
                    //[self performSelector:@selector(setCompressAudio) withObject:nil afterDelay:0.0];
                   // [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
                   // [self performSelectorOnMainThread:@selector(showHud) withObject:nil waitUntilDone:NO];
                    //[self performSelector:@selector(setCompressAudio) withObject:nil afterDelay:0.0];
                    [self setCompressAudio];

                }
                else
                {
                    [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];

                }

            }
            
        }
            if (exportSession.status==AVAssetExportSessionStatusFailed)
            {
                [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
//                if (recordingStopped)
//                {
//                    [self setCompressAudio];
//                    //[self composeAudio];
//                }
            }
        switch (exportSession.status)
        {
            case AVAssetExportSessionStatusFailed:
                break;
            case AVAssetExportSessionStatusCompleted:

                // you should now have the appended audio file
                break;
            case AVAssetExportSessionStatusWaiting:
                break;
            default:
                break;
        }
        
    }];

    NSLog(@"%@",error.localizedDescription);
}
-(void)hideHud
{
    [hud hideAnimated:YES];

}
-(void)hideHud1
{
    [hud1 hideAnimated:YES];
    
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    UIView* startRecordingView= [self.view viewWithTag:303];
    UIImageView* startRecordingImageView= [startRecordingView viewWithTag:403];
    startRecordingImageView.image=[UIImage imageNamed:@"Play"];
    [[self player] stop];
}

#pragma mark:TableView Datasource and Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    departmentNamesArray=[db getDepartMentNames];
    return departmentNamesArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    cell = [tableview dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    UILabel* departmentLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 10, self.view.frame.size.width - 60.0f, 18)];
    UIButton* radioButton=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, 18, 18)];
    departmentLabel.text = [departmentNamesArray objectAtIndex:indexPath.row];
    departmentLabel.tag=indexPath.row+200;
    radioButton.tag=indexPath.row+100;
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //    DepartMent *deptObj=[[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    //    deptObj.Id=indexPath.row;
    //    deptObj.departmentName=departmentLabel.text;
    DepartMent *deptObj1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"%ld",deptObj1.Id);
    if ([deptObj.departmentName isEqualToString:departmentLabel.text])
    {
        //        DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        //        long deptId= [[[Database shareddatabase] getDepartMentIdFromDepartmentName:departmentLabel.text] longLongValue];
        //
        //        deptObj.Id=deptId;
        //        //deptObj.Id=indexPath.row;
        //        deptObj.departmentName=departmentLabel.text;
        //        NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:deptObj];
        //
        //        [[NSUserDefaults standardUserDefaults] setObject:data1 forKey:SELECTED_DEPARTMENT_NAME_COPY];
        [radioButton setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
        
    }
    else
        [radioButton setBackgroundImage:[UIImage imageNamed:@"RadioButtonClear"] forState:UIControlStateNormal];
    [cell addSubview:radioButton];
    [cell addSubview:departmentLabel];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //MainTabBarViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarViewController"];
    cell=[tableView cellForRowAtIndexPath:indexPath];
    UILabel* departmentNameLanel= [cell viewWithTag:indexPath.row+200];
    UIButton* radioButton=[cell viewWithTag:indexPath.row+100];
    //NSLog(@"%ld",indexPath.row);
    // NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    DepartMent *deptObj = [[DepartMent alloc]init];
    long deptId= [[[Database shareddatabase] getDepartMentIdFromDepartmentName:departmentNameLanel.text] longLongValue];
    
    deptObj.Id=deptId;
    //deptObj.Id=indexPath.row;
    deptObj.departmentName=departmentNameLanel.text;
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:deptObj];
    
    [[NSUserDefaults standardUserDefaults] setObject:data1 forKey:SELECTED_DEPARTMENT_NAME];
    
    
    //  [[NSUserDefaults standardUserDefaults] setValue:departmentNameLanel.text forKey:SELECTED_DEPARTMENT_NAME];
    [radioButton setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
    [tableView reloadData];
    //[self performSelector:@selector(hideTableView) withObject:nil afterDelay:0.2];
    
}
-(void)cancel:(id)sender
{
    //    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //    long deptId= [[[Database shareddatabase] getDepartMentIdFromDepartmentName:departmentLabel.text] longLongValue];
    //
    //    deptObj.Id=deptId;
    //    //deptObj.Id=indexPath.row;
    //    deptObj.departmentName=departmentLabel.text;
    //    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:deptObj];
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME_COPY];
    DepartMent *deptObj1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME];
    [popupView removeFromSuperview];
}

-(void)save:(id)sender
{
    
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:data1 forKey:SELECTED_DEPARTMENT_NAME_COPY];
    
    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    UILabel* transferredByLabel= [self.view viewWithTag:102];
    transferredByLabel.text=deptObj.departmentName;
    [[Database shareddatabase] updateDepartment:deptObj.Id fileName:self.existingAudioFileName];
    [popupView removeFromSuperview];
}



//-(void)hideTableView
//{
//    
//    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:504] removeFromSuperview];//
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)stopRecordingButtonClicked:(id)sender
{
    [self setStopRecordingView:sender];

}
@end
