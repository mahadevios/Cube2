//
//  RecordViewController.m
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
// tag view 200 series are of storyboard reference Views
// tag with 300 series are of programmatically created actual circle Views


// audio compression(DoConvert tuto) http://stackoverflow.com/questions/6576530/ios-how-to-use-extaudiofileconvert-sample-in-a-new-project

#import "RecordViewController.h"
#import "PopUpCustomView.h"
#import "DepartMent.h"

#define IMPEDE_PLAYBACK NO
extern OSStatus DoConvertFile(CFURLRef sourceURL, CFURLRef destinationURL, OSType outputFormat, Float64 outputSampleRate);


@interface RecordViewController ()

@end


@implementation RecordViewController

@synthesize player, recordedAudioFileName, recorder,recordedAudioURL,recordCreatedDateString,hud,deleteButton,stopNewButton,stopNewImageView,stopLabel,recordLAbel;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    app=[APIManager sharedManager];
    db=[Database shareddatabase];
    
    popupView=[[UIView alloc]init];
    
    forTableViewObj=[[PopUpCustomView alloc]init];
    
    tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disMissPopView:)];
    tap.delegate=self;
    
    cirecleTimerLAbel=[[UILabel alloc]init];
    
    [[self.view viewWithTag:701] setHidden:YES];
    [[self.view viewWithTag:702] setHidden:YES];
    
    maxRecordingTimeString= [[NSUserDefaults standardUserDefaults] valueForKey:SAVE_DICTATION_WAITING_SETTING];

    recordingPausedOrStoped=YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseRecordingFromBackGround) name:NOTIFICATION_PAUSE_RECORDING
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideDeleteButton) name:NOTIFICATION_FILE_UPLOAD_API
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveRecordin) name:NOTIFICATION_SAVE_RECORDING
                                               object:nil];
    if (!IMPEDE_PLAYBACK)
    {
        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
    }
    

}

-(void)pauseRecordingFromBackGround
{
    if (!stopped && !paused)
    {
        
        recordingPausedOrStoped=YES;
                
        UIImageView* animatedView= [self.view viewWithTag:1001];
        
        [animatedView stopAnimating];
        
        animatedView.image=[UIImage imageNamed:@"SoundWave-3"];
        
        [self performSelector:@selector(pauseRecording) withObject:nil afterDelay:0.3];
       // [self pauseRecording];
        
        
        UILabel* recordOrPauseLabel = [self.view viewWithTag:603];
        
        recordOrPauseLabel.text = @"Resume";
        
        
      
    
    }
    
}
-(void)hideDeleteButton
{
    if ([[self.view viewWithTag:98] isDescendantOfView:self.view])//if animated view added then dont hide delete button
    {
        [[self.view viewWithTag:701] setHidden:NO];
        [[self.view viewWithTag:702] setHidden:NO];
    }
    else
    {
        [[self.view viewWithTag:701] setHidden:YES];
        [[self.view viewWithTag:702] setHidden:YES];
    }
    
}
-(void)saveRecordin  //save recording if user kill the app while recording
{
    if ([AppPreferences sharedAppPreferences].isRecordView)
    {
   
        if (!stopped)
        {
            NSLog(@"in save");
            
            [self saveAudioRecordToDatabase];

            NSString* destinationPath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,self.recordedAudioFileName]];
            
            NSError* error1;
            
            [[NSFileManager defaultManager] moveItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@copy.wav",AUDIO_FILES_FOLDER_NAME,self.recordedAudioFileName]] toPath:destinationPath error:&error1];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];

        }
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [AppPreferences sharedAppPreferences].isRecordView=YES;
    
    if (![APIManager sharedManager].userSettingsOpened)
    {
   
//        UIView* stopView= [self.view viewWithTag:201];
//        [self performSelector:@selector(addView:) withObject:stopView afterDelay:0.02];
//    
//        UIView* pauseView= [self.view viewWithTag:202];
//        [self performSelector:@selector(addView:) withObject:pauseView afterDelay:0.02];
    
        UIView* startRecordingView1= [self.view viewWithTag:203];
        [self performSelector:@selector(addView:) withObject:startRecordingView1 afterDelay:0.02];
    
        UIView* startRecordingView= [self.view viewWithTag:303];
        
        UIImageView* counterLabel= [startRecordingView viewWithTag:503];
        
        UILabel* fileNameLabel= [self.view viewWithTag:101];
        
        UILabel* transferredByLabel= [self.view viewWithTag:102];
        
        UILabel* dateLabel= [self.view viewWithTag:103];
        
        cirecleTimerLAbel= [self.view viewWithTag:104];

        [cirecleTimerLAbel setHidden:YES];
        
        [stopNewButton setHidden:YES];
        
        [stopNewImageView setHidden:YES];
        
        [stopLabel setHidden:YES];


       
        circleViewTimerMinutes=0;
        circleViewTimerSeconds=0;
        dictationTimerSeconds=0;
        recordingPauseAndExit = YES;
        
        //---set and show recording file name when view will appear---//
    
        NSDate *date = [[NSDate alloc] init];
        NSTimeInterval seconds = [date timeIntervalSinceReferenceDate];
        long milliseconds = seconds*1000;
        self.recordedAudioFileName = [NSString stringWithFormat:@"%ld", milliseconds];
    
        
        NSString* dateFileNameString=[app getDateAndTimeString];
        
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString* todaysDate = [dateFormatter stringFromDate:[NSDate new]];
        
        NSString* storedTodaysDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"TodaysDate"];
        

        if ([todaysDate isEqualToString:storedTodaysDate])
        {
            todaysSerialNumberCount = [[[NSUserDefaults standardUserDefaults] valueForKey:@"todaysSerialNumberCount"] longLongValue];
            todaysSerialNumberCount++;

        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setValue:todaysDate forKey:@"TodaysDate"];
            [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"todaysSerialNumberCount"];
            NSString* countString=[[NSUserDefaults standardUserDefaults] valueForKey:@"todaysSerialNumberCount"];
            todaysSerialNumberCount = [countString longLongValue];

            todaysSerialNumberCount++;

        }
        
        todaysDate=[todaysDate stringByReplacingOccurrencesOfString:@"-" withString:@""];

        
        
        NSString* fileNamePrefix;
        
        fileNamePrefix=[[NSUserDefaults standardUserDefaults] valueForKey:@"FileNamePrefix"];
        //fileNamePrefix = [[NSUserDefaults standardUserDefaults] valueForKey:@"fileNamePrefix"];

        self.recordedAudioFileName=[NSString stringWithFormat:@"%@%@-%02ld",fileNamePrefix,todaysDate,todaysSerialNumberCount];
        
        fileNameLabel.text=[NSString stringWithFormat:@"%@%@-%02ld",fileNamePrefix,todaysDate,todaysSerialNumberCount];
        
       // fileNameLabel.text=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] valueForKey:RECORD_ABBREVIATION],self.recordedAudioFileName];
        
       // self.recordedAudioFileName=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] valueForKey:RECORD_ABBREVIATION],self.recordedAudioFileName];
        //---
    
    
        self.navigationItem.title=@"Record";
    
       

        [counterLabel setHidden:NO];//hide time label when view appear
    
        [[self.view viewWithTag:504] setHidden:YES];

    
        
    
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
        DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        transferredByLabel.text=deptObj.departmentName;
    
        NSString* dateAndTimeString= [app getDateAndTimeString];
        NSArray* dateAndTimeArray= [dateAndTimeString componentsSeparatedByString:@" "];
        NSString* dateString=[dateAndTimeArray objectAtIndex:0];
        dateLabel.text=dateString;
    
    
    
        NSString* dictationTimeString= [[NSUserDefaults standardUserDefaults] valueForKey:SAVE_DICTATION_WAITING_SETTING];
        NSArray* minutesAndValueArray= [dictationTimeString componentsSeparatedByString:@" "];
        
        if (minutesAndValueArray.count < 1)
        {
            return;
        }

        minutesValue= [[minutesAndValueArray objectAtIndex:0]intValue];
        if (!IMPEDE_PLAYBACK)
        {
            [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryRecord];
        }
        //recordingNew=YES;
        stopped=YES;
    
        //
        NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    
        [[NSUserDefaults standardUserDefaults] setObject:data1 forKey:SELECTED_DEPARTMENT_NAME_COPY];
   
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    long freeDiskSpaceInMB= [[APIManager sharedManager] getFreeDiskspace];
    long storageThreshold = 0.0l;
    NSString* lowStorageThresholdString= [[NSUserDefaults standardUserDefaults] valueForKey:LOW_STORAGE_THRESHOLD];
   // NSString* lowStorageThresholdString= @"12 GB";

    if ([lowStorageThresholdString isEqualToString:@"512 MB"])
    {
        NSArray* thresholdArray= [lowStorageThresholdString componentsSeparatedByString:@" "];
        storageThreshold =[[thresholdArray objectAtIndex:0]longLongValue];
    }
    else
        if ([lowStorageThresholdString isEqualToString:@"1 GB"])
        {
            NSArray* thresholdArray= [lowStorageThresholdString componentsSeparatedByString:@" "];
            storageThreshold =[[thresholdArray objectAtIndex:0]longLongValue];
            storageThreshold=storageThreshold*1024ll;
        }
        else
            if ([lowStorageThresholdString isEqualToString:@"2 GB"])
            {
                NSArray* thresholdArray= [lowStorageThresholdString componentsSeparatedByString:@" "];
                storageThreshold =[[thresholdArray objectAtIndex:0]longLongValue];
                storageThreshold=storageThreshold*1024ll;
                
            }
            else
                if ([lowStorageThresholdString isEqualToString:@"3 GB"])
                {
                    NSArray* thresholdArray= [lowStorageThresholdString componentsSeparatedByString:@" "];
                    storageThreshold =[[thresholdArray objectAtIndex:0]longLongValue];
                    storageThreshold=storageThreshold*1024ll;
                }
