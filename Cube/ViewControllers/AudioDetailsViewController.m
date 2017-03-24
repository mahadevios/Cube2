//
//  AudioDetailsViewController.m
//  Cube
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "AudioDetailsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DepartMent.h"
#import "PopUpCustomView.h"
#define IMPEDE_PLAYBACK NO

@interface AudioDetailsViewController ()
{
  AVAudioPlayer       *player;
}
@end

@implementation AudioDetailsViewController
@synthesize transferDictationButton,deleteDictationButton,moreButton;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pausePlayerFromBackGround) name:NOTIFICATION_PAUSE_AUDIO_PALYER
                                               object:nil];
    popupView=[[UIView alloc]init];
    forTableViewObj=[[PopUpCustomView alloc]init];
    // Do any additional setup after loading the view.
}
-(void)pausePlayerFromBackGround
{
    [player stop];
    
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:222];
    if ([popUpView isKindOfClass:[UIView class]])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
    }
    


}
-(void)viewWillAppear:(BOOL)animated
{
    APIManager* app=[APIManager sharedManager];
    [transferDictationButton setHidden:NO];
    [deleteDictationButton setHidden:NO];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    transferDictationButton.layer.cornerRadius=4.0f;
    deleteDictationButton.layer.cornerRadius=4.0f;
    UILabel* filenameLabel=[self.view viewWithTag:501];
    //UILabel* dictatedByLabel=[self.view viewWithTag:502];
    UILabel* departmentLabel=[self.view viewWithTag:503];
    UILabel* dictatedOnLabel=[self.view viewWithTag:504];
    UILabel* transferStatusLabel=[self.view viewWithTag:505];
    UILabel* transferDateLabel=[self.view viewWithTag:506];
    UILabel* dictatedHeadingLabel=[self.view viewWithTag:2000];

    // UILabel* transferDateLabel=[self.view viewWithTag:506];
    
    if ([self.selectedView isEqualToString:@"Awaiting Transfer"])
    {
        audiorecordDict= [app.awaitingFileTransferNamesArray objectAtIndex:self.selectedRow];

    }
    else
    if ([self.selectedView isEqualToString:@"Today's Transferred"])
    {
        [transferDictationButton setTitle:@"Resend" forState:UIControlStateNormal];
        audiorecordDict= [app.todaysFileTransferNamesArray objectAtIndex:self.selectedRow];
    }
    else
        if ([self.selectedView isEqualToString:@"Transfer Failed"])
   
    {
        [transferDictationButton setTitle:@"Resend" forState:UIControlStateNormal];
        audiorecordDict= [app.failedTransferNamesArray objectAtIndex:self.selectedRow];
    }
    else
        if ([self.selectedView isEqualToString:@"Imported"])

    {
        [transferDictationButton setTitle:@"Transfer Recording" forState:UIControlStateNormal];
        audiorecordDict= [[AppPreferences sharedAppPreferences].importedFilesAudioDetailsArray objectAtIndex:self.selectedRow];
    }
    if ([self.selectedView isEqualToString:@"Imported"])
    {
        filenameLabel.text= [[audiorecordDict valueForKey:@"RecordItemName"] stringByDeletingPathExtension];
        //filenameLabel.text=[audiorecordDict valueForKey:@"RecordItemName"];
        dictatedHeadingLabel.text=@"Imported On";
    }
    else
    {
     filenameLabel.text=[audiorecordDict valueForKey:@"RecordItemName"];
    }
    dictatedOnLabel.text=[audiorecordDict valueForKey:@"RecordCreatedDate"];
    departmentLabel.text=[audiorecordDict valueForKey:@"Department"];
    transferStatusLabel.text=[audiorecordDict valueForKey:@"TransferStatus"];
   
    transferDateLabel.text=[audiorecordDict valueForKey:@"TransferDate"];
    if ([self.selectedView isEqualToString:@"Transfer Failed"])
    {
        transferDateLabel.text=@"";
    }
    if ([[audiorecordDict valueForKey:@"DeleteStatus"] isEqualToString:@"Delete"])//to check wether transferred file is deleted
    {
        transferStatusLabel.text=[NSString stringWithFormat:@"%@,Deleted",[audiorecordDict valueForKey:@"TransferStatus"]];
        [transferDictationButton setHidden:YES];
        [deleteDictationButton setHidden:YES];
    }
   // [UIApplication sharedApplication].idleTimerDisabled = NO;

    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME_COPY];

    DepartMent *deptObj = [[DepartMent alloc]init];
    long deptId= [[[Database shareddatabase] getDepartMentIdFromDepartmentName:departmentLabel.text] longLongValue];
    
    deptObj.Id=deptId;
    //deptObj.Id=indexPath.row;
    deptObj.departmentName=departmentLabel.text;
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:deptObj];
    
    [[NSUserDefaults standardUserDefaults] setObject:data1 forKey:SELECTED_DEPARTMENT_NAME];
    moreButton.userInteractionEnabled=YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME_COPY];
    DepartMent *deptObj1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME];
  //  [UIApplication sharedApplication].idleTimerDisabled = NO;

}
-(void)popViewController:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
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

