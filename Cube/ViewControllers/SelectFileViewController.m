//
//  SelectFileViewController.m
//  Cube
//
//  Created by mac on 28/11/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import "SelectFileViewController.h"
@interface SelectFileViewController ()

@end

@implementation SelectFileViewController

@synthesize VRSDocFilesArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //APIManager* app = [APIManager sharedManager];
    
    VRSDocFilesArray = [NSMutableArray new];
    
    VRSDocFilesArray = [[Database shareddatabase] getVRSDocFiles];

    
    // Do any additional setup after loading the view.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return VRSDocFilesArray.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    DocFileDetails* docFileDetails = [VRSDocFilesArray objectAtIndex:indexPath.row];
    
    UILabel* fileNameLabel = [cell viewWithTag:101];
    
    fileNameLabel.text = docFileDetails.docFileName;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

-(CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
    
}
-(UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
    
}

-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    
    return self;
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