//                else
//                    if ([lowStorageThresholdString isEqualToString:@"12 GB"])
//                    {
//                        NSArray* thresholdArray= [lowStorageThresholdString componentsSeparatedByString:@" "];
//                        storageThreshold =[[thresholdArray objectAtIndex:0]longLongValue];
//                        storageThreshold=storageThreshold*1024ll;
//                    }
    
    if (freeDiskSpaceInMB<storageThreshold)
    {
        alertController = [UIAlertController alertControllerWithTitle:@"Low storage"
                                                              message:@"Please delete some data from your deivice"
                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        actionDelete = [UIAlertAction actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
                            [alertController dismissViewControllerAnimated:YES completion:nil];
                            
                            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];

                            [self dismissViewControllerAnimated:YES completion:nil];
                            
                        }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionDelete];
        
        
        actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction * action)
                        {
                            [alertController dismissViewControllerAnimated:YES completion:nil];
                            
                            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];

                            [self dismissViewControllerAnimated:YES completion:nil];
                        }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionCancel];
        
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    //NSLog(@"disk space=%ld",freeDiskSpaceInMB);


}

-(void)viewWillDisappear:(BOOL)animated
{
   if( [APIManager sharedManager].userSettingsClosed)
   {
       [APIManager sharedManager].userSettingsOpened=NO;
   }
    if (![APIManager sharedManager].userSettingsOpened)
    {

//        UIView* startRecordingView= [self.view viewWithTag:303];
//        
//        UILabel* recordingStatusLabel=[self.view viewWithTag:99];
//    
//        UIImageView* startRecordingImageView= [startRecordingView viewWithTag:403];
//        
//        UIImageView* counterLabel= [startRecordingView viewWithTag:503];
//    
//        UIView* stopRecordingCircleView = [self.view viewWithTag:301];
//        
//        UIView* pauseRecordingCircleView =  [self.view viewWithTag:302];
//        
//        UILabel* stopRecordingLabel=[self.view viewWithTag:601];
//        
//        UILabel* pauseRecordingLabel=[self.view viewWithTag:602];
//        
//        UILabel* recordingLabel=[self.view viewWithTag:603];
//        
//        UIView* animatedView=  [self.view viewWithTag:98];
//
//        [startRecordingImageView setHidden:NO];
//        
//        [counterLabel setHidden:YES];
//    
//        [stopRecordingCircleView setHidden:NO];
//        
//        [pauseRecordingCircleView setHidden:NO];
//        
//        [stopRecordingLabel setHidden:NO];
//        
//        [pauseRecordingLabel setHidden:NO];
//        
//        [recordingLabel setHidden:NO];
//    
//        recordingStatusLabel.text=@"Tap on recording to start recording your audio";
//        
//        startRecordingView.backgroundColor=[UIColor colorWithRed:194/255.0 green:19/255.0 blue:19/255.0 alpha:1];
//        
//        startRecordingImageView.image=[UIImage imageNamed:@"Record"];
//        
//        startRecordingImageView.frame=CGRectMake((startRecordingView.frame.size.width/2)-15, (startRecordingView.frame.size.height/2)-25, 30, 50);
//    
//        [animatedView removeFromSuperview];
        [player stop];
     //   [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
    
    if([AppPreferences sharedAppPreferences].recordNew)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"dismiss"];

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
       double height = self.view.frame.size.height*0.50;
        
        double screenHeight =  [[UIScreen mainScreen] bounds].size.height;
        
        if (screenHeight<481)
        {
            [self setRoundedView:sender toDiameter:sender.frame.size.width];
            
        }
        else
       // [self setRoundedView:sender toDiameter:sender.frame.size.width+20];
        [self setRoundedView:sender toDiameter:sender.frame.size.width+20];

    }
//    else
//        [self setRoundedView:sender toDiameter:sender.frame.size.width];
}

-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
{
    circleView=[[UIView alloc]init];
    
    CGRect newFrame;
    
    if (roundedView.tag==203)
    {
        double screenHeight =  [[UIScreen mainScreen] bounds].size.height;
        
        if (screenHeight<481)
        {
            newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y-10, newSize, newSize);
            
        }
        else
        newFrame = CGRectMake(roundedView.frame.origin.x-10, roundedView.frame.origin.y-10, newSize, newSize);
        
    }
