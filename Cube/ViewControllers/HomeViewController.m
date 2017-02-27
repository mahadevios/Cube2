//
//  HomeViewController.m
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "HomeViewController.h"
#import "TransferListViewController.h"
#import "PopUpCustomView.h"
#import "AlertViewController.h"
#import "NSData+AES256.h"

//#import <iTunesLibrary/ITLibrary.h>


@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize transferredView,transferFailedView,awaitingTransferView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    app.awaitingFileTransferNamesArray=[[NSMutableArray alloc]init];
    db=[Database shareddatabase];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
        //[{"macid":"e0:2c:b2:ec:5a:8f"}]
    //NSLog(@"%@",NSHomeDirectory());
    //[db insertDepartMentData];
    
//    NSString* str=@"Hello mahadev";
//    NSData* data=[str dataUsingEncoding:NSUTF8StringEncoding];
//    NSData* encr=[data AES256EncryptWithKey:@"mahadev"];
//    
//    NSData* str1= [encr AES256DecryptWithKey:@"mahadev"];
//    
//    NSString* df=[[NSString alloc]initWithData:str1 encoding:NSUTF8StringEncoding];
    [AppPreferences sharedAppPreferences].isRecordView=NO;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"More"] style:UIBarButtonItemStylePlain target:self action:@selector(showUserSettings:)];
    transferFailedView.layer.cornerRadius=4.0f;
    transferredView.layer.cornerRadius=4.0f;
    awaitingTransferView.layer.cornerRadius=4.0f;
    
    tapRecogniser=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showList:)];
    tapRecogniser1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showList:)];
    tapRecogniser2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showList:)];
    [transferredView addGestureRecognizer:tapRecogniser];
    [awaitingTransferView addGestureRecognizer:tapRecogniser1];
    [transferFailedView addGestureRecognizer:tapRecogniser2];
    [self getCounts];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getCounts) name:NOTIFICATION_FILE_UPLOAD_API
                                               object:nil];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
//    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//        if (granted) {
//            NSLog(@"granted");
//        } else {
//            NSLog(@"denied");
//            
//            
//            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Microphone Access Denied" withMessage:@"You must allow microphone access in Settings > Privacy > Microphone" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//          //  [alert show];
//        }
//    }];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd-yyyy";
    NSString* todaysDate = [formatter stringFromDate:[NSDate date]];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:PURGE_DATA_DATE]== NULL)
    {
       
        [self deleteDictation];
    }
    else
    if (!([[[NSUserDefaults standardUserDefaults] valueForKey:PURGE_DATA_DATE] isEqualToString:todaysDate]))
    {
        [self deleteDictation];
       // [[NSUserDefaults standardUserDefaults] setValue:todaysDate forKey:PURGE_DATA_DATE];


    }
  //  [[NSUserDefaults standardUserDefaults] setValue:NULL forKey:PURGE_DATA_DATE];

     [self.tabBarController.tabBar setHidden:NO];
