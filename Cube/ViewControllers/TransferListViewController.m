//
//  TransferListViewController.m
//  Cube
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//
//self.checkedIndexPath contain file names to be upload,arrayOfChecked contain indexpathof selected cells

//check in cell for row at index path where we adding the indexpath to array
#import "TransferListViewController.h"
#import "AudioDetailsViewController.h"
@interface TransferListViewController ()

@end

@implementation TransferListViewController
@synthesize currentViewName, checkedIndexPath,longPressAdded;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
        {
         UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
         lpgr.minimumPressDuration = 1.0; //seconds
         lpgr.delegate = self;
         [self.tableView addGestureRecognizer:lpgr];
          self.checkedIndexPath = [[NSMutableArray alloc] init];
            
            
        }
    
    arrayOfMarked=[[NSMutableArray alloc]init];
    progressIndexPathArray=[[NSMutableArray alloc]init];
   // progressIndexPathArrayCopy=[[NSMutableArray alloc]init];

    indexPathFileNameDict= [NSMutableDictionary new];
    
  
    
}


-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title=self.currentViewName;
    if ([self.currentViewName isEqualToString:@"Today's Transferred"])
    {
        self.navigationItem.title=@"Transferred Today";
    }
    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
    {
        [self setTimer];
    }
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    
    self.navigationItem.rightBarButtonItem = nil;

    APIManager* app=[APIManager sharedManager];
    app.awaitingFileTransferNamesArray=[[NSMutableArray alloc]init];
    app.todaysFileTransferNamesArray=[[NSMutableArray alloc]init];
    app.failedTransferNamesArray=[[NSMutableArray alloc]init];
    
    
  //  [UIApplication sharedApplication].idleTimerDisabled = NO;

    [self.tableView reloadData];
    
    [self.tabBarController.tabBar setHidden:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateFileUploadResponse:) name:NOTIFICATION_FILE_UPLOAD_API
                                               object:nil];

}