//    else
//        newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    
    circleView.frame = newFrame;
    circleView.layer.cornerRadius = newSize / 2.0;
    circleView.tag=roundedView.tag+100;
    
    UIButton* viewClickbutton=[[UIButton alloc]init];
    viewClickbutton.frame=CGRectMake(0, 0, newSize, newSize);//button:subview of view hence 0,0
    
    UIImageView* startStopPauseImageview=[[UIImageView alloc]init];
    
    //--------set Images within the circle,add respective viewClickbutton targets-------//
    
    if (roundedView.tag==201)
    {
//        startStopPauseImageview.image=[UIImage imageNamed:@"Stop"];
//        
//        startStopPauseImageview.frame=CGRectMake((circleView.frame.size.width/2)-15, (circleView.frame.size.height/2)-8, 15, 15);
//        
//        circleView.backgroundColor=[UIColor grayColor];
//        
//        [viewClickbutton addTarget:self action:@selector(setStopRecordingView:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (roundedView.tag==202)
    {
//        startStopPauseImageview.image=[UIImage imageNamed:@"Play"];
//        
//        startStopPauseImageview.frame=CGRectMake((newSize/2), (newSize/2)-8, 15, 15);
//        
//        startStopPauseImageview.tag=roundedView.tag+200;
//        
//        circleView.backgroundColor=[UIColor grayColor];
//        
//        [viewClickbutton addTarget:self action:@selector(setPauseRecordingView:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if (roundedView.tag==203)
    {
        startStopPauseImageview.image=[UIImage imageNamed:@"Record"];
        
        startStopPauseImageview.frame=CGRectMake((circleView.frame.size.width/2)-15, (circleView.frame.size.height/2)-25, 30, 50);
        
        startStopPauseImageview.tag=roundedView.tag+200;
        
        circleView.layer.borderColor = [UIColor whiteColor].CGColor;
        
        circleView.layer.borderWidth = 3.0f;
        
        circleView.backgroundColor=[UIColor colorWithRed:194/255.0 green:19/255.0 blue:19/255.0 alpha:1];
        
        [viewClickbutton addTarget:self action:@selector(setStartRecordingView:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    //----------------------------------//
//    UILabel* recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(recordLAbel.frame.origin.x, circleView.frame.origin.y + circleView.frame.size.height+10, recordLAbel.frame.size.width, recordLAbel.frame.size.height)];
//    
//    recordLabel.tag = 603;
//    
//    recordLabel.textColor = [UIColor colorWithRed:194/255.0 green:19/255.0 blue:19/255.0 alpha:1.0];
//    
//    recordLabel.font = [UIFont systemFontOfSize:15];
//    
//    recordLabel.text = @"Recording";
//    
//    recordLAbel.frame = CGRectMake(recordLAbel.frame.origin.x, circleView.frame.origin.y + circleView.frame.size.height+10, recordLAbel.frame.size.width, recordLAbel.frame.size.height);
    
    [circleView addSubview:viewClickbutton];
    
    [circleView addSubview:startStopPauseImageview];
    
    [self.view addSubview:circleView];
    
   // [self.view addSubview:recordLabel];
}

-(void)setStopRecordingView:(UIButton*)sender
{
//    UIView* stopRecordingView = [self.view viewWithTag:301];
//    
//    UIView* pauseRecordingView =  [self.view viewWithTag:302];
    
    UIView* startRecordingView =  [self.view viewWithTag:303];
    
    if ([startRecordingView.backgroundColor isEqual:[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1]])
    {
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:CONFIRM_BEFORE_SAVING_SETTING])
        {
            UIImageView* animatedImageView= [self.view viewWithTag:1001];
            
            UIView* startRecordingView= [self.view viewWithTag:303];
            
            UIView* stopRecordingView = [self.view viewWithTag:301];
            
            UIView* pauseRecordingView =  [self.view viewWithTag:302];
            
            //        UILabel* recordingStatusLabel= [self.view viewWithTag:99];
            UILabel* stopRecordingLabel=[self.view viewWithTag:601];
            
            UILabel* pauseRecordingLabel=[self.view viewWithTag:602];
            
            UILabel* RecordingLabel=[self.view viewWithTag:603];

            [animatedImageView stopAnimating];
            animatedImageView.image=[UIImage imageNamed:@"SoundWave-3"];
            [self showHud];

       
            [stopRecordingView setHidden:YES];
       
            [pauseRecordingView setHidden:YES];
        
            recordingPausedOrStoped=YES;
            isRecordingStarted=NO;
            
            [stopRecordingView setHidden:YES];
            
            [pauseRecordingView setHidden:YES];
            
            [stopRecordingLabel setHidden:YES];
            
            [pauseRecordingLabel setHidden:YES];
            
            [RecordingLabel setHidden:YES];
            
            [stopNewImageView setHidden:YES];
            
            [stopNewButton setHidden:YES];
            
            [stopLabel setHidden:YES];

        
            startRecordingView.backgroundColor=[UIColor blackColor];
            
            UIImageView* startRecordingImageView= [startRecordingView viewWithTag:403];
            
            [startRecordingImageView setHidden:NO];
            
            [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-9, 18, 18)];
            
            startRecordingImageView.image=[UIImage imageNamed:@"Play"];
            
            [[self.view viewWithTag:701] setHidden:NO];
            
            [[self.view viewWithTag:702] setHidden:NO];
            
            [stopTimer invalidate];
            
            [cirecleTimerLAbel removeFromSuperview];
            
            [self performSelector:@selector(stopRecording) withObject:nil afterDelay:0.0];
            
            double screenHeight =  [[UIScreen mainScreen] bounds].size.height;
            
            if (screenHeight<481)
            {
               
                circleView.frame = CGRectMake(circleView.frame.origin.x, circleView.frame.origin.y-20, circleView.frame.size.width, circleView.frame.size.height);
            }


            [self addAnimatedView];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:BACK_TO_HOME_AFTER_DICTATION])
            {
                [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
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
                                UIImageView* animatedImageView= [self.view viewWithTag:1001];
                                
                                UIView* startRecordingView= [self.view viewWithTag:303];
                                
                                UIView* stopRecordingView = [self.view viewWithTag:301];
                                
                                UIView* pauseRecordingView =  [self.view viewWithTag:302];
                                
                                //        UILabel* recordingStatusLabel= [self.view viewWithTag:99];
                                UILabel* stopRecordingLabel=[self.view viewWithTag:601];
                                
                                UILabel* pauseRecordingLabel=[self.view viewWithTag:602];
                                
                                UILabel* RecordingLabel=[self.view viewWithTag:603];
                                
                                [animatedImageView stopAnimating];
                                animatedImageView.image=[UIImage imageNamed:@"SoundWave-3"];
                                [self showHud];

                                [stopRecordingView setHidden:YES];
                                
                                [pauseRecordingView setHidden:YES];
                                
                                recordingPausedOrStoped=YES;
                                isRecordingStarted=NO;
                                
                                [stopRecordingView setHidden:YES];
                                
                                [pauseRecordingView setHidden:YES];
                                
                                [stopRecordingLabel setHidden:YES];
                                
                                [pauseRecordingLabel setHidden:YES];
                                
                                [RecordingLabel setHidden:YES];
                                
                                [stopNewImageView setHidden:YES];
                                
                                [stopNewButton setHidden:YES];

                                [stopLabel setHidden:YES];

                                
                                startRecordingView.backgroundColor=[UIColor blackColor];
                                
                                UIImageView* startRecordingImageView= [startRecordingView viewWithTag:403];
                                
                                [startRecordingImageView setHidden:NO];
                                
                                [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-9, 18, 18)];
                                
                                startRecordingImageView.image=[UIImage imageNamed:@"Play"];
                                
                                [[self.view viewWithTag:701] setHidden:NO];
                                
                                [[self.view viewWithTag:702] setHidden:NO];
                                
                                
                                [stopTimer invalidate];
                                [cirecleTimerLAbel removeFromSuperview];

                                [self performSelector:@selector(stopRecording) withObject:nil afterDelay:0.0];
                                
                                double screenHeight =  [[UIScreen mainScreen] bounds].size.height;
                                
                                if (screenHeight<481)
                                {
                                    
                                    circleView.frame = CGRectMake(circleView.frame.origin.x, circleView.frame.origin.y-20, circleView.frame.size.width, circleView.frame.size.height);
                                }


                                [self addAnimatedView];
                                
                                if ([[NSUserDefaults standardUserDefaults] boolForKey:BACK_TO_HOME_AFTER_DICTATION])
                                {
                                    [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                }
  
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
    
    
}




//-(void)setPauseRecordingView:(UIButton*)sender
//{
//
//    UIView* pauseView=  [self.view viewWithTag:302];
//    UIImageView* pauseImageView= [pauseView viewWithTag:402];
//    
//    
//    if ( !paused)
//    {
//        recordingPausedOrStoped=YES;
//        
//        paused=YES;
//
//        UIImageView* animatedView= [self.view viewWithTag:1001];
//        
//        [animatedView stopAnimating];
//        
//        animatedView.image=[UIImage imageNamed:@"SoundWave-3"];
//        
//        [self pauseRecording];
//        
//        [stopTimer invalidate];
//        
//        pauseImageView.image=[UIImage imageNamed:@"Play"];
//        
//    }
//    else if ( isRecordingStarted==YES && paused)
//    {
//        recordingPausedOrStoped=NO;
//        
//        paused=NO;
//
//        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
//        
//        UIImageView* animatedView= [self.view viewWithTag:1001];
//        
//        [animatedView startAnimating];
//        
//        [self setTimer];
//        
//        [self performSelector:@selector(mdRecord) withObject:nil afterDelay:0.1];
//        
//        [UIApplication sharedApplication].idleTimerDisabled = YES;
//        
//        pauseImageView.image=[UIImage imageNamed:@"Pause"];
//    }
//
//    
//    // pauseImageView.image=[UIImage imageNamed:@"play"];
//}

- (void) mdRecord
{
    [recorder record];

}

-(void)setStartRecordingView:(UIButton*)sender
{
    
    UIView* startRecordingView= [self.view viewWithTag:303];
    
//    UIView* stopRecordingView = [self.view viewWithTag:301];
//    
//    UIView* pauseRecordingView =  [self.view viewWithTag:302];
//    
//    UILabel* stopRecordingLabel=[self.view viewWithTag:601];
//    
//    UILabel* pauseRecordingLabel=[self.view viewWithTag:602];
//    
//    UILabel* RecordingLabel=[self.view viewWithTag:603];
    
    
    if ([startRecordingView.backgroundColor isEqual:[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1]] || [startRecordingView.backgroundColor isEqual:[UIColor blackColor]])
    {
      if ([startRecordingView.backgroundColor isEqual:[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1]])
      {
          
          
//                  if (![[NSUserDefaults standardUserDefaults] boolForKey:CONFIRM_BEFORE_SAVING_SETTING])
//          {
              UIImageView* startRecordingImageView;
              
              startRecordingImageView  = [startRecordingView viewWithTag:403];
          
          
//              UIImageView* animatedImageView= [self.view viewWithTag:1001];
//              
//              [animatedImageView stopAnimating];
//              
//              animatedImageView.image=[UIImage imageNamed:@"SoundWave-3"];
//              
//              [self showHud];
//              
//              stopped=YES;
//              
//              [stopRecordingView setHidden:YES];
//              
//              [pauseRecordingView setHidden:YES];
//              
//              [stopRecordingLabel setHidden:YES];
//              
//              [pauseRecordingLabel setHidden:YES];
//              
//              [RecordingLabel setHidden:YES];
//              
//              recordingPausedOrStoped=YES;
//              
//              [stopTimer invalidate];
//              
//              [cirecleTimerLAbel removeFromSuperview];
//              
//              [[self.view viewWithTag:701] setHidden:NO];
//              
//              [[self.view viewWithTag:702] setHidden:NO];
//              
//              [self performSelector:@selector(stopRecording) withObject:nil afterDelay:0.0];
//              
//              isRecordingStarted=NO;
//
//              NSError* audioError;
//              
//              player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordedAudioURL error:&audioError];
//              
//              audioRecordSlider.maximumValue = player.duration;
//              
//              if (![[self.view viewWithTag:98] isDescendantOfView:self.view])
//              {
//                  [self addAnimatedView];
//              }
//
//          
//              startRecordingView.backgroundColor=[UIColor blackColor];
//              
//              startRecordingImageView= [startRecordingView viewWithTag:403];
//              
//              [startRecordingImageView setHidden:NO];
//              
//              [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-9, 18, 18)];
//              
//              startRecordingImageView.image=[UIImage imageNamed:@"Play"];
//              
//              if ([[NSUserDefaults standardUserDefaults] boolForKey:BACK_TO_HOME_AFTER_DICTATION])
//              {
//                  [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
//                  
//                  [self dismissViewControllerAnimated:YES completion:nil];
//              }
              
              
               
//              UIView* pauseView=  [self.view viewWithTag:302];
//              UIImageView* pauseImageView= [pauseView viewWithTag:402];
              
              
              if ( !paused)
              {
                  recordingPausedOrStoped=YES;
                  
                  paused=YES;
                  
                  UIImageView* animatedView= [self.view viewWithTag:1001];
                  
                  [animatedView stopAnimating];
                  
                  animatedView.image=[UIImage imageNamed:@"SoundWave-3"];
                  
                  [self pauseRecording];
                  
                  
                  UILabel* recordOrPauseLabel = [self.view viewWithTag:603];
                  
                  recordOrPauseLabel.text = @"Resume";

                  
                  [stopTimer invalidate];
                  
                  
                  [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-15, (startRecordingView.frame.size.height/2)-16, 30, 32)];
                  
                  startRecordingImageView.image=[UIImage imageNamed:@"ResumeNew"];
                  
                  
              }
              else if ( isRecordingStarted==YES && paused)
              {
                  recordingPausedOrStoped=NO;
                  
                  paused=NO;
                  
                  [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
                  
                  UIImageView* animatedView= [self.view viewWithTag:1001];
                  
                  [animatedView startAnimating];
                  
                  
                  UILabel* recordOrPauseLabel = [self.view viewWithTag:603];
                  
                  recordOrPauseLabel.text = @"Pause";

                  
                  [self setTimer];
                  
                  [self performSelector:@selector(mdRecord) withObject:nil afterDelay:0.1];
                  
                  [UIApplication sharedApplication].idleTimerDisabled = YES;
                  
                   [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-18, 18, 36)];
                  
                  startRecordingImageView.image=[UIImage imageNamed:@"PauseNew"];
              }
              
               
              
//          }
          
//          else
//          {
//              alertController = [UIAlertController alertControllerWithTitle:@""
//                                                                    message:@"Do you want to stop recording?"
//                                                             preferredStyle:UIAlertControllerStyleAlert];
//              
//              UIImageView* startRecordingImageView;
//              
//              startRecordingImageView  = [startRecordingView viewWithTag:403];
//
//              actionDelete = [UIAlertAction actionWithTitle:@"Yes"
//                                                      style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction * action)
//                              {
//                                  UIImageView* animatedImageView= [self.view viewWithTag:1001];
//                                  
//                                  [animatedImageView stopAnimating];
//                                  
//                                  animatedImageView.image=[UIImage imageNamed:@"SoundWave-3"];
//                                  
//                                  [self showHud];
//                                  
//                                  stopped=YES;
//
//                                  [stopRecordingView setHidden:YES];
//                                  
//                                  [pauseRecordingView setHidden:YES];
//                                  
//                                  [stopRecordingLabel setHidden:YES];
//                                  
//                                  [pauseRecordingLabel setHidden:YES];
//                                  
//                                  [RecordingLabel setHidden:YES];
//                                  
//                                  isRecordingStarted=NO;
//
//                                  [stopTimer invalidate];
//                                  
//                                  [cirecleTimerLAbel removeFromSuperview];
//                                  
//                                  [[self.view viewWithTag:701] setHidden:NO];
//                                  
//                                  [[self.view viewWithTag:702] setHidden:NO];
//                                  
//                                  [self performSelector:@selector(stopRecording) withObject:nil afterDelay:0.0];
//
//                                  NSError* audioError;
//                                  
//                                  player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordedAudioURL error:&audioError];
//                                  
//                                  audioRecordSlider.maximumValue = player.duration;
//                                  
//                                  if (![[self.view viewWithTag:98] isDescendantOfView:self.view])
//                                  {
//                                      
//                                      [self addAnimatedView];
//                                  }
//                                  
//                                  recordingPausedOrStoped=YES;
//                                  
//                                  startRecordingView.backgroundColor=[UIColor blackColor];
//                                  
//                                  [startRecordingImageView setHidden:NO];
//                                  
//                                  [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-9, 18, 18)];
//                                  
//                                  startRecordingImageView.image=[UIImage imageNamed:@"Play"];
//                                  
//                                  if ([[NSUserDefaults standardUserDefaults] boolForKey:BACK_TO_HOME_AFTER_DICTATION])
//                                  {
//                                      [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
//                                      
//                                      [self dismissViewControllerAnimated:YES completion:nil];
//                                  }
                                  
                                  
                                  
//                                   UIView* pauseView=  [self.view viewWithTag:302];
//                                   UIImageView* pauseImageView= [pauseView viewWithTag:402];
                                  
                                   
//                                   if ( !paused)
//                                   {
//                                   recordingPausedOrStoped=YES;
//                                   
//                                   paused=YES;
//                                   
//                                   UIImageView* animatedView= [self.view viewWithTag:1001];
//                                   
//                                   [animatedView stopAnimating];
//                                   
//                                   animatedView.image=[UIImage imageNamed:@"SoundWave-3"];
//                                   
//                                   [self pauseRecording];
//                                   
//                                   [stopTimer invalidate];
//                                   
//                                   startRecordingImageView.image=[UIImage imageNamed:@"Play"];
//                                   
//                                   }
//                                   else if ( isRecordingStarted==YES && paused)
//                                   {
//                                   recordingPausedOrStoped=NO;
//                                   
//                                   paused=NO;
//                                   
//                                   [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
//                                   
//                                   UIImageView* animatedView= [self.view viewWithTag:1001];
//                                   
//                                   [animatedView startAnimating];
//                                   
//                                   [self setTimer];
//                                   
//                                   [self performSelector:@selector(mdRecord) withObject:nil afterDelay:0.1];
//                                   
//                                   [UIApplication sharedApplication].idleTimerDisabled = YES;
//                                   
//                                   startRecordingImageView.image=[UIImage imageNamed:@"Pause"];
//                                   }
//                                   
//                                  
//                              }]; //You can use a block here to handle a press on this button
//              [alertController addAction:actionDelete];
//              
//              
//              actionCancel = [UIAlertAction actionWithTitle:@"No"
//                                                      style:UIAlertActionStyleCancel
//                                                    handler:^(UIAlertAction * action)
//                              {
//                                  [alertController dismissViewControllerAnimated:YES completion:nil];
//                                  
//                              }]; //You can use a block here to handle a press on this button
//              [alertController addAction:actionCancel];
//              
//              [self presentViewController:alertController animated:YES completion:nil];
//              
//
//          }
//          
          
     }
        else
        {
            UIImageView* startRecordingImageView;
            
            startRecordingImageView  = [startRecordingView viewWithTag:403];
            startRecordingView.backgroundColor=[UIColor blackColor];
            
            
            [startRecordingImageView setHidden:NO];
            
            [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-9, 18, 18)];
        
            if([startRecordingView.backgroundColor isEqual:[UIColor blackColor]])
            {
                if ([startRecordingImageView.image isEqual:[UIImage imageNamed:@"Play"]])
                {
                    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSliderTime:) userInfo:nil repeats:YES];
                    
                    [self prepareAudioPlayer];
            
                    [self playRecording];
            
                    
                    
                    startRecordingImageView.image=[UIImage imageNamed:@"Pause"];
            
                }
                //if image is pause then pause recording
                else
                {
                    [player pause];
                    [stopTimer invalidate];
                    
                 
                    
                    startRecordingImageView.image=[UIImage imageNamed:@"Play"];
                }
                //*-------------------for animated flipFromBottom subView---------------------*
            }
             //*-------------------for animated flipFromBottom subView---------------------*
            }
        }
    
    if ([startRecordingView.backgroundColor isEqual:[UIColor colorWithRed:194/255.0 green:19/255.0 blue:19/255.0 alpha:1]])
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:ALERT_BEFORE_RECORDING])
        {
            
            
            
            [self checkPermissionAndStartRecording];
            
        }
        else
        {
            alertController = [UIAlertController alertControllerWithTitle:@""
                                                                  message:@"Do you want to start recording?"
                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                                
                                
                                 [self checkPermissionAndStartRecording];
                                
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
        
//        AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
//        
//        switch (permissionStatus) {
//            case AVAudioSessionRecordPermissionUndetermined:{
//                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//                    // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
//                    if (granted)
//                    {
//                          [self startRecordingForUserSetting];
//                        // Microphone enabled code
//                    }
//                    else
//                    {
//                         [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Microphone Access Denied" withMessage:@"You must allow microphone access in Settings > Privacy > Microphone" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//                        // Microphone disabled code
//                    }
//                }];
//                break;
//            }
//            case AVAudioSessionRecordPermissionDenied:
//                // direct to settings...
//                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Microphone Access Denied" withMessage:@"You must allow microphone access in Settings > Privacy > Microphone" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//
//                break;
//            case AVAudioSessionRecordPermissionGranted:
//                // mic access ok...
//                [self startRecordingForUserSetting];
//
//                break;
//            default:
//                // this should not happen.. maybe throw an exception.
//                break;
//        }
//        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//            if (granted)
//            {
//                NSLog(@"granted");
//                if (![[NSUserDefaults standardUserDefaults] boolForKey:ALERT_BEFORE_RECORDING])
//                {
//                   
//
//
//                    [self startRecordingForUserSetting];
//                    
//                }
//                else
//                {
//                    alertController = [UIAlertController alertControllerWithTitle:@""
//                                                                          message:@"Do you want to start recording?"
//                                                                   preferredStyle:UIAlertControllerStyleAlert];
//                    
//                    actionDelete = [UIAlertAction actionWithTitle:@"Yes"
//                                                            style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action)
//                                    {
//                                       
//                                        
//                                        [self startRecordingForUserSetting];
//                                        
//                                    }]; //You can use a block here to handle a press on this button
//                    [alertController addAction:actionDelete];
//                    
//                    
//                    actionCancel = [UIAlertAction actionWithTitle:@"No"
//                                                            style:UIAlertActionStyleCancel
//                                                          handler:^(UIAlertAction * action)
//                                    {
//                                        [alertController dismissViewControllerAnimated:YES completion:nil];
//                                        
//                                    }]; //You can use a block here to handle a press on this button
//                    [alertController addAction:actionCancel];
//                    
//                    [self presentViewController:alertController animated:YES completion:nil];
//                    
//                    
//                }
//
//                
//            } else
//            {
//                NSLog(@"denied");
//                
//                
//                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Microphone Access Denied" withMessage:@"You must allow microphone access in Settings > Privacy > Microphone" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//                //  [alert show];
//            }
//        }];
//
        
    }
}

