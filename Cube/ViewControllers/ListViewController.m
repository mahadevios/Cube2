 //
//  ListViewController.m
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "ListViewController.h"
#import "PopUpCustomView.h"
#import "TransferredOrDeletedAudioDetailsViewController.h"
@interface ListViewController ()

@end

@implementation ListViewController
@synthesize segment,checkedIndexPath,longPressAdded;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
//                                          initWithTarget:self action:@selector(handleLongPress:)];
//    lpgr.minimumPressDuration = 1.0; //seconds
//    lpgr.delegate = self;
 //   [self.tableView addGestureRecognizer:lpgr];
    
    // Do any additional setup after loading the view.
    
//    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
//    {
        self.currentViewName = @"List";
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 1.0; //seconds
        lpgr.delegate = self;
        [self.tableView addGestureRecognizer:lpgr];
        self.checkedIndexPath = [[NSMutableArray alloc] init];
   // }
    
    arrayOfMarked=[[NSMutableArray alloc]init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [segment setSelectedSegmentIndex:0];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"More"] style:UIBarButtonItemStylePlain target:self action:@selector(showUserSettings:)];
    
    self.navigationItem.title=@"List";
    
        Database* db=[Database shareddatabase];
        APIManager* app=[APIManager sharedManager];
    
    app.transferredListArray=[db getListOfTransferredOrDeletedFiles:@"Transferred"];
    app.deletedListArray=[db getListOfTransferredOrDeletedFiles:@"Deleted"];

    int count= [[Database shareddatabase] getCountOfTransfersOfDicatationStatus:@"RecordingPause"];
    
    [[Database shareddatabase] getlistOfimportedFilesAudioDetailsArray:5];//get count of imported non transferred files
    
    int importedFileCount=[AppPreferences sharedAppPreferences].importedFilesAudioDetailsArray.count;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",count+importedFileCount] forKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    
    NSString* alertCount=[[NSUserDefaults standardUserDefaults] valueForKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    
    UIViewController *alertViewController = [self.tabBarController.viewControllers objectAtIndex:ALERT_TAB_LOCATION];
    
    if ([alertCount isEqualToString:@"0"])
    {
        alertViewController.tabBarItem.badgeValue =nil;
    }
    else
        alertViewController.tabBarItem.badgeValue = [[NSUserDefaults standardUserDefaults] valueForKey:INCOMPLETE_TRANSFER_COUNT_BADGE];
    
    self.navigationItem.leftBarButtonItem = nil;
   // self.navigationItem.rightBarButtonItem = nil;
  //  self.navigationItem.title = @"List";
    [self.checkedIndexPath removeAllObjects];
    
    [arrayOfMarked removeAllObjects];
    isMultipleFilesActivated = NO;
    toolBarAdded = NO;
    
    
    [self.tableView reloadData];
    
    [self.tabBarController.tabBar setHidden:NO];

    
}


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (self.segment.selectedSegmentIndex==0)//if navigation title=@"somevalue" then only handle longpress

