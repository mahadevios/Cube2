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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    APIManager* app = [APIManager sharedManager];
    
    app.awaitingFileTransferNamesArray= [[Database shareddatabase] getListOfFileTransfersOfStatus:@"RecordingComplete"];

    // Do any additional setup after loading the view.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [APIManager sharedManager].awaitingFileTransferNamesArray.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary* awaitingFileTransferDict;

    awaitingFileTransferDict = [[APIManager sharedManager].awaitingFileTransferNamesArray objectAtIndex:indexPath.row];
    
    UILabel* fileNameLabel = [cell viewWithTag:101];
    
    fileNameLabel.text = [awaitingFileTransferDict valueForKey:@"RecordItemName"];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel* fileNameLabel = [cell viewWithTag:101];
    
    [self.delegate setFileName:fileNameLabel.text];
    
    [self dismissViewControllerAnimated:true completion:nil];

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
