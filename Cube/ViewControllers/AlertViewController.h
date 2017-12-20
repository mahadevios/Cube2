//
//  AlertViewController.h
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface AlertViewController : UIViewController
{
    Database* db;
    APIManager* app;
    int badgeCount;
    MBProgressHUD* hud;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong)NSMutableArray* VRSDocFilesArray;

@end
