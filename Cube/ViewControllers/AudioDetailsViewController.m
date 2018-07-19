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
#import "InCompleteRecordViewController.h"
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"

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
    

    if (self.splitViewController == nil)
    {
        self.backImageView.hidden = false;
        self.backButton.hidden = false;

    }
    else
        if(self.splitViewController.isCollapsed == false)
        {
            self.backImageView.hidden = true;
            self.backButton.hidden = false;

        }
    
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
    if (self.splitViewController.isCollapsed == false)
    {
        self.navigationController.navigationBar.hidden = true;
    }
    
   [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"dismiss"];
    
   if (![AppPreferences sharedAppPreferences].dismissAudioDetails && ![AppPreferences sharedAppPreferences].recordNew)
   {
    
    APIManager* app=[APIManager sharedManager];
    
    if (isDeleteEditTransferButtonsRemovedAfterTransfer == false)
    {
        [transferDictationButton setHidden:NO];
        
        [deleteDictationButton setHidden:NO];
    }
   
       
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
       
    transferDictationButton.layer.cornerRadius=4.0f;
       
    deleteDictationButton.layer.cornerRadius=4.0f;
       
    UILabel* filenameLabel=[self.view viewWithTag:501];
       
    UILabel* departmentLabel=[self.view viewWithTag:503];
       
    UILabel* dictatedOnLabel=[self.view viewWithTag:504];
       
    UILabel* transferStatusLabel=[self.view viewWithTag:505];
       
    UILabel* transferDateLabel=[self.view viewWithTag:506];
       
    UILabel* dictatedHeadingLabel=[self.view viewWithTag:2000];

    [[self.view viewWithTag:507] setHidden:YES];
    
    if ([self.selectedView isEqualToString:@"Awaiting Transfer"])
    {
        audiorecordDict = [app.awaitingFileTransferNamesArray objectAtIndex:self.selectedRow];
        
        if (![[audiorecordDict valueForKey:@"TransferStatus"] isEqualToString:@"TransferFailed"])
        {
            if (isDeleteEditTransferButtonsRemovedAfterTransfer == false)
            {
                [self addEditDeleteAndUploadButtons];

            }
        }
       
        
    }
    else
    if ([self.selectedView isEqualToString:@"Transferred Today"])
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
        //[transferDictationButton setTitle:@"Transfer Recording" forState:UIControlStateNormal];
        
        audiorecordDict = [[AppPreferences sharedAppPreferences].importedFilesAudioDetailsArray objectAtIndex:self.selectedRow];
        
        [[self.view viewWithTag:507] setHidden:NO];
        
        if (isDeleteEditTransferButtonsRemovedAfterTransfer == false)
        {
            [self addEditDeleteAndUploadButtons];
            
        }

    }
       
       
    if ([self.selectedView isEqualToString:@"Imported"])
    {
        filenameLabel.text= [[audiorecordDict valueForKey:@"RecordItemName"] stringByDeletingPathExtension];

        dictatedHeadingLabel.text=@"Imported On";
        
        [[self.view viewWithTag:507] setHidden:NO];

    }
    else
    {
     filenameLabel.text=[audiorecordDict valueForKey:@"RecordItemName"];
    }
       
    dictatedOnLabel.text=[audiorecordDict valueForKey:@"RecordCreatedDate"];
       
    departmentLabel.text=[audiorecordDict valueForKey:@"Department"];
       
    NSString* tarnsferStatus = [audiorecordDict valueForKey:@"TransferStatus"];
       
    if ([tarnsferStatus isEqualToString:@"TransferFailed"])
    {
        transferStatusLabel.text = @"Transfer Failed";
    }
    else if ([tarnsferStatus isEqualToString:@"NotTransferred"])
    {
        transferStatusLabel.text = @"Not Transferred";

    }
    else
    {
        transferStatusLabel.text = tarnsferStatus;
    }
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

    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
       
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME_COPY];

    DepartMent *deptObj = [[DepartMent alloc]init];
       
    long deptId= [[[Database shareddatabase] getDepartMentIdFromDepartmentName:departmentLabel.text] longLongValue];
    
    deptObj.Id=deptId;
       
    deptObj.departmentName=departmentLabel.text;
       
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:deptObj];
    
    [[NSUserDefaults standardUserDefaults] setObject:data1 forKey:SELECTED_DEPARTMENT_NAME];
       
    moreButton.userInteractionEnabled=YES;
       
   }
    else
    {
        if ([AppPreferences sharedAppPreferences].recordNew)
        {
            [AppPreferences sharedAppPreferences].recordNew = false;
            
            [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"] animated:YES completion:nil];
            
            [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"dismiss"];
        }
        else
        {
            [AppPreferences sharedAppPreferences].dismissAudioDetails = NO;

            [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:801] removeFromSuperview];//remove uploading buuton
            
            [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:802] removeFromSuperview];//remove delete button
            
            [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:803] removeFromSuperview];//remove edit button
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
}


