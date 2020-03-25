//
//  AppointmentDetailsViewController.m
//  Cube
//
//  Created by mac on 25/03/20.
//  Copyright © 2020 Xanadutec. All rights reserved.
//

#import "AppointmentDetailsViewController.h"

@interface AppointmentDetailsViewController ()

@end

@implementation AppointmentDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.splitViewController.isCollapsed == false || self.splitViewController == nil)
    {
        self.navigationItem.title=@"Appointment Details";
    }
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    


}
-(void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)validateApnmntStatus:(NSNotification*)dictObj
{
   [self setStatusStringUsingStatusId:selectedAppointmentStatus];
    
}

-(void)setAptDetails
{
   
    [self setStatusStringUsingStatusId:self.patientDetails.AppointmentStatus];
    
    self.patientNameLabel.text = [NSString stringWithFormat:@"%@ %@ %@",self.patientDetails.PatTitle, self.patientDetails.PatFirstname, self.patientDetails.PatLastname];
    
    self.contactNameLabel.text = self.patientDetails.PatientContactNumber;
    
    self.dateAndTimeLabel.text = [NSString stringWithFormat:@"%@, %@",self.patientDetails.AppointmentDate, self.patientDetails.AppointmentTime];
    
    self.dateOfBirthLabel.text = self.patientDetails.DOB;
    
    self.nhsNoLabel.text = self.patientDetails.NHSNumber;
    
    self.mrnNoLabel.text = self.patientDetails.MRN;

}

-(void) setStatusStringUsingStatusId:(NSString*) statusId
{
    switch ([statusId intValue]) {
           case 1:
               self.aptStatusLabel.text = @"New";
               break;
           case 2:
               self.aptStatusLabel.text = @"Completed";
               break;
           case 3:
                self.aptStatusLabel.text = @"Not Attended";
               break;
               
           case 6:
                self.aptStatusLabel.text = @"Closed";
               break;
           default:
               self.aptStatusLabel.text = @"Undefined";
               break;
       }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)addCancelAction
{
    actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * action)
                      {
          [alertController dismissViewControllerAnimated:YES completion:nil];
          
      }]; //You can use a block here to handle a press on this button
      [alertController addAction:actionCancel];
    
}

- (IBAction)changeAptStatusButtonClicked:(id)sender {
    [self showStatusChangeOptions:sender];
}

-(void) showStatusChangeOptions:(UIButton*)sender
{
   
   
    alertController = [UIAlertController alertControllerWithTitle:@""
                                                          message:@"Select status to update"
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* actionComplete = [UIAlertAction actionWithTitle:@"Complete"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
        
        [self confirmUpdateApntmntStatus:2 sender:sender];
             // update status API call
        
    }]; //You can use a block here to handle a press on this button
//    UIImage *img = [UIImage imageNamed:@"Whatsapp"];
//    [actionWhatsapp setValue:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [alertController addAction:actionComplete];
    
    UIAlertAction* actionNotAttended = [UIAlertAction actionWithTitle:@"Not Attended"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action)
                                         {
            
         [self confirmUpdateApntmntStatus:3 sender:sender];
                 // update status API call
            
        }];
    [alertController addAction:actionNotAttended];
    
    UIAlertAction* actionClosed = [UIAlertAction actionWithTitle:@"Close"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action)
                                         {
            
          [self confirmUpdateApntmntStatus:6 sender:sender];
                 // update status API call
            
        }];
    [alertController addAction:actionClosed];
    
     [self addCancelAction];
     
     [alertController setModalPresentationStyle:UIModalPresentationPopover];
     
     
     if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
     {
         UIPopoverPresentationController *popPresenter = [alertController
                                                          popoverPresentationController];
         popPresenter.sourceView = sender;
         popPresenter.sourceRect = sender.bounds;
     }
     
     [self presentViewController:alertController animated:YES completion:nil];
}

-(void) confirmUpdateApntmntStatus:(int)status sender:(UIButton*)sender
{
  
    
    NSString* statusString;
    switch (status) {
               case 2:
            statusString = @"Completed";
                   break;
               
               case 3:
                  statusString = @"Not Attended";
                   break;
               
               case 6:
                   statusString = @"Closed";
                   break;
               default:
                   break;
           }
    NSString* updateMessage = [NSString stringWithFormat:@"Are you sure you want to update appointment status to %@ ?",statusString];
    
    alertController = [UIAlertController alertControllerWithTitle:@"Update Status?"
                                                          message:updateMessage
                                                   preferredStyle:UIAlertControllerStyleAlert];
    actionUpdate = [UIAlertAction actionWithTitle:@"Update"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
        
        switch (status) {
            case 2:
                selectedAppointmentStatus = @"2";
//                [[APIManager sharedManager] updateAppointmentStatus:[NSString stringWithFormat:@"%d",status] appointmentId:[NSString stringWithFormat:@"%ld",pD.AppointementID]];
                break;
            
            case 3:
                selectedAppointmentStatus = @"3";
//                [[APIManager sharedManager] updateAppointmentStatus:[NSString stringWithFormat:@"%d",status] appointmentId:[NSString stringWithFormat:@"%ld",pD.AppointementID]];
                break;
            
            case 6:
                selectedAppointmentStatus = @"6";
//                [[APIManager sharedManager] updateAppointmentStatus:[NSString stringWithFormat:@"%d",status] appointmentId:[NSString stringWithFormat:@"%ld",pD.AppointementID]];
                break;
            default:
                break;
        }
                      
        [self validateApnmntStatus:nil];
                        
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionUpdate];
    
    
    actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * action)
                    {
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                        
                    }]; //You can use a block here to handle a press on this button
    
    [alertController addAction:actionCancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


- (IBAction)backButtonClicked:(id)sender {
    if (self.splitViewController.isCollapsed || self.splitViewController == nil)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else
    {
        //        NSMutableArray* subVC = [[NSMutableArray alloc] initWithArray:[self.splitViewController viewControllers]];
        //
        //        [subVC removeLastObject];
        [self.splitViewController.viewControllers[0] popToRootViewControllerAnimated:YES];
        
        
    }
}
@end
