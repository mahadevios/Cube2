//
//  SelectFileViewController.m
//  Cube
//
//  Created by mac on 28/11/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import "SelectFileViewController.h"
#import "TableViewButton.h"

@interface SelectFileViewController ()

@end

@implementation SelectFileViewController

@synthesize VRSDocFilesArray,alertController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //APIManager* app = [APIManager sharedManager];
    
    VRSDocFilesArray = [NSMutableArray new];
    
    VRSDocFilesArray = [[Database shareddatabase] getVRSDocFiles];

    self.navigationItem.title = @"VRS DOC Files";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    
    [self.tabBarController.tabBar setHidden:YES];
    // Do any additional setup after loading the view.
}

-(void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return VRSDocFilesArray.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    DocFileDetails* docFileDetails = [VRSDocFilesArray objectAtIndex:indexPath.row];
    
    NSString* dateAndTimeString = docFileDetails.createdDate;
    
    NSArray* dateAndTimeArray=[dateAndTimeString componentsSeparatedByString:@" "];
    
    UILabel* fileNameLabel = [cell viewWithTag:101];

    UILabel* timeLabel = [cell viewWithTag:102];

    UILabel* departmentLabel=[cell viewWithTag:103];

    UILabel* dateLabel=[cell viewWithTag:104];

    TableViewButton* deleteButton = [cell viewWithTag:105];

    deleteButton.indexPathRow = indexPath.row;

    [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    if (dateAndTimeArray.count>1)
        timeLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:1]];
    
    dateLabel.text=[NSString stringWithFormat:@"%@",[dateAndTimeArray objectAtIndex:0]];
    
    departmentLabel.text = deptObj.departmentName;
    
    fileNameLabel.text = docFileDetails.docFileName;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[AppPreferences sharedAppPreferences] showHudWithTitle:@"Opening File" detailText:@"Please wait.."];

    });

    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel* fileNameLabel = [cell viewWithTag:101];
    
   // [self.delegate setFileName:fileNameLabel.text];
    NSString* destpath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@",DOC_VRS_FILES_FOLDER_NAME,fileNameLabel.text]];
    
    NSString* newDestPath = [destpath stringByAppendingFormat:@".txt"];
    
    
    UIDocumentInteractionController* interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:newDestPath]];
    
    interactionController.delegate = self;
    
    
    [interactionController presentPreviewAnimated:true];
    
    //[interactionController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:true];
    //[self dismissViewControllerAnimated:true completion:nil];

}

-(void)deleteButtonClicked:(TableViewButton*)sender
{
    alertController = [UIAlertController alertControllerWithTitle:@"Delete Doc File?"
                                                          message:@"Are you sure to delete this doc file?"
                                                   preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* actionCreate = [UIAlertAction actionWithTitle:@"Delete"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action)
                                   {
                                       dispatch_async(dispatch_get_main_queue(), ^
                                                      {
                                                          //NSLog(@"Reachable");
                                                          //[[AppPreferences sharedAppPreferences] showHudWithTitle:@"Creating Doc File" detailText:@"Please wait.."];
                                                          DocFileDetails* docFileDetails = [VRSDocFilesArray objectAtIndex:sender.indexPathRow];
                                                          
                                                          [[Database shareddatabase] deleteDocFileRecordFromDatabase:docFileDetails.docFileName];
                                                          
                                                          [self deleteDocFile:docFileDetails.docFileName];
                                                          
                                                          NSIndexPath* indexPath = [NSIndexPath indexPathForRow:sender.indexPathRow inSection:0];
                                                          
                                                          [VRSDocFilesArray removeObjectAtIndex:sender.indexPathRow];
                                                          
                                                          [self.tableView deleteRowsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil]  withRowAnimation:UITableViewRowAnimationTop];
                                                          [self.tableView reloadData];
//                                                              [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Doc File Created" withMessage:@"Doc file crated successfully, check doc files in alert tab" withCancelText:@"Cancel" withOkText:@"Ok" withAlertTag:1000];
                                                          
                                                          //[[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
                                                          
                                                      });
                                   }]; //You can use a block here to handle a press on this button
    
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       
                                   }];
    
    [alertController addAction:actionCreate];
    
    [alertController addAction:actionCancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)deleteDocFile:(NSString*)docFileName
{
    NSString* docFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@",DOC_VRS_FILES_FOLDER_NAME,docFileName]];
    
    docFilePath = [docFilePath stringByAppendingFormat:@".txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:docFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:docFilePath error:nil];
    }
}

//-(CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
//{
//    return self.view.frame;
//
//}
//-(UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
//{
//    return self.view;
//
//}

-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    
    return self;
}

-(void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller
{
    //dispatch_async(dispatch_get_main_queue(), ^{
        
        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

    //});
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

- (IBAction)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
