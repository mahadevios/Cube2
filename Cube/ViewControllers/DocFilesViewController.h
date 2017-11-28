//
//  DocFilesViewController.h
//  Cube
//
//  Created by mac on 20/11/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+TableViewButton.h"
#import "TableViewButton.h"
#import "UIColor+ApplicationColors.h"

@interface DocFilesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UIDocumentInteractionControllerDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *completedFilesResponseArray;
@property (strong, nonatomic) NSMutableArray *completedFilesForTableViewArray;
@property (strong, nonatomic) NSMutableArray *downloadingFilesDictationIdsArray;
@property (strong, nonatomic) UIView* overLayView;
@property (strong, nonatomic) UIScrollView* scrollView;
@property (strong, nonatomic) NSArray *uploadedFilesArray;


@end