//    if (self.navigationItem.title==self.currentViewName)//if navigation title=@"somevalue" then only handle longpress
    {
    
        isMultipleFilesActivated = YES;
        APIManager* app=[APIManager sharedManager];
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        UITableViewCell* cell=[self.tableView cellForRowAtIndexPath:indexPath];
//        UILabel* deleteStatusLabel=[cell viewWithTag:105];
        
        
        if (cell.accessoryType == UITableViewCellAccessoryNone)
        {
            NSDictionary* awaitingFileTransferDict= [app.transferredListArray objectAtIndex:indexPath.row];
            NSString* fileName=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
            
            [self.checkedIndexPath addObject:fileName];
            [arrayOfMarked addObject:indexPath];
            [self hideAndShowUploadButton:YES];
            //[self hideAndShowLeftBarButton:YES];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            longPressAdded=YES;
        }
        
    }
}
- (void) hideAndShowUploadButton:(BOOL)isShown
{
    if (isShown)
    {
        self.navigationItem.title=@"";
        if (!toolBarAdded)
        {
            [self addToolbar];
            
        }
        
    }
    else
    {
        toolBarAdded=NO;
      //  self.navigationItem.title=self.currentViewName;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"More"] style:UIBarButtonItemStylePlain target:self action:@selector(showUserSettings:)];
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
        
    }
}
-(void)addToolbar
{
    toolBarAdded=YES;
    UIToolbar *tools = [[UIToolbar alloc]
                        initWithFrame:CGRectMake(30.0f, 10.0f, 150.0f, 44.01f)]; // 44.01 shifts it up 1px for some reason
    //tools.layer.borderWidth = 1;
    tools.tag=101;
    tools.layer.borderColor = [[UIColor whiteColor] CGColor];
    tools.clipsToBounds = YES;
    
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:5];
    // Create a standard refresh button.
    UIBarButtonItem *bi = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteMutipleFiles)];
    
    [buttons addObject:bi];
    
    //Create a spacer.
    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    bi.width = 12.0f;
    [buttons addObject:bi];
    
    
    // Add profile button.
   
    
    bi = [[UIBarButtonItem alloc]initWithTitle:@"Select all" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllFiles:)];
    bi.tag=102;
    [buttons addObject:bi];
    
    
    // Add buttons to toolbar and toolbar to nav bar.
    [tools setItems:buttons animated:NO];
    UIBarButtonItem *threeButtons = [[UIBarButtonItem alloc] initWithCustomView:tools];
    self.navigationItem.rightBarButtonItem = threeButtons;
    
    
    
    
    self.navigationItem.leftBarButtonItem=nil;
    //UIToolbar *tools1 = [[UIToolbar alloc]
    //                   initWithFrame:CGRectMake(-50.0f, 10.0f, 150.0f, 44.01f)]; // 44.01 shifts it up 1px for some reason
    UIToolbar *tools1 = [[UIToolbar alloc]
                         initWithFrame:CGRectMake(-70.0f, 0.0f, 80.0f, 44.01f)]; // 44.01 shifts it up 1px for some reason
    //tools.layer.borderWidth = 1;
    tools1.tag=101;
    tools1.layer.borderColor = [[UIColor whiteColor] CGColor];
    tools1.clipsToBounds = YES;
    
    NSMutableArray *buttons1 = [[NSMutableArray alloc] initWithCapacity:4];
    // Create a standard refresh button.
//    UIBarButtonItem *bi1 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
//    bi1.imageInsets=UIEdgeInsetsMake(0, -30, 0, 0);
//    [buttons1 addObject:bi1];
    
    //Create a spacer.