-(void) checkPermissionAndStartRecording
{
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    
    switch (permissionStatus) {
        case AVAudioSessionRecordPermissionUndetermined:{
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
                if (granted)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self startRecordingForUserSetting];

                    });
                    // Microphone enabled code
                }
                else
                {
                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Microphone Access Denied" withMessage:@"You must allow microphone access in Settings > Privacy > Microphone" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                    // Microphone disabled code
                }
            }];
            break;
        }
        case AVAudioSessionRecordPermissionDenied:
            // direct to settings...
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Microphone Access Denied" withMessage:@"You must allow microphone access in Settings > Privacy > Microphone" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
            
            break;
        case AVAudioSessionRecordPermissionGranted:
            // mic access ok...
            [self startRecordingForUserSetting];
            
            break;
        default:
            // this should not happen.. maybe throw an exception.
            break;
    }


}
-(void)showHud
{
    hud.minSize = CGSizeMake(150.f, 100.f);
    
    [hud hideAnimated:NO];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    
    hud.label.text = @"Saving audio..";
    
    hud.detailsLabel.text = @"Please wait";
    
    
}

-(void)hideHud
{
    [hud hideAnimated:YES];

}
-(void)startRecordingForUserSetting
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    UIView* startRecordingView= [self.view viewWithTag:303];
    
    UIView* pauseRecordingView =  [self.view viewWithTag:302];
    
    UILabel* recordingStatusLabel= [self.view viewWithTag:99];
    
    UILabel* startLabel = [self.view viewWithTag:603];
    
    startLabel.text = @"Pause";
    
    startLabel.textColor = [UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1];
    
    UIImageView* startRecordingImageView;
    
    stopped=NO;
    
    [stopNewButton setHidden:NO];
    
    [stopNewImageView setHidden:NO];
    
    [stopLabel setHidden:NO];

    
    [cirecleTimerLAbel setHidden:NO];
   
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",todaysSerialNumberCount] forKey:@"todaysSerialNumberCount"];
    
    [self audioRecord];
    
    startRecordingView.backgroundColor=[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1];
    
