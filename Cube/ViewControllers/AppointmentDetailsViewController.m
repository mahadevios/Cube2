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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

    if (self.splitViewController.isCollapsed == false || self.splitViewController == nil)
    {
        self.navigationItem.title=@"Appointment Details";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(validateApnmntStatus:) name:NOTIFICATION_UPDATE_APNTMNT_STATUS
        object:nil];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    
    if (self.splitViewController == nil)
    {
        self.backImageView.hidden = false;
        self.backButton.hidden = false;
        
    }
    else
        if(self.splitViewController.isCollapsed == false)
        {
            self.backImageView.hidden = true;
            self.backButton.hidden = true;
            
        }
    
    self.changeAptStatusButton.layer.cornerRadius = 4.0;
    // Do any additional setup after loading the view.
}

-(void)appWillResignActive:(NSNotification*)note
{
    [alertController dismissViewControllerAnimated:true completion:nil];
}

-(void) showVideoCallingOptions
{
    alertController = [UIAlertController alertControllerWithTitle:@""
                                                          message:@"Select an application to make a call"
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* actionWhatsapp = [UIAlertAction actionWithTitle:@"Whatsapp"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
        
       
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?phone=%@",self.patientDetails.PatientContactNumber]]];
        
    }]; //You can use a block here to handle a press on this button
    UIImage *img = [UIImage imageNamed:@"Whatsapp"];
    [actionWhatsapp setValue:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [alertController addAction:actionWhatsapp];

    UIAlertAction* actionFaceTime = [UIAlertAction actionWithTitle:@"FaceTime"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
        
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"facetime://%@",self.patientDetails.PatientContactNumber]]];
        
    }]; //You can use a block here to handle a press on this button
    img = [UIImage imageNamed:@"FaceTime"];
    [actionFaceTime setValue:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [alertController addAction:actionFaceTime];

    
    UIAlertAction* phoneCall = [UIAlertAction actionWithTitle:@"Phone Call"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.patientDetails.PatientContactNumber]]];

        
    }]; //You can use a block here to handle a press on this button
    img = [UIImage imageNamed:@"PhoneCall"];
    [phoneCall setValue:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [alertController addAction:phoneCall];
    
    [self addCancelAction];
    
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    
    
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//    {
//        UIPopoverPresentationController *popPresenter = [alertController
//                                                         popoverPresentationController];
//        popPresenter.sourceView = sender;
//        popPresenter.sourceRect = sender.bounds;
//    }
//
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)viewWillAppear:(BOOL)animated
{
    if (self.isOpenedThroughButton && !callOptionShownOnce) {
        callOptionShownOnce = true;
           [self showVideoCallingOptions];
       }
    if(!aptDetailsSet)
    {
        aptDetailsSet = YES;
        [self setAptDetails];
    }
    

}

-(void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)validateApnmntStatus:(NSNotification*)dictObj
{
    [hud removeFromSuperview];
    NSDictionary* response = dictObj.object;
    NSString* responseCodeString=  [response valueForKey:RESPONSE_CODE];

      if ([responseCodeString intValue] == 2001 || [responseCodeString intValue] == -1001)
         {
             return;
         }
    
    if([responseCodeString intValue] == 200)
    {
        [self.delegate myClassDelegateMethod:self];
       
         [self setStatusStringUsingStatusId:selectedAppointmentStatus];
    }
    
  
    
}

-(void)setAptDetails
{
   
    [self setStatusStringUsingStatusId:self.patientDetails.AppointmentStatus];
    
    self.patientNameLabel.text = [NSString stringWithFormat:@"%@ %@ %@",self.patientDetails.PatTitle, self.patientDetails.PatFirstname, self.patientDetails.PatLastname];
    
    self.contactNameLabel.text = [NSString stringWithFormat:@"%@",self.patientDetails.PatientContactNumber];
    
    self.dateAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@",self.patientDetails.AppointmentDate, self.patientDetails.AppointmentTime];
    
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
    if ([[AppPreferences sharedAppPreferences] isReachable]) {
        [self showStatusChangeOptions:sender];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:NO_INTERNET_TITLE_MESSAGE withMessage:NO_INTERNET_DETAIL_MESSAGE withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
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
               [self updateStatus:status];
                break;
            
            case 3:
                [self updateStatus:status];
                break;
            
            case 6:
                [self updateStatus:status];
                break;
            default:
                break;
        }
                      
       // [self validateApnmntStatus:nil];
                        
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

-(void)showHud
{
    hud.minSize = CGSizeMake(150.f, 100.f);
    
    [hud hideAnimated:NO];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    
    hud.label.text = @"Changing Appointment Status...";
    
    hud.detailsLabel.text = @"Please wait";
    
    
}

-(void)updateStatus:(int)status
{
    if ([[AppPreferences sharedAppPreferences] isReachable]) {
        [self showHud];
                       selectedAppointmentStatus = [NSString stringWithFormat:@"%d", status];
                      [[APIManager sharedManager] updateAppointmentStatus:selectedAppointmentStatus appointmentId:[NSString stringWithFormat:@"%ld",self.patientDetails.AppointementID]];
                     }
                     else
                     {
                         [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:NO_INTERNET_TITLE_MESSAGE withMessage:NO_INTERNET_DETAIL_MESSAGE withCancelText:nil withOkText:@"OK" withAlertTag:1000];
                     }
//    selectedAppointmentStatus = [NSString stringWithFormat:@"%d", status];
//    [self validateApnmntStatus:nil];
                  
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
- (IBAction)whatsappButtonClicked:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?phone=%@",self.patientDetails.PatientContactNumber]]];
}
- (IBAction)facetimeButtonClicked:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"facetime://%@",self.patientDetails.PatientContactNumber]]];
}
- (IBAction)phoneCallButtonClicked:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.patientDetails.PatientContactNumber]]];
}
@end