//     UIBarButtonItem *bi1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    bi1.width = 8.0f;
//    [buttons1 addObject:bi1];
    
    
    // Add profile button.
    selectedCountLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, 30, 20)];
    selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];
     UIBarButtonItem *bi1 = [[UIBarButtonItem alloc]initWithCustomView:selectedCountLabel];
    [buttons1 addObject:bi1];
    
    bi1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    bi1.width = -15.0f;
    [buttons1 addObject:bi1];
    
    bi1 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Check"] style:UIBarButtonItemStylePlain target:self action:nil];
    //bi1.imageInsets=UIEdgeInsetsMake(0, -30, 0, 0);
    [buttons1 addObject:bi1];
    
    
    // Add buttons to toolbar and toolbar to nav bar.
    [tools1 setItems:buttons1 animated:NO];
    UIBarButtonItem *threeButtons1 = [[UIBarButtonItem alloc] initWithCustomView:tools1];
    self.navigationItem.leftBarButtonItem = threeButtons1;
    
    int uploadFileCount=0;
    for (NSInteger i = 0; i < [APIManager sharedManager].transferredListArray.count; ++i)
    {
        NSIndexPath* indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell* cell= [self.tableView cellForRowAtIndexPath:indexPath];
        UILabel* deleteStatusLabel=[cell viewWithTag:105];
        if ([deleteStatusLabel.text isEqual:@"Uploading"])
        {
            ++uploadFileCount;
        }
    }
    if ([APIManager sharedManager].transferredListArray.count-uploadFileCount==1)
    {
        UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
        UIToolbar* view=  vc.customView;
        NSArray* arr= [view items];
        UIBarButtonItem* button= [arr objectAtIndex:2];
        //UIButton* button=  [view viewWithTag:102];
        
        [button setTitle:@"Deselect all"];
    }
    
    
    
}
-(void)deleteMutipleFiles
{
    alertController = [UIAlertController alertControllerWithTitle:@"Delete?"
                                                          message:DELETE_MESSAGE
                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    
    actionDelete = [UIAlertAction actionWithTitle:@"Delete"
                                            style:UIAlertActionStyleDestructive
                                          handler:^(UIAlertAction * action)
                    {
                        
                        for (int i=0; i<arrayOfMarked.count; i++)
                            
                        {
                            Database* db=[Database shareddatabase];
                            APIManager* app=[APIManager sharedManager];
                            NSString* dateAndTimeString=[app getDateAndTimeString];
                            NSIndexPath* indexPath=[arrayOfMarked objectAtIndex:i];
                            
                            NSDictionary* awaitingFileTransferDict= [app.transferredListArray objectAtIndex:indexPath.row];
                            NSString* fileName=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
                            self.navigationItem.title=self.currentViewName;
                            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"More"] style:UIBarButtonItemStylePlain target:self action:@selector(showUserSettings:)];;
                            self.navigationItem.leftBarButtonItem = nil;
//                            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
                            toolBarAdded=NO;
                            [db updateAudioFileStatus:@"RecordingDelete" fileName:fileName dateAndTime:dateAndTimeString];
                            [app deleteFile:fileName];
                            [app deleteFile:[NSString stringWithFormat:@"%@backup",fileName]];
                            
                            
                        }
                        [arrayOfMarked removeAllObjects];
                        [self.tableView reloadData];
                        
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionDelete];
    
    
    actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * action)
                    {
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                        
                        
                        self.navigationItem.title=self.currentViewName;
                        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"More"] style:UIBarButtonItemStylePlain target:self action:@selector(showUserSettings:)];
                        self.navigationItem.leftBarButtonItem = nil;

                        isMultipleFilesActivated=NO;
                        toolBarAdded=NO;
                        
                        [arrayOfMarked removeAllObjects];
                        [self.checkedIndexPath removeAllObjects];
                        [self.tableView reloadData];
                        
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