//    recordingStatusLabel.frame= CGRectMake(recordingStatusLabel.frame.origin.x, self.view.frame.origin.y + stopNewImageView.frame.size.height + 20, recordingStatusLabel.frame.size.width, recordingStatusLabel.frame.size.height);
    
    recordingStatusLabel.text=@"Your audio is being recorded";
    
//    UILabel* updatedrecordingStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(recordingStatusLabel.frame.origin.x, stopNewImageView.frame.origin.y + stopNewImageView.frame.size.height + 20, recordingStatusLabel.frame.size.width, 30)];
    
    double screenHeight =  [[UIScreen mainScreen] bounds].size.height;

    UIImageView* animatedImageView;
    if (screenHeight<481)
    {
        animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(recordingStatusLabel.frame.origin.x-10, stopNewImageView.frame.origin.y + stopNewImageView.frame.size.height + 30, recordingStatusLabel.frame.size.width+20, 15)];
    }
    else
    animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(recordingStatusLabel.frame.origin.x-10, stopNewImageView.frame.origin.y + stopNewImageView.frame.size.height + 40, recordingStatusLabel.frame.size.width+20, 30)];

     UILabel* updatedrecordingStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(recordingStatusLabel.frame.origin.x, animatedImageView.frame.origin.y + animatedImageView.frame.size.height + 10, recordingStatusLabel.frame.size.width, 30)];
    
    updatedrecordingStatusLabel.text=@"Your audio is being recorded";
    
    updatedrecordingStatusLabel.textColor = [UIColor lightGrayColor];
    
    updatedrecordingStatusLabel.textAlignment = NSTextAlignmentCenter;
    
    updatedrecordingStatusLabel.font = [UIFont systemFontOfSize:18];
    
    [recordingStatusLabel setHidden:YES];
    
    
    animatedImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"SoundWave-1"],
                                         [UIImage imageNamed:@"SoundWave-2"],
                                         [UIImage imageNamed:@"SoundWave-3"],
                                          nil];
    //animatedImageView.image= [UIImage animatedImageNamed:@"SoundWave-" duration:1.0f];
    //[UIImage animatedImageNamed:@"SoundWave-" duration:1.0f];

    animatedImageView.animationDuration = 1.0f;
    
    animatedImageView.animationRepeatCount = 0;
    
    [animatedImageView startAnimating];
    
    animatedImageView.userInteractionEnabled=YES;
    
    animatedImageView.tag=1001;
    
    [self.view addSubview:updatedrecordingStatusLabel];
    
    [self.view addSubview: animatedImageView];
    