- (IBAction)moreButtonClicked:(id)sender
{
    NSArray* subViewArray=[NSArray arrayWithObjects:@"Edit Department", nil];
    UIView* pop=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-170, self.view.frame.origin.y+20, 160, 40) andSubViews:subViewArray :self];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:pop];
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


- (IBAction)backButtonPressed:(id)sender
{
    [player stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deleteDictation:(id)sender
{
    
    alertController = [UIAlertController alertControllerWithTitle:@"Delete?"
                                                          message:DELETE_MESSAGE
                                                   preferredStyle:UIAlertControllerStyleAlert];
    actionDelete = [UIAlertAction actionWithTitle:@"Delete"
                                        style:UIAlertActionStyleDestructive
                                      handler:^(UIAlertAction * action)
                {
                    APIManager* app=[APIManager sharedManager];
                    Database* db=[Database shareddatabase];
                    NSString* fileName=[audiorecordDict valueForKey:@"RecordItemName"];
                    NSString* dateAndTimeString=[app getDateAndTimeString];
                    [db updateAudioFileStatus:@"RecordingDelete" fileName:fileName dateAndTime:dateAndTimeString];
                    [app deleteFile:[NSString stringWithFormat:@"%@backup",fileName]];
                    BOOL delete= [app deleteFile:fileName];
                    
                    if ([self.selectedView isEqualToString:@"Imported"])
                    {
                        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_IDENTIFIER];
                        
                        // NSString* sharedAudioFolderPathString=[sharedDefaults objectForKey:@"audioFolderPath"];
                        
                        NSMutableArray* sharedAudioNamesArray=[NSMutableArray new];
                        
                        NSArray* copyArray=[NSArray new];
                        
                        copyArray=[sharedDefaults objectForKey:@"audioNamesArray"];
                        
                        sharedAudioNamesArray=[copyArray mutableCopy];
                        
                        NSMutableArray* forDeleteStatusProxyArray = [NSMutableArray new];
                        
                        for (int i=0; i<sharedAudioNamesArray.count; i++)
                        {
                            
                            NSString* fileNameWithoutExtension=[[sharedAudioNamesArray objectAtIndex:i] stringByDeletingPathExtension];

                            NSString* pathExtension= [[sharedAudioNamesArray objectAtIndex:i] pathExtension];
                            
                            NSString* fileNameWithExtension=[NSString stringWithFormat:@"%@.%@",fileName,pathExtension];
//
                            if ([sharedAudioNamesArray containsObject:fileNameWithExtension])
                            {
                                [sharedAudioNamesArray removeObject:fileNameWithExtension];
                                
                                break;

                            }
                            
                        }
                        
                        [sharedDefaults setObject:sharedAudioNamesArray forKey:@"audioNamesArray"];
                        
                        [sharedDefaults synchronize];
                    }
                    if (delete)
                    {
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
    
//    APIManager* app=[APIManager sharedManager];
//    Database* db=[Database shareddatabase];
//    NSDictionary* audiorecordDict= [app.awaitingFileTransferNamesArray objectAtIndex:self.selectedRow];
//    NSString* fileName=[audiorecordDict valueForKey:@"RecordItemName"];
//    NSString* dateAndTimeString=[app getDateAndTimeString];
//    [db updateAudioFileStatus:@"RecordingDelete" fileName:fileName dateAndTime:dateAndTimeString];
//    BOOL deleted= [app deleteFile:fileName];
    
}

- (IBAction)playRecordingButtonPressed:(id)sender
{
    if ([[audiorecordDict valueForKey:@"DeleteStatus"] isEqualToString:@"Delete"])//to check wether transferred file is deleted
    {
        alertController = [UIAlertController alertControllerWithTitle:@"File does not exist"
                                                              message:@""
                                                       preferredStyle:UIAlertControllerStyleAlert];
        actionDelete = [UIAlertAction actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
                            
                        }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionDelete];
        [self presentViewController:alertController animated:YES completion:nil];

    }
    else
    {
        
        UIView * overlay1=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.05, self.view.center.y-40, self.view.frame.size.width*0.9, 80) senderNameForSlider:self player:player];
//     UIView* overlay=   [obj initWithFrame:CGRectMake(self.view.frame.size.width*0.05, self.view.center.y, self.view.frame.size.width*0.9, 80) senderNameForSlider:self player:player];
        [[[UIApplication sharedApplication] keyWindow] addSubview:overlay1];

      sliderPopUpView=  [overlay1 viewWithTag:223];
      audioRecordSlider=  [sliderPopUpView viewWithTag:224];
        
        UIImageView* pauseOrPlayImageView= [sliderPopUpView viewWithTag:226];
        UILabel* dateAndTimeLabel=[sliderPopUpView viewWithTag:225];
        dateAndTimeLabel.text=[audiorecordDict valueForKey:@"RecordCreatedDate"];
        pauseOrPlayImageView.image=[UIImage imageNamed:@"Pause"];
    NSString* filName;
        
//        if ([self.selectedView isEqualToString:@"Imported"])
//        {
//            //filName= [[audiorecordDict valueForKey:@"RecordItemName"] stringByDeletingPathExtension];
//            //filenameLabel.text=[audiorecordDict valueForKey:@"RecordItemName"];
//            
//        }
//        else
 //       {
         filName=[audiorecordDict valueForKey:@"RecordItemName"];
   //     }

    if (!IMPEDE_PLAYBACK)
    {
        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayback];
    }
    NSArray* pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               AUDIO_FILES_FOLDER_NAME,
                               [NSString stringWithFormat:@"%@.wav", filName],
                               nil];
    NSURL* recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
    NSError* audioError;
   player= [[AVAudioPlayer alloc] initWithContentsOfURL:recordedAudioURL error:&audioError];
    
    player.delegate = self;
    [player prepareToPlay];
        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSliderTime:) userInfo:nil repeats:YES];

    audioRecordSlider.maximumValue=player.duration;
    [player play];
        [UIApplication sharedApplication].idleTimerDisabled = YES;

    }
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player1 successfully:(BOOL)flag
{
   UIImageView* pauseOrImageView= [sliderPopUpView viewWithTag:226];
    pauseOrImageView.image=[UIImage imageNamed:@"Play"] ;
   // [UIApplication sharedApplication].idleTimerDisabled = NO;

    [player1 stop];
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:222];
    if ([popUpView isKindOfClass:[UIView class]])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
    }
}
-(void)playOrPauseButtonPressed
{
    UIImageView* pauseOrImageView= [sliderPopUpView viewWithTag:226];
    if ([pauseOrImageView.image isEqual:[UIImage imageNamed:@"Pause"]])
    {
        pauseOrImageView.image=[UIImage imageNamed:@"Play"] ;
        [player pause];
      //  [UIApplication sharedApplication].idleTimerDisabled = NO;

    }
    else
    if ([pauseOrImageView.image isEqual:[UIImage imageNamed:@"Play"]])
    {
        pauseOrImageView.image=[UIImage imageNamed:@"Pause"] ;
        [player play];
        [UIApplication sharedApplication].idleTimerDisabled = YES;

    }

}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (popupView.superview != nil)
    {
        if (![touch.view isEqual:popupView])
        {
            return NO;
        }
        
        return YES;
    }
    if (sliderPopUpView.superview != nil)
    {
        UIImageView* pauseOrPlayImageView= [sliderPopUpView viewWithTag:226];
        if([pauseOrPlayImageView.image isEqual:[UIImage imageNamed:@"Play"]] && ![touch.view isDescendantOfView:sliderPopUpView])
        {

            return YES;
        }
        if([pauseOrPlayImageView.image isEqual:[UIImage imageNamed:@"Pause"]] && ![touch.view isDescendantOfView:sliderPopUpView])
        {
            return NO;
        }
        if ([touch.view isDescendantOfView:sliderPopUpView])
        {
            
            return NO;
        }
    }
    
    return YES; // handle the touch
}
-(void)updateSliderTime:(id)sender
{
    audioRecordSlider.value = player.currentTime;


}
-(void)dismissPopView:(id)sender
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];

    
}
-(void)dismissPlayerView:(id)sender
{
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:222];
    if ([popUpView isKindOfClass:[UIView class]])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
    }

}
-(void)sliderValueChanged
{
    player.currentTime = audioRecordSlider.value;
    
}
- (IBAction)transferDictationButtonClicked:(id)sender
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        moreButton.userInteractionEnabled=NO;

    if ([self.selectedView isEqualToString:@"Today's Transferred"])
    {
        alertController = [UIAlertController alertControllerWithTitle:RESEND_MESSAGE
                                                              message:@""
                                                       preferredStyle:UIAlertControllerStyleAlert];
        actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
                            APIManager* app=[APIManager sharedManager];
                            NSString* date=[app getDateAndTimeString];
                            //NSDictionary* audiorecordDict= [app.todaysFileTransferNamesArray objectAtIndex:self.selectedRow];
                            NSString* filName=[audiorecordDict valueForKey:@"RecordItemName"];
                            [transferDictationButton setHidden:YES];
                            [deleteDictationButton setHidden:YES];
                            
                            [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                            int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                            [[Database shareddatabase] updateAudioFileUploadedStatus:@"Resend" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                
                                

                                if ([AppPreferences sharedAppPreferences].isReachable)
                                {
                                    [AppPreferences sharedAppPreferences].fileUploading=YES;
                                }
                                [app uploadFileToServer:filName];
//                                [self dismissViewControllerAnimated:YES completion:nil];
                                
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
        
        
     
        
    
    }
    else
        if ([self.selectedView isEqualToString:@"Awaiting transfer"])
//for incomplete and failed transfer please recheck
    {
    
    alertController = [UIAlertController alertControllerWithTitle:TRANSFER_MESSAGE
                                                          message:@""
                                                   preferredStyle:UIAlertControllerStyleAlert];
    actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        APIManager* app=[APIManager sharedManager];
                        
                        NSString* filName=[audiorecordDict valueForKey:@"RecordItemName"];
                        [transferDictationButton setHidden:YES];
                        [deleteDictationButton setHidden:YES];
                        [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                        if ([AppPreferences sharedAppPreferences].isReachable)
                        {
                            [AppPreferences sharedAppPreferences].fileUploading=YES;
                        }

                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                                                       [app uploadFileToServer:filName];
                            //[self dismissViewControllerAnimated:YES completion:nil];

                            
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
        
        
     }
        
        else
            if ([self.selectedView isEqualToString:@"Transfer Failed"])                //for incomplete and failed transfer please recheck
            {
                
                alertController = [UIAlertController alertControllerWithTitle:TRANSFER_MESSAGE
                                                                      message:@""
                                                               preferredStyle:UIAlertControllerStyleAlert];
                actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                                    APIManager* app=[APIManager sharedManager];
                                    NSString* date=[app getDateAndTimeString];

                                    NSString* filName=[audiorecordDict valueForKey:@"RecordItemName"];
                                    [transferDictationButton setHidden:YES];
                                    [deleteDictationButton setHidden:YES];
                                    
                                    [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                                    int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                                    
                                    [[Database shareddatabase] updateAudioFileUploadedStatus:@"ResendFailed" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                                    
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        
                                       

                                       
                                        [app uploadFileToServer:filName];
                                     //   [self dismissViewControllerAnimated:YES completion:nil];

                                        
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
                
                
            }
        
        else
        {
            alertController = [UIAlertController alertControllerWithTitle:TRANSFER_MESSAGE
                                                                  message:@""
                                                           preferredStyle:UIAlertControllerStyleAlert];
            actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                            {
                                APIManager* app=[APIManager sharedManager];
                                
                                NSString* filName=[audiorecordDict valueForKey:@"RecordItemName"];
                                NSString* date=[app getDateAndTimeString];

                                [transferDictationButton setHidden:YES];
                                [deleteDictationButton setHidden:YES];
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    
                                    [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                                    
                                    NSString* transferStatus=[audiorecordDict valueForKey:@"TransferStatus"];
                                    if ([transferStatus isEqualToString:@"Transferred"])
                                    {
                                        int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                                        
                                        [[Database shareddatabase] updateAudioFileUploadedStatus:@"Resend" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                                    }
                                    if ([AppPreferences sharedAppPreferences].isReachable)
                                    {
                                        [AppPreferences sharedAppPreferences].fileUploading=YES;
                                    }
                                    [app uploadFileToServer:filName];
                                    //[self dismissViewControllerAnimated:YES completion:nil];
                                    
                                    
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
            

        }

     [self presentViewController:alertController animated:YES completion:nil];
    
        
        
        
    }
    
    
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
 
    
    
   // [self dismissViewControllerAnimated:YES completion:nil];
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
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME_COPY];
    DepartMent *deptObj1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME];
    [popupView removeFromSuperview];
}

-(void)save:(id)sender
{
    
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    //[[NSUserDefaults standardUserDefaults] setObject:data1 forKey:SELECTED_DEPARTMENT_NAME_COPY];
    
    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    UILabel* transferredByLabel= [self.view viewWithTag:503];
    transferredByLabel.text=deptObj.departmentName;
    UILabel* filenameLabel=[self.view viewWithTag:501];
    [[Database shareddatabase] updateDepartment:deptObj.Id fileName:filenameLabel.text];

//    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME_COPY];
//    DepartMent *deptObj1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    NSLog(@"%ld",deptObj1.Id);
//    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME];

    [popupView removeFromSuperview];
}



-(void)hideTableView
{
    
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:504] removeFromSuperview];//
}



//-(void)uploadFileToServer:(NSString*)str
//
//{
//    
//    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
//                          [NSString stringWithFormat:@"Documents/%@/%@.m4a",AUDIO_FILES_FOLDER_NAME,str] ];
//
//    
//        NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, FILE_UPLOAD_API]];
//        
//        NSString *boundary = [self generateBoundaryString];
//        
//        NSDictionary *params = @{@"filename"     : str,
//                                 };
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//        [request setHTTPMethod:@"POST"];
//
//        long filesizelong=[[APIManager sharedManager] getFileSize:filePath];
//        int filesizeint=(int)filesizelong;
//    
//        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
//        DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];//    if ([[[NSUserDefaults standardUserDefaults]
//    
//        NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%ld*%d*%d",MAC_ID,filesizeint,deptObj.Id,1,0];
//        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
//        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
//   
//        [request setValue:authorisation forHTTPHeaderField:@"Authorization"];
//
//        // create body
//        
//        NSData *httpBody = [self createBodyWithBoundary:boundary parameters:params paths:@[filePath] fieldName:str];
//        
//        request.HTTPBody = httpBody;
//
//        
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//            if (connectionError)
//            {
//                NSLog(@"error = %@", connectionError);
//                return;
//            }
//            
//            NSError* error;
//            result = [NSJSONSerialization JSONObjectWithData:data
//                                                     options:NSJSONReadingAllowFragments
//                                                       error:&error];
//            
//            NSString* returnCode= [result valueForKey:@"code"];
//            
//            if ([returnCode longLongValue]==200)
//            {
//                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:@"File uploaded successfully" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//                
//                
//            }
//            
//        }];
//        
//        
//      
//    
//    
//}
//
//
//
//- (NSData *)createBodyWithBoundary:(NSString *)boundary
//                        parameters:(NSDictionary *)parameters
//                             paths:(NSArray *)paths
//                         fieldName:(NSString *)fieldName
//{
//    NSMutableData *httpBody = [NSMutableData data];
//    
//    // add params (all params are strings)
//    
//    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
//        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
//        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
//    }];
//    
//    // add image data
//    
//    for (NSString *path in paths)
//    {
//        NSString *filename  = [path lastPathComponent];
//        NSData   *data      = [NSData dataWithContentsOfFile:path];
//        NSString *mimetype  = [self mimeTypeForPath:path];
//        
//        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
//        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
//        [httpBody appendData:data];
//        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    }
//    
//    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    return httpBody;
//}
//
//
//- (NSString *)mimeTypeForPath:(NSString *)path
//{
//    // get a mime type for an extension using MobileCoreServices.framework
//    
//    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
//    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
//    assert(UTI != NULL);
//    
//    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
//    
//    assert(mimetype != NULL);
//    
//    CFRelease(UTI);
//    
//    return mimetype;
//}
//
//
//- (NSString *)generateBoundaryString
//{
//    return [NSString stringWithFormat:@"*%@", [[NSUUID UUID] UUIDString]];
//    //return [NSString stringWithFormat:@"*"];
//
//}
//


//-(void)prepareAudioPlayer
//{
//    if (!IMPEDE_PLAYBACK)
//    {
//        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayback];
//    }
//    [recorder stop];
//    NSError *audioError;
//    
//    NSArray* pathComponents = [NSArray arrayWithObjects:
//                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
//                               AUDIO_FILES_FOLDER_NAME,
//                               [NSString stringWithFormat:@"%@.m4a", existingAudioFileName],
//                               nil];
//    
//    recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
//    
//    player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordedAudioURL error:&audioError];
//    audioRecordSlider.maximumValue = player.duration;
//    player.currentTime = audioRecordSlider.value;
//    
//    player.delegate = self;
//    [player prepareToPlay];
//    
//}

@end
