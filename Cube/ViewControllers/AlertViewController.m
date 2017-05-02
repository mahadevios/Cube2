//
//  AlertViewController.m
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "AlertViewController.h"
#import "PopUpCustomView.h"
@interface AlertViewController ()

@end

@implementation AlertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    db=[Database shareddatabase];
    app=[APIManager sharedManager];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideHud) name:NOTIFICATION_FILE_IMPORTED object:nil];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"More"] style:UIBarButtonItemStylePlain target:self action:@selector(showUserSettings:)];
    //badgeCount= [db getCountOfTransfersOfDicatationStatus:@"RecordingPause"];
    // [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",badgeCount] forKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    self.navigationItem.title=@"Alert";
    app.incompleteFileTransferCount= [db getCountOfTransfersOfDicatationStatus:@"RecordingPause"];
    [[Database shareddatabase] getlistOfimportedFilesAudioDetailsArray:5];

    [self.tableView reloadData];
    
    [self.tabBarController.tabBar setHidden:NO];
    
    [self showTabBadge];
    
//    if ([AppPreferences sharedAppPreferences].isImporting)
//    {
//        [self showhud];
//    }
    
    
}


-(void)showTabBadge
{
    int count= [[Database shareddatabase] getCountOfTransfersOfDicatationStatus:@"RecordingPause"];
    
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

//-(void)showhud
//{
//    hud.minSize = CGSizeMake(150.f, 100.f);
//    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.label.text = @"Importing Files..";
//    hud.detailsLabel.text = @"Please wait";
//
//}

-(void)hideHud
{
    [hud removeFromSuperview];
    
    [AppPreferences sharedAppPreferences].isImporting = NO;
    
    [self showTabBadge];
    
    [self.tableView reloadData];



}
-(void)showUserSettings:(id)sender
{
    
    NSArray* subViewArray=[NSArray arrayWithObjects:@"User Settings", nil];
    UIView* pop=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-170, self.view.frame.origin.y+20, 160, 40) andSubViews:subViewArray :self];
    [[[UIApplication sharedApplication] keyWindow] addSubview:pop];
    
}

-(void)UserSettings
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    [self.navigationController presentViewController:[self.storyboard  instantiateViewControllerWithIdentifier:@"UserSettingsViewController"] animated:YES completion:nil];
}

-(void)dismissPopView:(id)sender
{
    
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:111];
    if ([popUpView isKindOfClass:[UIView class]])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UILabel* inCompleteDictationLabel=[cell viewWithTag:101];
    UILabel* noDictationLabel=[cell viewWithTag:102];
    if (indexPath.row==0)
    {
        inCompleteDictationLabel.text=@"Incomplete Dictations";
        noDictationLabel.text=[NSString stringWithFormat:@"%d",app.incompleteFileTransferCount];
    }
    else
        if (indexPath.row==1)
    {
        inCompleteDictationLabel.text=@"No Dictation";
        noDictationLabel.text=@"0";
    }
    else
    {
        inCompleteDictationLabel.text=@"Imported Dictations";
        noDictationLabel.text=[NSString stringWithFormat:@"%ld",[AppPreferences sharedAppPreferences].importedFilesAudioDetailsArray.count];

    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //MainTabBarViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarViewController"];
    if (indexPath.row==0)
    {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"InCompleteDictationViewController"] animated:YES];
    }
    if (indexPath.row==2)
    {
       // [self.navigationController presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ImportedAudioViewController"] animated:YES completion:nil];
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ImportedAudioViewController"] animated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    
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