//    cirecleTimerLAbel.frame=CGRectMake((startRecordingView.frame.size.width/2)-30, (startRecordingView.frame.size.height/2)-25, 60, 50);
    
    cirecleTimerLAbel = [self.view viewWithTag:104];
    //cirecleTimerLAbel.frame=CGRectMake((startRecordingView.frame.size.width/2)-30, (startRecordingView.frame.size.height/2)-25, 60, 50);
    
    
    //cirecleTimerLAbel.textColor=[UIColor whiteColor];
    
    //cirecleTimerLAbel.font=[UIFont systemFontOfSize:20];
    
    cirecleTimerLAbel.textAlignment=NSTextAlignmentCenter;
    
    cirecleTimerLAbel.text=[NSString stringWithFormat:@"%02d:%02d:%02d",00,00,00];
    
    [startRecordingView addSubview:cirecleTimerLAbel];
    
    isRecordingStarted=YES;
    
    recordingPausedOrStoped = NO;
    
    paused=NO;

    //UIImageView* pauseRecordingImageView = [pauseRecordingView viewWithTag:402];
    
    //pauseRecordingImageView.image=[UIImage imageNamed:@"Pause"];
    
    startRecordingImageView= [startRecordingView viewWithTag:403];
    
    startRecordingImageView.image=[UIImage imageNamed:@"PauseNew"];
    
    
    startRecordingImageView  = [startRecordingView viewWithTag:403];
    
    [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-9, (startRecordingView.frame.size.height/2)-18, 18, 36)];
   
    //[startRecordingImageView setHidden:YES];
    
    [self startRecorderAfterPrepared];
   // [self performSelector:@selector(startRecorderAfterPrepared) withObject:nil afterDelay:0.3];


}

/*
 
 -(void)startRecordingForUserSetting
 {
 [UIApplication sharedApplication].idleTimerDisabled = YES;
 
 UIView* startRecordingView= [self.view viewWithTag:303];
 
 UIView* pauseRecordingView =  [self.view viewWithTag:302];
 
 UILabel* recordingStatusLabel= [self.view viewWithTag:99];
 
 UIImageView* startRecordingImageView;
 
 
 [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",todaysSerialNumberCount] forKey:@"todaysSerialNumberCount"];
 
 [self audioRecord];
 
 startRecordingView.backgroundColor=[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1];
 
 recordingStatusLabel.text=@"Your audio is being recorded";
 
 UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(recordingStatusLabel.frame.origin.x-10, recordingStatusLabel.frame.origin.y+recordingStatusLabel.frame.size.height+10., recordingStatusLabel.frame.size.width+20, 30)];
 
 animatedImageView.animationImages = [NSArray arrayWithObjects:
 [UIImage imageNamed:@"SoundWave-1"],
 [UIImage imageNamed:@"SoundWave-2"],
 [UIImage imageNamed:@"SoundWave-3"],
 nil];
 //animatedImageView.image= [UIImage animatedImageNamed:@"SoundWave-" duration:1.0f];
 //[UIImage animatedImageNamed:@"SoundWave-" duration:1.0f];
 
 animatedImageView.animationDuration = 1.0f;
 
 animatedImageView.animationRepeatCount = 0;
 
 [animatedImageView startAnimating];
 
 animatedImageView.userInteractionEnabled=YES;
 
 animatedImageView.tag=1001;
 
 [self.view addSubview: animatedImageView];
 
 cirecleTimerLAbel.frame=CGRectMake((startRecordingView.frame.size.width/2)-30, (startRecordingView.frame.size.height/2)-25, 60, 50);
 
 cirecleTimerLAbel.textColor=[UIColor whiteColor];
 
 cirecleTimerLAbel.font=[UIFont systemFontOfSize:20];
 
 cirecleTimerLAbel.textAlignment=NSTextAlignmentCenter;
 
 cirecleTimerLAbel.text=[NSString stringWithFormat:@"%02d:%02d",00,00];
 
 [startRecordingView addSubview:cirecleTimerLAbel];
 
 isRecordingStarted=YES;
 
 recordingPausedOrStoped = NO;
 
 paused=NO;
 
 UIImageView* pauseRecordingImageView = [pauseRecordingView viewWithTag:402];
 
 pauseRecordingImageView.image=[UIImage imageNamed:@"Pause"];
 
 startRecordingImageView= [startRecordingView viewWithTag:403];
 
 [startRecordingImageView setHidden:YES];
 
 [self performSelector:@selector(startRecorderAfterPrepared) withObject:nil afterDelay:0.3];
 
 
 }

 */
