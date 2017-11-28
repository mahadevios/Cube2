//
//  SelectFileViewController.h
//  Cube
//
//  Created by mac on 28/11/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonDelegate.h"

@interface SelectFileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(readwrite , assign) id<CommonDelegate>delegate;
- (IBAction)backButtonPressed:(id)sender;

@end
