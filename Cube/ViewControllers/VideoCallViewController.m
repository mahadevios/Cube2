//
//  VideoCallViewController.m
//  Cube
//
//  Created by mac on 21/03/20.
//  Copyright © 2020 Xanadutec. All rights reserved.
//

#import "VideoCallViewController.h"

@interface VideoCallViewController ()

@end

@implementation VideoCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"facetime://mahadevmandale@yahoo.com"]];
//
    // Do any additional setup after loading the view.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    return cell;
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