-(void)startRecorderAfterPrepared
{

    [self setTimer];
    
    [recorder record];

}
-(void)addAnimatedView
{
    
    UIView* animatedView=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2)];
    animatedView.tag=98;
    
    audioRecordSlider=[[UISlider alloc]initWithFrame:CGRectMake(animatedView.frame.size.width*0.14,animatedView.frame.size.height*0.01 , animatedView.frame.size.width*0.7, 30)];
    [audioRecordSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    //audioRecordSlider.minimumValue = 0.0;
    audioRecordSlider.continuous = YES;
    audioRecordSlider.maximumValue=player.duration;
    //float currentTimeFloat=player.duration;
    int currentTime= player.duration;
    int minutes=currentTime/60;
    int seconds=currentTime%60;
   
    UIButton* uploadAudioButton=[[UIButton alloc]initWithFrame:CGRectMake(animatedView.frame.size.width*0.1, animatedView.frame.size.height*0.2, animatedView.frame.size.width*0.8, 36)];
    uploadAudioButton.backgroundColor=[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1];
    uploadAudioButton.userInteractionEnabled=YES;
    [uploadAudioButton setTitle:@"Upload Recording" forState:UIControlStateNormal];
    uploadAudioButton.titleLabel.font = [UIFont systemFontOfSize: 15];
    
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
    
    UIButton* recordNewButton=[[UIButton alloc]initWithFrame:CGRectMake(uploadLaterButton.frame.origin.x+uploadLaterButton.frame.size.width+uploadAudioButton.frame.size.width*0.04, uploadAudioButton.frame.origin.y+uploadAudioButton.frame.size.height+10, uploadAudioButton.frame.size.width*0.48, 36)];
    recordNewButton.backgroundColor=[UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
    [recordNewButton setTitle:@"Record New" forState:UIControlStateNormal];
    recordNewButton.titleLabel.font = [UIFont systemFontOfSize: 15];
    [recordNewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    recordNewButton.layer.cornerRadius=5.0f;
    [recordNewButton addTarget:self action:@selector(presentRecordView) forControlEvents:UIControlEventTouchUpInside];
    
//    currentDuration=[[UILabel alloc]initWithFrame:CGRectMake(animatedView.frame.size.width*0.15, animatedView.frame.size.height*0.1, 100, 20)];
//    totalDuration=[[UILabel alloc]initWithFrame:CGRectMake(animatedView.frame.size.width*0.15+audioRecordSlider.frame.size.width-10, animatedView.frame.size.height*0.1, 100, 20)];
    
    currentDuration=[[UILabel alloc]initWithFrame:CGRectMake(uploadAudioButton.frame.origin.x, animatedView.frame.size.height*0.1, 80, 20)];
    totalDuration=[[UILabel alloc]initWithFrame:CGRectMake(uploadAudioButton.frame.origin.x+uploadAudioButton.frame.size.width-80, animatedView.frame.size.height*0.1, 80, 20)];
    currentDuration.textAlignment=NSTextAlignmentLeft;
    totalDuration.textAlignment=NSTextAlignmentRight;
    
    totalDuration.text=[NSString stringWithFormat:@"%02d:%02d",minutes,seconds];//for slider label time label
    currentDuration.text=[NSString stringWithFormat:@"00:00"];//for slider label time label
    
    if (minutes>99)//foe more than 99 min show time in 3 digits
    {
        totalDuration.text=[NSString stringWithFormat:@"%03d:%02d",minutes,seconds];//for slider label time label
        
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
                     completion:^(BOOL finished)
    {
                     }];
    [self.view addSubview:animatedView];
    
}


-(void)dismissView
{
    [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)presentRecordView
{
    recordingNew=YES;
    if ([AppPreferences sharedAppPreferences].selectedTabBarIndex==3)
    {
            [AppPreferences sharedAppPreferences].recordNew=YES;

    }
//    [AppPreferences sharedAppPreferences].recordNew=YES;
    [self dismissViewControllerAnimated:NO completion:nil];
    //[self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"] animated:NO completion:nil];
    
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
                            
                            [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:self.recordedAudioFileName];
                            
                            [app uploadFileToServer:self.recordedAudioFileName];
                            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
                            sender.userInteractionEnabled=NO;
                            deleteButton.userInteractionEnabled=NO;
                            recordingNew=NO;
                            
                            
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
    //for dictation waiting by
    ++dictationTimerSeconds;

    if (dictationTimerSeconds==60*minutesValue)
    {
        recordingPausedOrStoped=YES;
        UIImageView* animatedView= [self.view viewWithTag:1001];
        [animatedView stopAnimating];
        animatedView.image=[UIImage imageNamed:@"SoundWave-3"];
        UILabel* recordOrPauseLabel = [self.view viewWithTag:603];
        
        recordOrPauseLabel.text = @"Resume";
        paused=YES;
        [self pauseRecording];
     //   [UIApplication sharedApplication].idleTimerDisabled = NO;

    }
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    if(![self.view viewWithTag:701].hidden && recorder.isRecording)
    {
    [[self.view viewWithTag:701] setHidden:YES];
    [[self.view viewWithTag:702] setHidden:YES];
    }
    //------------------------
    ++circleViewTimerSeconds;
    if (circleViewTimerSeconds==60)
    {
        circleViewTimerSeconds=0;
        ++circleViewTimerMinutes;
    }
    if (circleViewTimerMinutes==60)
    {
        circleViewTimerSeconds=0;
        circleViewTimerMinutes=0;
        ++circleViewTimerHours;
    }
   
    cirecleTimerLAbel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",circleViewTimerHours,circleViewTimerMinutes,circleViewTimerSeconds];//for circleView timer label
    
}


#pragma mark:AudioSlider actions

-(void)sliderValueChanged
{
    player.currentTime = audioRecordSlider.value;
    
}
-(void)sliderValueChanged:(id)sender
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
        
        
        [self presentViewController:alertController animated:YES completion:nil];    }
    else
    if (recordingPauseAndExit && !stopped)
    {
        [self saveAudioRecordToDatabase];

        NSString* destinationPath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,self.recordedAudioFileName]];
        NSError* error1;
         [[NSFileManager defaultManager] moveItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@copy.wav",AUDIO_FILES_FOLDER_NAME,self.recordedAudioFileName]] toPath:destinationPath error:&error1];
        

        //[self setCompressAudio];
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];


    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
        
        UIView* animatedView=  [self.view viewWithTag:98];

        [animatedView removeFromSuperview];
        
        [self dismissViewControllerAnimated:YES completion:nil];

    }
    
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


-(void)EditDepartment
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    CGRect frame=CGRectMake(10.0f, self.view.center.y-150, self.view.frame.size.width - 20.0f, 200.0f);
    UITableView* tab= [forTableViewObj tableView:self frame:frame];
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
   // [recorder recordForDuration:60];
    
    if (!IMPEDE_PLAYBACK)
    {
        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryRecord];
    }
    NSString* filePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:AUDIO_FILES_FOLDER_NAME]];
    NSError* error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    
    NSArray* pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               AUDIO_FILES_FOLDER_NAME,
                               [NSString stringWithFormat:@"%@copy.wav", self.recordedAudioFileName],
                               nil];
    
    self.recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // settings for the recorder
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];//kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];//8000

    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    
    // initiate recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:self.recordedAudioURL settings:recordSetting error:&error];
   [recorder prepareToRecord];
    
    
}

-(void)pauseRecording
{
    //for dictation waiting by setting
//    UIView* pauseView=  [self.view viewWithTag:302];
//    UIImageView* pauseImageView= [pauseView viewWithTag:402];
    [stopTimer invalidate];
   
 //    pauseImageView.image=[UIImage imageNamed:@"Play"];
   
    UIView* startRecordingView = [self.view viewWithTag:303];
    
    UIImageView* startRecordingImageView = [startRecordingView viewWithTag:403];
    
     [startRecordingImageView setFrame:CGRectMake((startRecordingView.frame.size.width/2)-15, (startRecordingView.frame.size.height/2)-16, 30, 32)];
    
    startRecordingImageView.image=[UIImage imageNamed:@"ResumeNew"];
//
    dictationTimerSeconds=0;
    recordingPauseAndExit=YES;
    paused=YES;
    [recorder pause];

}