-(void)addEditDeleteAndUploadButtons
{
    if (([[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:801] == nil))
    {
        UIButton* uploadRecordButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width*0.095, transferDictationButton.frame.origin.y, self.view.frame.size.width*0.83, transferDictationButton.frame.size.height)];
        
        uploadRecordButton.tag = 801;
        
        uploadRecordButton.backgroundColor=[UIColor colorWithRed:250/255.0 green:162/255.0 blue:27/255.0 alpha:1];
        
        [uploadRecordButton setTitle:@"Upload Recording" forState:UIControlStateNormal];
        
        uploadRecordButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        
        [uploadRecordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        uploadRecordButton.layer.cornerRadius=5.0f;
        
        [uploadRecordButton addTarget:self action:@selector(transferDictationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [[[self.view viewWithTag:900] viewWithTag:800] addSubview:uploadRecordButton];
        
        
        
        UIButton* deleteRecordButton = [[UIButton alloc]initWithFrame:CGRectMake(uploadRecordButton.frame.origin.x, uploadRecordButton.frame.origin.y+uploadRecordButton.frame.size.height+12, uploadRecordButton.frame.size.width*0.48, uploadRecordButton.frame.size.height)];
        
        deleteRecordButton.tag = 802;
        
        deleteRecordButton.backgroundColor=[UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
        
        [deleteRecordButton setTitle:@"Delete Recording" forState:UIControlStateNormal];
        
        deleteRecordButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        
        [deleteRecordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        deleteRecordButton.layer.cornerRadius=5.0f;
        
        [deleteRecordButton addTarget:self action:@selector(deleteRecording) forControlEvents:UIControlEventTouchUpInside];
        
        [[[self.view viewWithTag:900] viewWithTag:800] addSubview:deleteRecordButton];
        
        
        UIButton* editRecordButton=[[UIButton alloc]initWithFrame:CGRectMake(deleteRecordButton.frame.origin.x+deleteRecordButton.frame.size.width+uploadRecordButton.frame.size.width*0.04, deleteRecordButton.frame.origin.y,uploadRecordButton.frame.size.width*0.48, deleteRecordButton.frame.size.height)];
        
        editRecordButton.tag = 803;
        
        editRecordButton.backgroundColor=[UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1];
        
        [editRecordButton setTitle:@"Edit Recording" forState:UIControlStateNormal];
        
        editRecordButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        
        [editRecordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        editRecordButton.layer.cornerRadius=5.0f;
        
        [editRecordButton addTarget:self action:@selector(showEditRecordingView) forControlEvents:UIControlEventTouchUpInside];
        
//        NSArray* arr =  self.splitViewController.viewControllers;
        
         long viewWidth = self.splitViewController.primaryColumnWidth;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {//for ipad
            
            uploadRecordButton.frame = CGRectMake((self.view.frame.size.width-viewWidth)*0.1, transferDictationButton.frame.origin.y, (self.view.frame.size.width-viewWidth)*0.8, transferDictationButton.frame.size.height);
            
            deleteRecordButton.frame = CGRectMake((self.view.frame.size.width-viewWidth)*0.1, uploadRecordButton.frame.origin.y+uploadRecordButton.frame.size.height+10, uploadRecordButton.frame.size.width*0.48, transferDictationButton.frame.size.height);
            
            editRecordButton.frame = CGRectMake(deleteRecordButton.frame.origin.x+deleteRecordButton.frame.size.width+uploadRecordButton.frame.size.width*0.04, uploadRecordButton.frame.origin.y+uploadRecordButton.frame.size.height+10, uploadRecordButton.frame.size.width*0.48, transferDictationButton.frame.size.height);
            
//            uploadRecordButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
//            
//            deleteRecordButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
//            
//            editRecordButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
            
            
        }
        [[[self.view viewWithTag:900] viewWithTag:800] addSubview:editRecordButton];
    }
    
    
    [transferDictationButton removeFromSuperview];
    
    [deleteDictationButton removeFromSuperview];

}
-(void)viewWillDisappear:(BOOL)animated
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME_COPY];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME];
    
//    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    
//    DepartMent *deptObj1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];

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


- (IBAction)moreButtonClicked:(id)sender
{
    NSArray* subViewArray=[NSArray arrayWithObjects:@"Change Department", nil];
    
    UIView* pop=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-160, self.view.frame.origin.y+20, 160, 40) andSubViews:subViewArray :self];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:pop];
}