-(void)setTimer
{

    progressTimer =  [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateProgresCount) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.checkedIndexPath removeAllObjects];
    [arrayOfMarked removeAllObjects];
    isMultipleFilesActivated=NO;
    toolBarAdded=NO;
    
    [progressTimer invalidate];
}
-(void)validateFileUploadResponse:(NSNotification*)obj
{
    [progressTimer invalidate];
    //NSString* fileName =  obj.object;
    
    // [progressTimer invalidate];
    //NSIndexPath* indexPath = [indexPathFileNameDict objectForKey:fileName];
   
    //[progressIndexPathArrayCopy removeAllObjects];

    //[self setTimer];
   // APIManager* api = [APIManager sharedManager];
  //  [APIManager sharedManager].awaitingFileTransferNamesArray= [[Database shareddatabase] getListOfFileTransfersOfStatus:@"RecordingComplete"];
    
     [progressIndexPathArray removeAllObjects];
    [self.checkedIndexPath removeAllObjects];
    [arrayOfMarked removeAllObjects];
    isMultipleFilesActivated=NO;
    [self hideAndShowUploadButton:NO];
    
    
    //[self.tableView beginUpdates];
    
    [self.tableView reloadData];//to update table agter getting file trnasfer response
    
    [self setTimer];
    //[self.tableView endUpdates];
}
-(void)updateProgresCount
{
       // [self.tableView beginUpdates];
        if (progressIndexPathArray.count>0)
    {
       // [self.tableView beginUpdates];
        [APIManager sharedManager].awaitingFileTransferNamesArray= [[Database shareddatabase] getListOfFileTransfersOfStatus:@"RecordingComplete"] ;

        [self.tableView reloadRowsAtIndexPaths:progressIndexPathArray withRowAnimation:UITableViewRowAnimationNone];
        //[self.tableView endUpdates];
    }
      //  [self.tableView endUpdates];
    
    // [self.tableView reloadData];
    
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (self.navigationItem.title==self.currentViewName)//if navigation title=@"somevalue" then only handle longpress
    {
   
        isMultipleFilesActivated = YES;
        APIManager* app=[APIManager sharedManager];
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        UITableViewCell* cell=[self.tableView cellForRowAtIndexPath:indexPath];
        UILabel* deleteStatusLabel=[cell viewWithTag:105];
    
    
        if (cell.accessoryType == UITableViewCellAccessoryNone && (![deleteStatusLabel.text containsString:@"Uploading"]))
        {
            NSDictionary* awaitingFileTransferDict= [app.awaitingFileTransferNamesArray objectAtIndex:indexPath.row];
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

-(void)popViewController:(id)sender
{
    [self.tabBarController.tabBar setHidden:NO];

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark: tableView delegates adn datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Database* db=[Database shareddatabase];
    APIManager* app=[APIManager sharedManager];
    if ([self.currentViewName isEqualToString:@"Today's Transferred"])
    {
        app.todaysFileTransferNamesArray= [db getListOfFileTransfersOfStatus:@"Transferred"];

        return app.todaysFileTransferNamesArray.count;

    }
    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
    {
        app.awaitingFileTransferNamesArray= [db getListOfFileTransfersOfStatus:@"RecordingComplete"];

        return app.awaitingFileTransferNamesArray.count;
    }
    else
    {
        app.failedTransferNamesArray= [db getListOfFileTransfersOfStatus:@"TransferFailed"];

        return app.failedTransferNamesArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APIManager* app=[APIManager sharedManager];
    NSDictionary* awaitingFileTransferDict;
    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
    {
        awaitingFileTransferDict= [app.awaitingFileTransferNamesArray objectAtIndex:indexPath.row];
    }
    else
    if ([self.currentViewName isEqualToString:@"Today's Transferred"])
    {
        awaitingFileTransferDict= [app.todaysFileTransferNamesArray objectAtIndex:indexPath.row];
    }
    else
        awaitingFileTransferDict= [app.failedTransferNamesArray objectAtIndex:indexPath.row];

    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
   
    UILabel* departmentNameLabel=[cell viewWithTag:101];
    departmentNameLabel.text=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
    NSString* dateAndTimeString=[awaitingFileTransferDict valueForKey:@"RecordCreatedDate"];
    NSArray* dateAndTimeArray=[dateAndTimeString componentsSeparatedByString:@" "];
    
    UILabel* timeLabel=[cell viewWithTag:102];
    if (dateAndTimeArray.count>1)
    timeLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]];
    
    UILabel* nameLabel=[cell viewWithTag:103];
    nameLabel.text=[awaitingFileTransferDict valueForKey:@"Department"];
    
    UILabel* deleteStatusLabel=[cell viewWithTag:105];

    UILabel* dateLabel=[cell viewWithTag:104];
    dateLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:0]];
    
    if ([self.currentViewName isEqualToString:@"Today's Transferred"])
    {
        dateAndTimeString=[awaitingFileTransferDict valueForKey:@"TransferDate"];
        dateAndTimeArray=nil;
        dateAndTimeArray=[dateAndTimeString componentsSeparatedByString:@" "];
        
        if (dateAndTimeArray.count>1)
        {
            timeLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]];
            dateLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:0]];
        }
        

    }
    if ([[awaitingFileTransferDict valueForKey:@"DeleteStatus"] isEqualToString:@"Delete"])
    {
        deleteStatusLabel.text=@"Deleted";
    }
    else
        deleteStatusLabel.text=@"";
    if ([[awaitingFileTransferDict valueForKey:@"DictationStatus"] isEqualToString:@"RecordingFileUpload"] && ([[awaitingFileTransferDict valueForKey:@"TransferStatus"] isEqualToString:@"NotTransferred"] || [[awaitingFileTransferDict valueForKey:@"TransferStatus"] isEqualToString:@"Resend"] || [[awaitingFileTransferDict valueForKey:@"TransferStatus"] isEqualToString:@"ResendFailed"]))
    {
        if (![progressIndexPathArray containsObject:indexPath])
        {
            [progressIndexPathArray addObject:indexPath];
           // [progressIndexPathArrayCopy addObject:indexPath];

            [indexPathFileNameDict setObject:indexPath forKey:departmentNameLabel.text];
        }
        //deleteStatusLabel.text=@"Uploading";
        if ([[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict valueForKey:[awaitingFileTransferDict valueForKey:@"RecordItemName"]]== NULL)
        {
            deleteStatusLabel.text= @"Uploading 0%";
        }
        else
        deleteStatusLabel.text=[NSString stringWithFormat:@"Uploading %@",[[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict valueForKey:[awaitingFileTransferDict valueForKey:@"RecordItemName"]]];

    }
    else
    {
        if ([progressIndexPathArray containsObject:indexPath])
        {
            [progressIndexPathArray removeObject:indexPath];
            [indexPathFileNameDict removeObjectForKey:departmentNameLabel.text];
        }
    }
    
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
    //NSDictionary* awaitingFileTransferDict;
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    APIManager* app=[APIManager sharedManager];

   

    if (isMultipleFilesActivated)
    {
        int uploadFileCount;
        UILabel* deleteStatusLabel=[cell viewWithTag:105];
        NSDictionary* awaitingFileTransferDict= [app.awaitingFileTransferNamesArray objectAtIndex:indexPath.row];
        NSString* fileName=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
        
        for (NSInteger i = 0; i < app.awaitingFileTransferNamesArray.count; ++i)
        {
            NSIndexPath* indexPath= [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell* cell= [self.tableView cellForRowAtIndexPath:indexPath];
            UILabel* deleteStatusLabel=[cell viewWithTag:105];
            if ([deleteStatusLabel.text containsString:@"Uploading"])
            {
                ++uploadFileCount;
            }
        }
        if (app.awaitingFileTransferNamesArray.count-uploadFileCount==1)
        {
            UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
            UIToolbar* view=  vc.customView;
            NSArray* arr= [view items];
            UIBarButtonItem* button= [arr objectAtIndex:4];
            //UIButton* button=  [view viewWithTag:102];
            
            [button setTitle:@"Deselect all"];
        }
        if (arrayOfMarked.count == app.awaitingFileTransferNamesArray.count-uploadFileCount)

        {
            UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
            UIToolbar* view=  vc.customView;
            NSArray* arr= [view items];
            UIBarButtonItem* button= [arr objectAtIndex:4];
            //UIButton* button=  [view viewWithTag:102];
            
            [button setTitle:@"Deselect all"];
        }

        if (cell.accessoryType == UITableViewCellAccessoryNone && (![deleteStatusLabel.text containsString:@"Uploading"]))
        {
            
            [self.checkedIndexPath addObject:fileName];
            [arrayOfMarked addObject:indexPath];
            selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            //
            if (arrayOfMarked.count == app.awaitingFileTransferNamesArray.count)
            {
                UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
                UIToolbar* view=  vc.customView;
                NSArray* arr= [view items];
                UIBarButtonItem* button= [arr objectAtIndex:4];
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
            UIBarButtonItem* button= [arr objectAtIndex:4];
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
            isMultipleFilesActivated = NO;
            [self hideAndShowUploadButton:NO];
        }
    }
else//to disaalow single row while that row is uploading

    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
    {    UILabel* deleteStatusLabel=[cell viewWithTag:105];

        if(([deleteStatusLabel.text containsString:@"Uploading"]))
        {
            alertController = [UIAlertController alertControllerWithTitle:@"Alert?"
                                                                  message:@"File is in use!"
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
        {
            AudioDetailsViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioDetailsViewController"];
            vc.selectedRow=indexPath.row ;
            vc.selectedView=self.currentViewName;
            [self.navigationController presentViewController:vc animated:YES completion:nil];
         }

    }
    else
    {
        AudioDetailsViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioDetailsViewController"];
        vc.selectedRow=indexPath.row ;
        vc.selectedView=self.currentViewName;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];

    if ([self.currentViewName isEqualToString:@"Awaiting Transfer"])
    {    UILabel* deleteStatusLabel=[cell viewWithTag:105];
        
        if(([deleteStatusLabel.text containsString:@"Uploading"]))
        {
            alertController = [UIAlertController alertControllerWithTitle:@"Alert?"
                                                                  message:@"File is in use!"
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
            if (isMultipleFilesActivated)
            {
                if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    NSDictionary* awaitingFileTransferDict= [[APIManager sharedManager].awaitingFileTransferNamesArray objectAtIndex:indexPath.row];
                    NSString* fileName=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
                    [arrayOfMarked removeObject:indexPath];
                    selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];

                    [self.checkedIndexPath removeObject:fileName];

                    //
                    UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
                    UIToolbar* view=  vc.customView;
                    NSArray* arr= [view items];
                    UIBarButtonItem* button= [arr objectAtIndex:4];
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
                    isMultipleFilesActivated = NO;
                    [self hideAndShowUploadButton:NO];
                }
//                int uploadFileCount;
//                for (NSInteger i = 0; i < [APIManager sharedManager].awaitingFileTransferNamesArray.count; ++i)
//                {
//                    NSIndexPath* indexPath= [NSIndexPath indexPathForRow:i inSection:0];
//                    UITableViewCell* cell= [self.tableView cellForRowAtIndexPath:indexPath];
//                    UILabel* deleteStatusLabel=[cell viewWithTag:105];
//                    if ([deleteStatusLabel.text isEqual:@"Uploading"])
//                    {
//                        ++uploadFileCount;
//                    }
//                }
//                if (arrayOfMarked.count == [APIManager sharedManager].awaitingFileTransferNamesArray.count-uploadFileCount)
//                    
//                {
//                    UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
//                    UIToolbar* view=  vc.customView;
//                    NSArray* arr= [view items];
//                    UIBarButtonItem* button= [arr objectAtIndex:4];
//                    //UIButton* button=  [view viewWithTag:102];
//                    [button setTitle:@"Deselect all"];
//                }
                

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
        self.navigationItem.title=self.currentViewName;

        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];

    }
}

//- (void) hideAndShowLeftBarButton:(BOOL)isShown
//{
//    if (isShown)
//    {
//        self.navigationItem.title=@"";
////        if (!toolBarAdded)
////        {
//            [self addLeftBarButton];
//            
//       // }
//        
//    }
//    else
//    {
//        toolBarAdded=NO;
//        self.navigationItem.title=self.currentViewName;
//        
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];;
//        
//    }
//}


-(void)addToolbar
{
    toolBarAdded=YES;
    UIToolbar *tools = [[UIToolbar alloc]
                        initWithFrame:CGRectMake(-50.0f, 10.0f, 182.0f, 44.01f)]; // 44.01 shifts it up 1px for some reason
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
    bi = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Upload"] style:UIBarButtonItemStylePlain target:self action:@selector(uploadMultipleFilesToserver)];
    [buttons addObject:bi];

    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    bi.width = 12.0f;
    [buttons addObject:bi];
    
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
                         initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.01f)]; // 44.01 shifts it up 1px for some reason
    //tools.layer.borderWidth = 1;
    tools1.tag=101;
    tools1.layer.borderColor = [[UIColor whiteColor] CGColor];
    tools1.clipsToBounds = YES;
    
    NSMutableArray *buttons1 = [[NSMutableArray alloc] initWithCapacity:4];
    // Create a standard refresh button.
    UIBarButtonItem *bi1 = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
bi1.imageInsets=UIEdgeInsetsMake(0, -30, 0, 0);
    [buttons1 addObject:bi1];
    
    //Create a spacer.
    bi1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    bi1.width = 8.0f;
    [buttons1 addObject:bi1];
    
    
    // Add profile button.
    selectedCountLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, 30, 20)];
    selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];
    bi1 = [[UIBarButtonItem alloc]initWithCustomView:selectedCountLabel];
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
    for (NSInteger i = 0; i < [APIManager sharedManager].awaitingFileTransferNamesArray.count; ++i)
    {
        NSIndexPath* indexPath= [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell* cell= [self.tableView cellForRowAtIndexPath:indexPath];
        UILabel* deleteStatusLabel=[cell viewWithTag:105];
        if ([deleteStatusLabel.text containsString:@"Uploading"])
        {
            ++uploadFileCount;
        }
    }
    if ([APIManager sharedManager].awaitingFileTransferNamesArray.count-uploadFileCount==1)
    {
        UIBarButtonItem* vc=self.navigationItem.rightBarButtonItem;
        UIToolbar* view=  vc.customView;
        NSArray* arr= [view items];
        UIBarButtonItem* button= [arr objectAtIndex:4];
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
                            
                            NSDictionary* awaitingFileTransferDict= [app.awaitingFileTransferNamesArray objectAtIndex:indexPath.row];
                            NSString* fileName=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
                                self.navigationItem.title=self.currentViewName;
                                self.navigationItem.rightBarButtonItem = nil;
                            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
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
                            self.navigationItem.rightBarButtonItem = nil;
                        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
                            isMultipleFilesActivated=NO;
                            toolBarAdded=NO;
                            
                        [arrayOfMarked removeAllObjects];
                        [self.checkedIndexPath removeAllObjects];
                        [self.tableView reloadData];
                        
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

-(void)uploadMultipleFilesToserver
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {

    alertController = [UIAlertController alertControllerWithTitle:TRANSFER_MESSAGE_MULTIPLES
                                                          message:@""
                                                   preferredStyle:UIAlertControllerStyleAlert];
    actionDelete = [UIAlertAction actionWithTitle:@"Yes"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        isMultipleFilesActivated = NO;

                        NSMutableArray* aarayOfMarkedCopy=[[NSMutableArray alloc]init];
                        for (int i=0; i<arrayOfMarked.count; i++)
                            
                        {
                            APIManager* app=[APIManager sharedManager];
                            NSIndexPath* indexPath=[arrayOfMarked objectAtIndex:i];
                            //[aarayOfMarkedCopy addObject:[arrayOfMarked objectAtIndex:i]];
                            NSDictionary* awaitingFileTransferDict= [app.awaitingFileTransferNamesArray objectAtIndex:indexPath.row];
                            NSString* fileName=[awaitingFileTransferDict valueForKey:@"RecordItemName"];
                            
                            self.navigationItem.title=self.currentViewName;
                            self.navigationItem.rightBarButtonItem = nil;
                            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
                            toolBarAdded=NO;
                            [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUpload" fileName:fileName];
                            
                            

                            
                        }
                        [arrayOfMarked removeAllObjects];//array of marked is for to get marked cells(objects),got the file names from arrayof marked,update the db hence remove all objects,and rload table
                        //[self.tableView reloadData];
                        [aarayOfMarkedCopy addObjectsFromArray:self.checkedIndexPath];
                        
                        [self.checkedIndexPath removeAllObjects];
                        [self.tableView reloadData];
                        for (int i=0; i<aarayOfMarkedCopy.count; i++)
                        {
                             NSString* fileName=[aarayOfMarkedCopy objectAtIndex:i];
                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                APIManager* app=[APIManager sharedManager];
                                
                                 
                                [app uploadFileToServer:fileName];
                                
                            });
                        }
                        isMultipleFilesActivated=NO;
                        //////////////
                        
  
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionDelete];
    
    
    actionCancel = [UIAlertAction actionWithTitle:@"No"
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * action)
                    {
                        [alertController dismissViewControllerAnimated:YES completion:nil];

                        self.navigationItem.title=self.currentViewName;
                        self.navigationItem.rightBarButtonItem = nil;
                        
                        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
                        isMultipleFilesActivated=NO;
                        toolBarAdded=NO;

                        [self.checkedIndexPath removeAllObjects];
                        [arrayOfMarked removeAllObjects];
                        [self.tableView reloadData];

                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    
    else
    {
        self.navigationItem.title=self.currentViewName;
        self.navigationItem.rightBarButtonItem = nil;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
        isMultipleFilesActivated=NO;
        toolBarAdded=NO;
        
        [self.checkedIndexPath removeAllObjects];
        [arrayOfMarked removeAllObjects];
        [self.tableView reloadData];

        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }

    
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
        app.awaitingFileTransferNamesArray= [db getListOfFileTransfersOfStatus:@"RecordingComplete"];

        for (NSInteger i = 0; i < app.awaitingFileTransferNamesArray.count; ++i)
        {
          NSIndexPath* indexPath= [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell* cell= [self.tableView cellForRowAtIndexPath:indexPath];
            NSDictionary* awaitingFileTransferDict= [app.awaitingFileTransferNamesArray objectAtIndex:i];
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
        self.navigationItem.title=self.currentViewName;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
        isMultipleFilesActivated=NO;
        [self.checkedIndexPath removeAllObjects];
        [arrayOfMarked removeAllObjects];
        selectedCountLabel.text=[NSString stringWithFormat:@"%ld",arrayOfMarked.count];

        toolBarAdded=NO;
        [self.tableView reloadData];
        
        
    }

    

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
