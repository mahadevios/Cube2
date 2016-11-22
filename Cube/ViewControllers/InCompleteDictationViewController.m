//
//  InCompleteDictationViewController.m
//  Cube
//
//  Created by mac on 04/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "InCompleteDictationViewController.h"
#import "InCompleteRecordViewController.h"
#import "RecordViewController.h"
@interface InCompleteDictationViewController ()

@end

@implementation InCompleteDictationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    app=[APIManager sharedManager];
    db=[Database shareddatabase];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([AppPreferences sharedAppPreferences].recordNew)
    {
        RecordViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
        //recordingNew=YES;
        [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"dismiss"];
        [AppPreferences sharedAppPreferences].recordNew=NO;
        [self presentViewController:vc animated:YES completion:nil];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"dismiss"];

    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    
    self.navigationItem.title=@"Incomplete Dictation(s)";
    app.inCompleteFileTransferNamesArray=[db getListOfFileTransfersOfStatus:@"RecordingPause"];
    [self.tableView reloadData];
   // NSLog(@"%lu",(unsigned long)app.inCompleteFileTransferNamesArray.count);
    
    UIViewController *alertViewController = [self.tabBarController.viewControllers objectAtIndex:3];
    
    alertViewController.tabBarItem.badgeValue = [[NSUserDefaults standardUserDefaults] valueForKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    }
}
-(void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return app.inCompleteFileTransferNamesArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary* awaitingFileTransferDict= [app.inCompleteFileTransferNamesArray objectAtIndex:indexPath.row];
    
    UILabel* recordItemName=[cell viewWithTag:101];
    recordItemName.text=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
    
    NSString* dateAndTimeString=[awaitingFileTransferDict valueForKey:@"RecordCreatedDate"];
    NSArray* dateAndTimeArray=[dateAndTimeString componentsSeparatedByString:@" "];
    
    
    UILabel* recordingDurationLabel=[cell viewWithTag:102];
    int audioMinutes= [[awaitingFileTransferDict valueForKey:@"CurrentDuration"] intValue]/60;
    int audioSeconds= [[awaitingFileTransferDict valueForKey:@"CurrentDuration"] intValue]%60;
    
    recordingDurationLabel.text=[NSString stringWithFormat:@"%02d:%02d",audioMinutes,audioSeconds];
  //  NSLog(@"%@",recordingDurationLabel.text);
    
    UILabel* departmentNameLabel=[cell viewWithTag:103];
    departmentNameLabel.text=[awaitingFileTransferDict valueForKey:@"Department"];
    
    UILabel* dateLabel=[cell viewWithTag:104];
    dateLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:0]];
    
    UILabel* timeLabel=[cell viewWithTag:105];
    timeLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]];
    
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    UITableViewCell* cell= [tableView cellForRowAtIndexPath:indexPath];
    UILabel* fileNameLabel=[cell viewWithTag:101];
    UILabel* recordingDurationLabel=[cell viewWithTag:102];
    UILabel* nameLabel=[cell viewWithTag:103];
    UILabel* dateLabel=[cell viewWithTag:104];
    
    
    InCompleteRecordViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InCompleteRecordViewController"];
    vc.existingAudioFileName=fileNameLabel.text;
    vc.audioDuration=recordingDurationLabel.text;
    vc.existingAudioDepartmentName=nameLabel.text;
    vc.existingAudioDate=dateLabel.text;
    [self presentViewController:vc animated:YES completion:nil];
   
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