-(void)stopRecording
{
    [recorder stop];
    stopped = YES;
    paused = YES;
    recordingPauseAndExit=NO;
    app=[APIManager sharedManager];
    [self saveAudioRecordToDatabase];

    
    [self setCompressAudio];
   
    app.awaitingFileTransferCount= [db getCountOfTransfersOfDicatationStatus:@"RecordingComplete"];
}

-(void)setCompressAudio
{
    
    NSString* filePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:AUDIO_FILES_FOLDER_NAME]];
    NSString *source=[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@copy.wav",self.recordedAudioFileName]];
    
    // NSString *source = [[NSBundle mainBundle] pathForResource:@"sourceALAC" ofType:@"caf"];
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    destinationFilePath= [[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:AUDIO_FILES_FOLDER_NAME]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",self.recordedAudioFileName]];
    //destinationFilePath = [[NSString alloc] initWithFormat: @"%@/output.caf", documentsDirectory];
    destinationURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)destinationFilePath, kCFURLPOSIXPathStyle, false);
    sourceURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)source, kCFURLPOSIXPathStyle, false);
    NSError* error;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAudioProcessing error:&error];
    
    if (error)
    {
        printf("Setting the AVAudioSessionCategoryAudioProcessing Category failed! %ld\n", (long)error.code);
        [self hideHud];

        return;
    }
    
    
    
    // run audio file code in a background thread
    [self convertAudio];

}
- (bool)convertAudio
{
//    outputFormat = kAudioFormatLinearPCM;
    outputFormat = kAudioFormatLinearPCM;

  //  sampleRate = 44100.0;
    sampleRate = 0;

    OSStatus error = DoConvertFile(sourceURL, destinationURL, outputFormat, sampleRate);
    NSError* error1;
    
    if (error) {
        // delete output file if it exists since an error was returned during the conversion process
        if ([[NSFileManager defaultManager] fileExistsAtPath:destinationFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:destinationFilePath error:nil];
        }
        NSString* destinationPath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,self.recordedAudioFileName]];
          [[NSFileManager defaultManager] moveItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@copy.wav",AUDIO_FILES_FOLDER_NAME,self.recordedAudioFileName]] toPath:destinationPath error:&error1];
        printf("DoConvertFile failed! %d\n", (int)error);
        [self hideHud];

        return false;
    }
    else
    {
        //NSLog(@"Converted");
                        [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@copy.wav",AUDIO_FILES_FOLDER_NAME,self.recordedAudioFileName]] error:&error1];
        NSArray* pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   AUDIO_FILES_FOLDER_NAME,
                                   [NSString stringWithFormat:@"%@.wav", self.recordedAudioFileName],
                                   nil];
        self.recordedAudioURL=[NSURL fileURLWithPathComponents:pathComponents];
        [self hideHud];
        return true;
    }
    
}


-(void)prepareAudioPlayer
{
    [recorder stop];

    if (!IMPEDE_PLAYBACK)
    {
        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayback];
    }
   // [recorder stop];
    NSError *audioError;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordedAudioURL error:&audioError];
   //int maxValue= ceil(player.duration);
    audioRecordSlider.maximumValue = player.duration;
    player.currentTime = audioRecordSlider.value;
    
    player.delegate = self;
    [player prepareToPlay];
    
}
-(void)playRecording
{
    circleViewTimerSeconds=0;
    circleViewTimerMinutes=0;
    
    //int maxValue= ceil(player.duration);

        int totalMinutes=player.duration/60;
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

-(void)saveAudioRecordToDatabase
{
    app=[APIManager sharedManager];
    NSString* recordedAudioFileNamem4a=[NSString stringWithFormat:@"%@.wav",self.recordedAudioFileName];
    NSString* filePath=[[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:AUDIO_FILES_FOLDER_NAME]] stringByAppendingPathComponent:recordedAudioFileNamem4a];
    uint64_t freeSpaceUnsignLong= [[APIManager sharedManager] getFileSize:filePath];
    long fileSizeinKB=freeSpaceUnsignLong;
   
    [self prepareAudioPlayer];//initiate audio player with current recording to get currentAudioDuration
    
    recordCreatedDateString=[app getDateAndTimeString];//recording createdDate
    NSString* recordingDate=recordCreatedDateString;//recording updated date
    
    int dictationStatus=1;
    if (recordingPauseAndExit)
    {
        dictationStatus=2;
    }
    int transferStatus=0;
    int deleteStatus=0;
    NSString* deleteDate=@"";
    NSString* transferDate=@"";
    
    //int duration= ceil(player.duration);
    NSString *currentDuration1=[NSString stringWithFormat:@"%f",player.duration];
    NSString* fileSize=[NSString stringWithFormat:@"%ld",fileSizeinKB];
    int newDataUpdate=0;
    int newDataSend=0;
    int mobileDictationIdVal;
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //deptObj.departmentName=departmentNameLanel.text;
    //DepartMent *deptObj=[[NSUserDefaults standardUserDefaults] valueForKey:SELECTED_DEPARTMENT_NAME];
    //deptObj.departmentName;
   NSString* departmentName=[db getDepartMentIdFromDepartmentName:deptObj.departmentName];
    
    NSDictionary* audioRecordDetailsDict=[[NSDictionary alloc]initWithObjectsAndKeys:self.recordedAudioFileName,@"recordItemName",recordCreatedDateString,@"recordCreatedDate",recordingDate,@"recordingDate",transferDate,@"transferDate",[NSString stringWithFormat:@"%d",dictationStatus],@"dictationStatus",[NSString stringWithFormat:@"%d",transferStatus],@"transferStatus",[NSString stringWithFormat:@"%d",deleteStatus],@"deleteStatus",deleteDate,@"deleteDate",fileSize,@"fileSize",currentDuration1,@"currentDuration",[NSString stringWithFormat:@"%d",newDataUpdate],@"newDataUpdate",[NSString stringWithFormat:@"%d",newDataSend],@"newDataSend",[NSString stringWithFormat:@"%d",mobileDictationIdVal],@"mobileDictationIdVal",departmentName,@"departmentName",nil];
    
    [db insertRecordingData:audioRecordDetailsDict];
    
    if (recordingPauseAndExit)
    {
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
    }
    
    
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    UIView* startRecordingView= [self.view viewWithTag:303];
    UIImageView* startRecordingImageView= [startRecordingView viewWithTag:403];
    startRecordingImageView.image=[UIImage imageNamed:@"Play"];
    [stopTimer invalidate];
    currentDuration.text=[NSString stringWithFormat:@"00:00"];//for slider label time label

    [[self player] stop];
}

#pragma mark:TableView Datasource and Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Database* db=[Database shareddatabase];
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
    
    if ([deptObj.departmentName isEqualToString:departmentLabel.text])
    {

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
    NSLog(@"%ld",deptObj.Id);
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME_COPY];
    DepartMent *deptObj1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"%ld",deptObj1.Id);
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

    [popupView removeFromSuperview];
}



-(void)hideTableView
{
    
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:504] removeFromSuperview];//
}


- (IBAction)deleteRecording:(id)sender

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
                        [db updateAudioFileStatus:@"RecordingDelete" fileName:recordedAudioFileName dateAndTime:dateAndTimeString];

                        BOOL deleted= [app deleteFile:recordedAudioFileName];
                        if (deleted)
                        {
                            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];//for recordtabarControlr ref to dismiss current view
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