//    [[Database shareddatabase] setDepartment];//to insert default department for imported files
}
- (void)deleteDictation
{
    
    
   NSArray* filesToBePurgedArray = [[Database shareddatabase] getFilesToBePurged];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd-yyyy";
    NSString* todaysDate = [formatter stringFromDate:[NSDate date]];
    
    if (filesToBePurgedArray>0)
    {
        alertController = [UIAlertController alertControllerWithTitle:@"Purge old dictations?"
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
        actionDelete = [UIAlertAction actionWithTitle:@"Purge"
                                                style:UIAlertActionStyleDestructive
                                              handler:^(UIAlertAction * action)
                        {
                            for (int i=0; i< filesToBePurgedArray.count; i++)
                            {
                          
                            
                            NSString* fileName = [filesToBePurgedArray objectAtIndex:i];
                            NSString* dateAndTimeString = [app getDateAndTimeString];
                            [db updateAudioFileStatus:@"RecordingDelete" fileName:fileName dateAndTime:dateAndTimeString];
                            [app deleteFile:[NSString stringWithFormat:@"%@backup",fileName]];
                            BOOL delete= [[APIManager sharedManager] deleteFile:fileName];
                            
                                
                            [[NSUserDefaults standardUserDefaults] setValue:todaysDate forKey:PURGE_DATA_DATE];

//                            if (delete)
//                            {
                                [self dismissViewControllerAnimated:YES completion:nil];
                           // }
                            }
                        }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionDelete];
        
        
        actionCancel = [UIAlertAction actionWithTitle:@"Later"
                                                style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction * action)
                        {
                           
                                               //NSLog(@"Reachable");
                                               
                                               [alertController dismissViewControllerAnimated:YES completion:nil];
                                               [[NSUserDefaults standardUserDefaults] setValue:todaysDate forKey:PURGE_DATA_DATE];
// [[NSUserDefaults standardUserDefaults] setValue:NULL forKey:PURGE_DATA_DATE];
                            
                            
                        }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionCancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    

    
}

-(void)getCounts
{
  
    app=[APIManager sharedManager];
    app.awaitingFileTransferCount= [db getCountOfTransfersOfDicatationStatus:@"RecordingComplete"];
    app.todaysFileTransferCount=[db getCountOfTodaysTransfer:[app getDateAndTimeString]];
    app.transferFailedCount=[db getCountOfTransferFailed];
    
    UITextField* awaitingFileTransferCountTextFiled=[self.view viewWithTag:502];
    awaitingFileTransferCountTextFiled.text=[NSString stringWithFormat:@"%d",app.awaitingFileTransferCount];
    
    UITextField* todaysFileTransferCountTextFiled=[self.view viewWithTag:501];
    todaysFileTransferCountTextFiled.text=[NSString stringWithFormat:@"%d",app.todaysFileTransferCount];
    
    UITextField* transferFailedCountTextFiled=[self.view viewWithTag:503];
    transferFailedCountTextFiled.text=[NSString stringWithFormat:@"%d",app.transferFailedCount];
    
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

-(void)showUserSettings:(id)sender
{
    [self addPopView];
}


-(void)addPopView
{
    //    tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissPopView:)];
    //
    //    overlayView=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //
    //    [overlayView addGestureRecognizer:tap];
    //    overlayView.tag=111;
    //
    //    overlayView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.1];
    //
    //    UIView* popUpView=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-170, self.view.frame.origin.y+20, 160, 80)];
    //    popUpView.backgroundColor=[UIColor whiteColor];
    //
    //    UIButton* userSettingsButton=[[UIButton alloc]initWithFrame:CGRectMake(20, 12, 100, 20)];
    //    [userSettingsButton setTitle:@"User Settings" forState:UIControlStateNormal];
    //    [userSettingsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    userSettingsButton.titleLabel.font=[UIFont systemFontOfSize:14];
    //    [userSettingsButton addTarget:self action:@selector(selectSetting:) forControlEvents:UIControlEventTouchUpInside];
    //    [popUpView addSubview:userSettingsButton];
    //
    //    UIButton* logoutButton=[[UIButton alloc]initWithFrame:CGRectMake(userSettingsButton.frame.origin.x, userSettingsButton.frame.origin.x+userSettingsButton.frame.size.height+10, 100, 20)];
    //    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    //    [logoutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    logoutButton.titleLabel.font=[UIFont systemFontOfSize:14];
    //    [logoutButton addTarget:self action:@selector(selectSetting:) forControlEvents:UIControlEventTouchUpInside];
    //    [popUpView addSubview:logoutButton];
    //
    //    [overlayView addSubview:popUpView];
    //    [[[UIApplication sharedApplication] keyWindow] addSubview:overlayView];
    
    NSArray* subViewArray=[NSArray arrayWithObjects:@"User Settings",@"Logout", nil];
    UIView* pop=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-175, self.view.frame.origin.y+20, 160, 80) andSubViews:subViewArray :self];
    [[[UIApplication sharedApplication] keyWindow] addSubview:pop];
    
    
}
-(void)UserSettings
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    [self.navigationController presentViewController:[self.storyboard  instantiateViewControllerWithIdentifier:@"UserSettingsViewController"] animated:YES completion:nil];
}



-(void)Logout
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    [AppPreferences sharedAppPreferences].userObj = nil;

   // LoginViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
   UIViewController* vc= [self.storyboard  instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    //[[[UIApplication sharedApplication] keyWindow] setRootViewController:nil];
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:vc];

   // [[[[UIApplication sharedApplication] keyWindow] setRootViewController:[self.storyboard  instantiateViewControllerWithIdentifier:@"LoginViewController"] animated:YES completion:nil] ];
   // [[UIApplication sharedApplication] keyWindow] setRootViewController:[self.storyboard  instantiateViewControllerWithIdentifier:@"LoginViewController"] animated:YES completion:nil] ;
    
}
-(void)dismissPopView:(id)sender
{
    
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:111];
    if ([popUpView isKindOfClass:[UIView class]])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    }
    
}

-(void)showList:(UITapGestureRecognizer*)sender
{
    TransferListViewController* vc=[self.storyboard instantiateViewControllerWithIdentifier:@"TransferListViewController"];
    //app=[APIManager sharedManager];
    if (sender==tapRecogniser)
    {
        vc.currentViewName=@"Today's Transferred";
    }
    if (sender==tapRecogniser1)
    {
        vc.currentViewName=@"Awaiting Transfer";
        
    }
    if (sender==tapRecogniser2)
    {
        vc.currentViewName=@"Transfer Failed";
    }
    [self.navigationController pushViewController:vc animated:YES];
    
    //NSLog(@"%@",self.tabBarController);
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
