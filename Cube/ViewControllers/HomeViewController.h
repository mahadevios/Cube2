//
//  HomeViewController.h
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"

@interface HomeViewController : UIViewController
{
    UITapGestureRecognizer* tapRecogniser;
    UITapGestureRecognizer* tapRecogniser1;
    UITapGestureRecognizer* tapRecogniser2;
    UIView* overlayView;
    UITapGestureRecognizer* tap;
    APIManager* app;
    Database* db;
    UIAlertController *alertController;
    UIAlertAction *actionDelete;
    UIAlertAction *actionCancel;
    MBProgressHUD* hud;
    NSURLSession* session;
    
}
@property (weak, nonatomic) IBOutlet UIView *transferredView;
@property (weak, nonatomic) IBOutlet UIView *awaitingTransferView;
@property (weak, nonatomic) IBOutlet UIView *transferFailedView;
@property (weak, nonatomic) IBOutlet UILabel *failedCountLabel;
@property (strong, nonatomic) NSMutableArray *completedFilesResponseArray;
@property (strong, nonatomic) NSMutableArray *completedFilesForTableViewArray;
@property (strong, nonatomic) NSMutableArray *downloadingFilesDictationIdsArray;
@property (strong, nonatomic) NSArray *uploadedFilesArray;
@property (weak, nonatomic) IBOutlet UILabel *completedDocCountLabel;

@end
