//
//  VideoCallViewController.h
//  Cube
//
//  Created by mac on 21/03/20.
//  Copyright © 2020 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientDetails.h"
#import "Constants.h"
#import "APIManager.h"
#import "AppointmentDetailsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoCallViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UIToolbar* toolbar;
    UIDatePicker* picker;
    NSMutableArray* patientsDetailsArray;
    UIAlertController *alertController;
    UIAlertAction *actionDelete;
    UIAlertAction *actionCancel;
    AppointmentDetailsViewController* detailVC;
}
@property (strong, nonatomic) NSIndexPath *expandedIndexPath;

@property (weak, nonatomic) IBOutlet UITableView *tabelView;
- (IBAction)searchButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@end

NS_ASSUME_NONNULL_END
