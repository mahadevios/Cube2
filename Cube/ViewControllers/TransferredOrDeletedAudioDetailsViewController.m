//
//  TransferredOrDeletedAudioDetailsViewController.m
//  Cube
//
//  Created by mac on 29/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "TransferredOrDeletedAudioDetailsViewController.h"
#import "PopUpCustomView.h"
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"

#define IMPEDE_PLAYBACK NO

@interface TransferredOrDeletedAudioDetailsViewController ()
{
    AVAudioPlayer       *player;
}

@end

@implementation TransferredOrDeletedAudioDetailsViewController
@synthesize listSelected,selectedRow,resendButton,deleteDictationButton,moreButton;
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
    resendButton.layer.cornerRadius=4.0f;
    deleteDictationButton.layer.cornerRadius=4.0f;
    
    UILabel* filenameLabel=[self.view viewWithTag:501];
    //UILabel* dictatedByLabel=[self.view viewWithTag:502];
    UILabel* departmentLabel=[self.view viewWithTag:503];
    UILabel* dictatedOnLabel=[self.view viewWithTag:504];
    UILabel* transferStatusLabel=[self.view viewWithTag:505];
    UILabel* transferDateLabel=[self.view viewWithTag:506];

    // UILabel* transferDateLabel=[self.view viewWithTag:506];
    APIManager* app=[APIManager sharedManager];
    if (self.listSelected==0)
    {
      audiorecordDict= [app.transferredListArray objectAtIndex:selectedRow];
        transferStatusLabel.text=[NSString stringWithFormat:@"Transferred,%@",[audiorecordDict valueForKey:@"status"]];//if selected list is Transferred then we have status=Transferred ,only fetch delete status append it to transferStatusLabel


    }
    if (self.listSelected==1)
    {
        [resendButton setHidden:YES];
        [deleteDictationButton setHidden:YES];
        audiorecordDict= [app.deletedListArray objectAtIndex:selectedRow];
        transferStatusLabel.text=[NSString stringWithFormat:@"Deleted,%@",[audiorecordDict valueForKey:@"status"]];//if selected list is delete then we have status=deleted ,only fetch transfer status append it to transferStatusLabel

    }
    
    filenameLabel.text=[audiorecordDict valueForKey:@"RecordItemName"];
    dictatedOnLabel.text=[audiorecordDict valueForKey:@"RecordCreateDate"];
    departmentLabel.text=[audiorecordDict valueForKey:@"Department"];
    transferDateLabel.text=[audiorecordDict valueForKey:@"TransferDate"];

    //transferStatusLabel.text=[audiorecordDict valueForKey:@"TransferStatus"];
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
    [UIApplication sharedApplication].idleTimerDisabled = NO
    ;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME_COPY];
    DepartMent *deptObj1 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"%ld",deptObj1.Id);
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME];

}
- (IBAction)backButtonPressed:(id)sender
{
    [player stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
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

- (IBAction)playRecordingButtonPressed:(id)sender
{
    if (self.listSelected==1)
    {
        
        alertController = [UIAlertController alertControllerWithTitle:@"File does not exist"
                                                              message:@""
                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        actionCancel = [UIAlertAction actionWithTitle:@"Ok"
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
        UIView * overlay=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.05, self.view.center.y-40, self.view.frame.size.width*0.9, 80) senderNameForSlider:self player:player];
        //     UIView* overlay=   [obj initWithFrame:CGRectMake(self.view.frame.size.width*0.05, self.view.center.y, self.view.frame.size.width*0.9, 80) senderNameForSlider:self player:player];
        [[[UIApplication sharedApplication] keyWindow] addSubview:overlay];
        
        sliderPopUpView=  [overlay viewWithTag:223];
        audioRecordSlider=  [sliderPopUpView viewWithTag:224];
        
        UIImageView* pauseOrPlayImageView= [sliderPopUpView viewWithTag:226];
        UILabel* dateAndTimeLabel=[sliderPopUpView viewWithTag:225];
        dateAndTimeLabel.text=[audiorecordDict valueForKey:@"RecordCreateDate"];
        pauseOrPlayImageView.image=[UIImage imageNamed:@"Pause"];
        NSString* filName=[audiorecordDict valueForKey:@"RecordItemName"];
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
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    UIImageView* pauseOrImageView= [sliderPopUpView viewWithTag:226];
    pauseOrImageView.image=[UIImage imageNamed:@"Play"] ;
    
    [player stop];
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:222];
    if ([popUpView isKindOfClass:[UIView class]])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
    }
 //   [UIApplication sharedApplication].idleTimerDisabled = NO;

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
-(void)dismissPopView:(id)sender
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    
    
}
-(void)updateSliderTime:(id)sender
{
    audioRecordSlider.value = player.currentTime;
}

-(void)dismissPlayerView:(id)sender
{
    //    if (moreButtonPressed)
    //    {
    //        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    //        moreButtonPressed=NO;
    //    }
    //else
    //{
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:222];
    if ([popUpView isKindOfClass:[UIView class]])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
    }
    //}
    
}
-(void)sliderValueChanged
{
    player.currentTime = audioRecordSlider.value;
    
}

- (IBAction)deleteRecordinfButtonPressed:(id)sender
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

- (IBAction)resendButtonClckied:(id)sender
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        moreButton.userInteractionEnabled=NO;

    alertController = [UIAlertController alertControllerWithTitle:RESEND_MESSAGE
                                                          message:@""
                                                   preferredStyle:UIAlertControllerStyleAlert];
    actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        APIManager* app=[APIManager sharedManager];
                       NSString* date= [app getDateAndTimeString];
                        NSDictionary* audiorecordDic= [app.transferredListArray objectAtIndex:self.selectedRow];
                        NSString* filName=[audiorecordDic valueForKey:@"RecordItemName"];
                        [resendButton setHidden:YES];
                        [deleteDictationButton setHidden:YES];
                        
//                        dispatch_async(dispatch_get_main_queue(), ^
//                                       {
                                           //NSLog(@"Reachable");
                                           [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:filName];
                                           int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:filName];
                                           
                                           [[Database shareddatabase] updateAudioFileUploadedStatus:@"Resend" fileName:filName dateAndTime:date mobiledictationidval:mobileDictationIdVal];
                                       
                                       //});
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                            
                            
                            [app uploadFileToServer:filName jobName:FILE_UPLOAD_API];
                            
                           // [self dismissViewControllerAnimated:YES completion:nil];

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


-(void)hideTableView
{
    
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:504] removeFromSuperview];//
}


@end
