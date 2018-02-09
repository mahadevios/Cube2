//
//  SelectFileViewController.h
//  Cube
//
//  Created by mac on 28/11/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonDelegate.h"

@interface SelectFileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate>
{
    NSTimer* newRequestTimer;

}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(readwrite , assign) id<CommonDelegate>delegate;
@property(nonatomic, strong)NSMutableArray* VRSDocFilesArray;
- (IBAction)backButtonPressed:(id)sender;
@property(nonatomic, strong)UIAlertController* alertController;


@end
