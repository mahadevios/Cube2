//
//  AppointmentDetailsViewController.h
//  Cube
//
//  Created by mac on 25/03/20.
//  Copyright © 2020 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientDetails.h"

NS_ASSUME_NONNULL_BEGIN
@class AppointmentDetailsViewController;
@protocol MyClassDelegate <NSObject>   //define delegate protocol

- (void) myClassDelegateMethod: (AppointmentDetailsViewController *) sender;  //define delegate method to be implemented within another class
@end //end protocol

@interface AppointmentDetailsViewController : UIViewController
{
   UIAlertController *alertController;
   UIAlertAction *actionUpdate;
   UIAlertAction *actionCancel;
   NSString* selectedAppointmentStatus;
}
- (IBAction)changeAptStatusButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *changeAptButton;
@property (weak, nonatomic) IBOutlet UILabel *aptStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *patientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateAndTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateOfBirthLabel;
@property (weak, nonatomic) IBOutlet UILabel *nhsNoLabel;

@property (weak, nonatomic) IBOutlet UILabel *mrnNoLabel;
@property (nonatomic)int selectedRow;
@property (nonatomic, weak) id <MyClassDelegate> delegate; //define MyClassDelegate as delegate
@property (nonatomic, strong) PatientDetails* patientDetails;
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@end

NS_ASSUME_NONNULL_END