-(void)ChangeDepartment
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
    
    if (self.splitViewController.isCollapsed || self.splitViewController == nil)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else
    {
//        NSMutableArray* subVC = [[NSMutableArray alloc] initWithArray:[self.splitViewController viewControllers]];
//
//        [subVC removeLastObject];
        [self.navigationController popViewControllerAnimated:true];

        
    }
    
}

- (IBAction)deleteDictation:(id)sender
{
    
    [self deleteRecording];
    
}

-(void)deleteRecording
{
    alertController = [UIAlertController alertControllerWithTitle:@"Delete"
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
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:overlay1];

        sliderPopUpView=  [overlay1 viewWithTag:223];
        
        audioRecordSlider=  [sliderPopUpView viewWithTag:224];
        
        UIImageView* pauseOrPlayImageView= [sliderPopUpView viewWithTag:226];
        
        UILabel* dateAndTimeLabel=[sliderPopUpView viewWithTag:225];
        
        dateAndTimeLabel.text=[audiorecordDict valueForKey:@"RecordCreatedDate"];
       
        pauseOrPlayImageView.image=[UIImage imageNamed:@"Pause"];
    
        NSString* filName;
        

        filName=[audiorecordDict valueForKey:@"RecordItemName"];

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
      
//        [UIApplication sharedApplication].idleTimerDisabled = YES;

    }
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player1 successfully:(BOOL)flag
{
    UIImageView* pauseOrImageView= [sliderPopUpView viewWithTag:226];
    
    pauseOrImageView.image=[UIImage imageNamed:@"Play"] ;
    
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

    }
    else
    if ([pauseOrImageView.image isEqual:[UIImage imageNamed:@"Play"]])
    {
        pauseOrImageView.image=[UIImage imageNamed:@"Pause"] ;
        
        [player play];
        
//        [UIApplication sharedApplication].idleTimerDisabled = YES;

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


    if ([self.selectedView isEqualToString:@"Transferred Today"])
    {
        alertController = [UIAlertController alertControllerWithTitle:RESEND_MESSAGE
                                                              message:@""
                                                       preferredStyle:UIAlertControllerStyleAlert];
        actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
                           
                            APIManager* app = [APIManager sharedManager];
                            
                            NSString* date = [app getDateAndTimeString];
                            
                            NSString* filName = [audiorecordDict valueForKey:@"RecordItemName"];
                            
                            isDeleteEditTransferButtonsRemovedAfterTransfer = YES;
                            
                            [transferDictationButton setHidden:YES];
                            
                            [deleteDictationButton setHidden:YES];
                            
                            [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                            int mobileDictationIdVal = [[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                            
                            [[Database shareddatabase] updateAudioFileUploadedStatus:@"Resend" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                            
//                            NSLog(@"Today's Transferred after DB");
                            
                            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_CLICKED object:nil];
                                
                            }
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                
                                if ([AppPreferences sharedAppPreferences].isReachable)
                                {
                                    [AppPreferences sharedAppPreferences].fileUploading=YES;
                                }
                                
                                [app uploadFileToServer:filName jobName:FILE_UPLOAD_API];
                                
                                [[self.view viewWithTag:507] setHidden:YES];
                                
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
        if ([self.selectedView isEqualToString:@"Awaiting Transfer"])
        {
    
            alertController = [UIAlertController alertControllerWithTitle:TRANSFER_MESSAGE
                                                          message:@""
                                                   preferredStyle:UIAlertControllerStyleAlert];
            
            actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        
                        
                        APIManager* app = [APIManager sharedManager];
                        
                        NSString* filName = [audiorecordDict valueForKey:@"RecordItemName"];
                        
                        NSString* transferStatus = [audiorecordDict valueForKey:@"TransferStatus"];

                        [transferDictationButton setHidden:YES];
                        
                        [deleteDictationButton setHidden:YES];
                        
                        if ([AppPreferences sharedAppPreferences].isReachable)
                        {
                            [AppPreferences sharedAppPreferences].fileUploading=YES;
                        }
                        
                        if ([transferStatus isEqualToString:@"TransferFailed"])
                        {
                            int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                            
                            NSString* date=[app getDateAndTimeString];

                            [[Database shareddatabase] updateAudioFileUploadedStatus:@"ResendFailed" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                        }
                            [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];

                        isDeleteEditTransferButtonsRemovedAfterTransfer = YES;

                        
                            [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:801] removeFromSuperview];//remove uploading buuton
                           
                            [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:802] removeFromSuperview];//remove delete button
                            
                            [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:803] removeFromSuperview];//remove edit button
                        

                        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_CLICKED object:nil];
                            
                        }
                        

                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                                                       [app uploadFileToServer:filName jobName:FILE_UPLOAD_API];
            
                            
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
                                    
                                    isDeleteEditTransferButtonsRemovedAfterTransfer = YES;

                                   [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                                                       
                                   int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                                                       
                                   [[Database shareddatabase] updateAudioFileUploadedStatus:@"ResendFailed" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                                    
                                    
                                    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                                    {
                                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_CLICKED object:nil];
                                        
                                    }
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        
                                        [app uploadFileToServer:filName jobName:FILE_UPLOAD_API];
                                        
                                        [[self.view viewWithTag:507] setHidden:YES];
                                        
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
                                
                                                   [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:801] removeFromSuperview];//remove uploading buuton
                                                   [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:802] removeFromSuperview];//remove delete button
                                                   
                                                   [[[[self.view viewWithTag:900] viewWithTag:800] viewWithTag:803] removeFromSuperview];//remove edit button
                                
                                                    isDeleteEditTransferButtonsRemovedAfterTransfer = YES;

                                                   [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                                                   
                                                   NSString* transferStatus=[audiorecordDict valueForKey:@"TransferStatus"];
                                                   
                                                   if ([transferStatus isEqualToString:@"Transferred"])
                                                   {
                                                       int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                                                       
                                                       [[Database shareddatabase] updateAudioFileUploadedStatus:@"Resend" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                                                   }

                               
                                if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                                {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_CLICKED object:nil];
                                    
                                }
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    
                                    
                                    if ([AppPreferences sharedAppPreferences].isReachable)
                                    {
                                        [AppPreferences sharedAppPreferences].fileUploading=YES;
                                    }
                                    
                                    [app uploadFileToServer:filName jobName:FILE_UPLOAD_API];
                                    
                                    [[self.view viewWithTag:507] setHidden:YES];

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
    cell=[tableView cellForRowAtIndexPath:indexPath];
    
    UILabel* departmentNameLanel= [cell viewWithTag:indexPath.row+200];
    
    UIButton* radioButton=[cell viewWithTag:indexPath.row+100];
    
    DepartMent *deptObj = [[DepartMent alloc]init];
    
    long deptId= [[[Database shareddatabase] getDepartMentIdFromDepartmentName:departmentNameLanel.text] longLongValue];
    
    deptObj.Id=deptId;

    deptObj.departmentName=departmentNameLanel.text;
    
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:deptObj];
    
    [[NSUserDefaults standardUserDefaults] setObject:data1 forKey:SELECTED_DEPARTMENT_NAME];
    
    [radioButton setBackgroundImage:[UIImage imageNamed:@"RadioButton"] forState:UIControlStateNormal];
    
    [tableView reloadData];
    
}
-(void)cancel:(id)sender
{
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
    
    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    
    UILabel* transferredByLabel= [self.view viewWithTag:503];
    
    transferredByLabel.text=deptObj.departmentName;
    
    UILabel* filenameLabel=[self.view viewWithTag:501];
    
    [[Database shareddatabase] updateDepartment:deptObj.Id fileName:filenameLabel.text];

    [popupView removeFromSuperview];
    
}