-(void)popViewController:(id)sender
{
    [self.tabBarController.tabBar setHidden:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)selectAllFiles:(UIBarButtonItem*)sender
{
    
    if ([sender.title isEqualToString:@"Select all"])
    {
        sender.title=@"Deselect all";
        [self.checkedIndexPath removeAllObjects];
        [arrayOfMarked removeAllObjects];
        APIManager* app=[APIManager sharedManager];
        Database* db=[Database shareddatabase];
        app.transferredListArray=[db getListOfTransferredOrDeletedFiles:@"Transferred"];
        
        for (NSInteger i = 0; i < app.transferredListArray.count; ++i)
        {
            NSIndexPath* indexPath= [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell* cell= [self.tableView cellForRowAtIndexPath:indexPath];
            NSDictionary* awaitingFileTransferDict= [app.transferredListArray objectAtIndex:i];
            NSString* fileName=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
            
            if (![[awaitingFileTransferDict valueForKey:@"DictationStatus"] isEqualToString:@"RecordingFileUpload"])
            {
                
                [arrayOfMarked addObject:indexPath];
                [cell setSelected:YES];
                [self.checkedIndexPath addObject:fileName];
                
            }
            selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];
            
        }
        

        [self.tableView reloadData];
    }
    else
    {
        sender.title=@"Select all";
      //  self.navigationItem.title=self.currentViewName;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"More"] style:UIBarButtonItemStylePlain target:self action:@selector(showUserSettings:)];
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
        isMultipleFilesActivated=NO;
        [self.checkedIndexPath removeAllObjects];
        [arrayOfMarked removeAllObjects];
        selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];
        
        toolBarAdded=NO;
        self.navigationItem.title = @"List";
        self.navigationItem.leftBarButtonItem = nil;
        [self.tableView reloadData];
        
        
    }
    
    
    
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
    [APIManager sharedManager].deletedListArray=[[Database shareddatabase] getListOfTransferredOrDeletedFiles:@"Deleted"];
    [APIManager sharedManager].transferredListArray=[[Database shareddatabase] getListOfTransferredOrDeletedFiles:@"Transferred"];
    return 1;
   
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (segment.selectedSegmentIndex==0)
    {
        APIManager* app=[APIManager sharedManager];
        return app.transferredListArray.count;
    }
    if (segment.selectedSegmentIndex==1)
    {
        APIManager* app=[APIManager sharedManager];
        return app.deletedListArray.count;
    }
    else
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UILabel* fileNameLabel=[cell viewWithTag:101];
    UILabel* timeLabel=[cell viewWithTag:102];
    UILabel* transferByLabel=[cell viewWithTag:103];
    UILabel* dateLabel=[cell viewWithTag:104];
    
    APIManager* app=[APIManager sharedManager];
    NSDictionary* dict;
    if (segment.selectedSegmentIndex==0)
    {
        dict= [app.transferredListArray objectAtIndex:indexPath.row];
    }
    else
    dict= [app.deletedListArray objectAtIndex:indexPath.row];
    
    fileNameLabel.text=[dict valueForKey:@"RecordItemName"];
    NSString* dateAndTimeString=[dict valueForKey:@"Date"];
    NSArray* dateAndTimeArray=[dateAndTimeString componentsSeparatedByString:@" "];
    if (segment.selectedSegmentIndex==0) {
        timeLabel.text=[NSString stringWithFormat:@"Transferred %@",[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]]];

    }
    else
        timeLabel.text=[NSString stringWithFormat:@"Deleted %@",[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]]];

    
    //timeLabel.text=[NSString stringWithFormat:@"%@",@"Transferred 12:18:00 PM"];

    transferByLabel.text=[dict valueForKey:@"Department"];
    
    dateLabel.text=[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:0]]];
    
    if ([arrayOfMarked containsObject:indexPath])
    {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    else
        cell.accessoryType=UITableViewCellAccessoryNone;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //MainTabBarViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarViewController"];
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    APIManager* app=[APIManager sharedManager];

    if (isMultipleFilesActivated)
    {
        int uploadFileCount;
        UILabel* deleteStatusLabel=[cell viewWithTag:105];
        NSDictionary* awaitingFileTransferDict= [app.transferredListArray objectAtIndex:indexPath.row];
        NSString* fileName=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
        
        for (NSInteger i = 0; i < app.transferredListArray.count; ++i)
        {
            NSIndexPath* indexPath= [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell* cell= [self.tableView cellForRowAtIndexPath:indexPath];
            UILabel* deleteStatusLabel=[cell viewWithTag:105];
            if ([deleteStatusLabel.text isEqual:@"Uploading"])
            {
                ++uploadFileCount;
            }
        }
        if (app.transferredListArray.count-uploadFileCount==1)
        {
            UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
            UIToolbar* view=  vc.customView;
            NSArray* arr= [view items];
            UIBarButtonItem* button= [arr objectAtIndex:2];
            //UIButton* button=  [view viewWithTag:102];
            
            [button setTitle:@"Deselect all"];
        }
        if (arrayOfMarked.count == app.transferredListArray.count-uploadFileCount)
            
        {
            UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
            UIToolbar* view=  vc.customView;
            NSArray* arr= [view items];
            UIBarButtonItem* button= [arr objectAtIndex:2];
            //UIButton* button=  [view viewWithTag:102];
            
            [button setTitle:@"Deselect all"];
        }
        
        if (cell.accessoryType == UITableViewCellAccessoryNone)
        {
            
            [self.checkedIndexPath addObject:fileName];
            [arrayOfMarked addObject:indexPath];
            selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            //
            if (arrayOfMarked.count == app.transferredListArray.count)
            {
                UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
                UIToolbar* view=  vc.customView;
                NSArray* arr= [view items];
                UIBarButtonItem* button= [arr objectAtIndex:2];
                //UIButton* button=  [view viewWithTag:102];
                [button setTitle:@"Deselect all"];
            }
        }
        else if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.checkedIndexPath removeObject:fileName];
            [arrayOfMarked removeObject:indexPath];
            selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];
            
            //
            UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
            UIToolbar* view=  vc.customView;
            NSArray* arr= [view items];
            UIBarButtonItem* button= [arr objectAtIndex:2];
            //UIButton* button=  [view viewWithTag:102];
            [button setTitle:@"Select all"];
            
        }
        
        if(arrayOfMarked.count > 0)
        {
            //Show upload files button
            
            [self hideAndShowUploadButton:YES];
        }
        else
        {
            //Remove upload files button.
            self.navigationItem.leftBarButtonItem= nil;
            self.navigationItem.title = @"List";
            isMultipleFilesActivated = NO;
            [self hideAndShowUploadButton:NO];
        }
    }

    else
    {
    TransferredOrDeletedAudioDetailsViewController* vc=[self.storyboard instantiateViewControllerWithIdentifier:@"TransferredOrDeletedAudioDetailsViewController"];
    vc.listSelected=segment.selectedSegmentIndex;
    //NSLog(@"%ld",vc.listSelected);
    vc.selectedRow=indexPath.row;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
    
}
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
//{
//    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
//    
//               if (isMultipleFilesActivated)
//            {
//                if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
//                {
//                    cell.accessoryType = UITableViewCellAccessoryNone;
//                    NSDictionary* awaitingFileTransferDict= [[APIManager sharedManager].transferredListArray objectAtIndex:indexPath.row];
//                    NSString* fileName=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
//                    [arrayOfMarked removeObject:indexPath];
//                    selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];
//                    
//                    [self.checkedIndexPath removeObject:fileName];
//                    
//                    //
//                    UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
//                    UIToolbar* view=  vc.customView;
//                    NSArray* arr= [view items];
//                    UIBarButtonItem* button= [arr objectAtIndex:2];
//                    //UIButton* button=  [view viewWithTag:102];
//                    [button setTitle:@"Select all"];
//                    
//                }
//                
//                if(arrayOfMarked.count > 0)
//                {
//                    //Show upload files button
//                    [self hideAndShowUploadButton:YES];
//                }
//                else
//                {
//                    //Remove upload files button.
//                    isMultipleFilesActivated = NO;
//                    [self hideAndShowUploadButton:NO];
//                }
//                
//            }
//        
//    
//}


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

- (IBAction)segmentChanged:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex == 1)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"More"] style:UIBarButtonItemStylePlain target:self action:@selector(showUserSettings:)];
        self.navigationItem.title = @"List";
        [self.checkedIndexPath removeAllObjects];
    
        [arrayOfMarked removeAllObjects];
    }
    APIManager* app=[APIManager sharedManager];
    Database* db=[Database shareddatabase];
   self.segment.selectedSegmentIndex= sender.selectedSegmentIndex;
    isMultipleFilesActivated = NO;
    toolBarAdded = NO;
     app.deletedListArray=[db getListOfTransferredOrDeletedFiles:@"Deleted"];
    app.transferredListArray=[db getListOfTransferredOrDeletedFiles:@"Transferred"];

    [self.tableView reloadData];
}
@end