-(void)hideTableView
{
    
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:504] removeFromSuperview];//
    
}
- (IBAction)editRecordingButtonPressed:(id)sender
{
    [self showEditRecordingView];
   
}

-(void)showEditRecordingView
{
    
    int audioHour= [[audiorecordDict valueForKey:@"CurrentDuration"] intValue]/(60*60);
    
    int audioHourByMod= [[audiorecordDict valueForKey:@"CurrentDuration"] intValue]%(60*60);
    
    int audioMinutes = audioHourByMod / 60;
    
    int audioSeconds = audioHourByMod % 60;
    
    NSString* audioDuration = [NSString stringWithFormat:@"%02d:%02d:%02d",audioHour,audioMinutes,audioSeconds];
    
    InCompleteRecordViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InCompleteRecordViewController"];
    
    vc.existingAudioFileName= [audiorecordDict valueForKey:@"RecordItemName"];
    
    vc.audioDuration = audioDuration;
    
    NSString* dataAndTime = [audiorecordDict valueForKey:@"RecordCreatedDate"];
    
    NSArray* dateAndTimeArray = [dataAndTime componentsSeparatedByString:@" "];
    
    if (dateAndTimeArray.count>0)
    {
        vc.existingAudioDate = [dateAndTimeArray objectAtIndex:0];
        
    }
    
    int audioDurationSeconds = [[audiorecordDict valueForKey:@"CurrentDuration"] intValue];
    
    //int roundUpAudioDurationSeconds = ceil(audioDurationSeconds);
    
    vc.audioDurationInSeconds = audioDurationSeconds;
    
    vc.existingAudioDepartmentName = [audiorecordDict valueForKey:@"Department"];
    
    vc.isOpenedFromAudioDetails = YES;
    
    [self presentViewController:vc animated:YES completion:nil];

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
