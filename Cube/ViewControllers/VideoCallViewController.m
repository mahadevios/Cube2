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
    

//
//    [self showDatePicker];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(validateApntmntListResponse:) name:NOTIFICATION_GET_APNTMNT_LIST
      object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(validateApnmntStatus:) name:NOTIFICATION_UPDATE_APNTMNT_STATUS
      object:nil];
    self.dateTextField.delegate = self;
  
   [self setTextFieldDate:[NSDate date]];
    
    [self.dateTextField addTarget:self action:@selector(addDatePicker) forControlEvents:UIControlEventEditingDidBegin];
    
    self.searchButton.layer.cornerRadius = 4.0;
    
    [self.tabBarController.tabBar setHidden:YES];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
               
     [self.tabBarController.tabBar setHidden:YES];
    
    self.navigationItem.title=@"Appointments";
    
    patientsDetailsArray = [NSMutableArray new];
    
    [self setPatientDetailsFromAPI];
}

-(void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)validateApntmntListResponse:(NSNotification*)dictObj
{
    NSDictionary* responseDict=dictObj.object;
       
       NSString* responseCodeString=  [responseDict valueForKey:RESPONSE_CODE];
       
       NSArray* aptList =  [responseDict valueForKey:@"respArray"];
       
       for (NSDictionary* aptDict in aptList) {
           int aptId = [[aptDict valueForKey:@"AppointementID"] intValue];
           NSString* patientTitle = [aptDict valueForKey:@"PatTitle"];
           NSString* PatFirstname = [aptDict valueForKey:@"PatFirstname"];
           NSString* PatLastname = [aptDict valueForKey:@"PatLastname"];
           NSString* MRN = [aptDict valueForKey:@"MRN"];
           NSString* NHSNumber = [aptDict valueForKey:@"NHSNumber"];
           NSString* DOB = [aptDict valueForKey:@"DOB"];
           NSString* PatientContactNumber = [aptDict valueForKey:@"PatientContactNumber"];
           NSString* PatientContactNumber2 = [aptDict valueForKey:@"PatientContactNumber2"];
           NSString* AppointmentDate = [aptDict valueForKey:@"AppointmentDate"];
           NSString* AppointmentTime = [aptDict valueForKey:@"AppointmentTime"];
           NSString* AppointmentStatus = [aptDict valueForKey:@"AppointmentStatus"];
           NSString* DepartmentID = [aptDict valueForKey:@"DepartmentID"];
           
           PatientDetails* patientDetails = [PatientDetails new];
           patientDetails.AppointementID = aptId;
           patientDetails.PatTitle = patientTitle;
           patientDetails.PatFirstname = PatFirstname;
           patientDetails.PatLastname = PatLastname;
           patientDetails.MRN = MRN;
           patientDetails.NHSNumber = NHSNumber;
           patientDetails.DOB = DOB;
           patientDetails.PatientContactNumber = PatientContactNumber;
           patientDetails.PatientContactNumber2 = PatientContactNumber2;
           patientDetails.AppointmentDate = AppointmentDate;
           patientDetails.AppointmentTime = AppointmentTime;
           patientDetails.AppointmentStatus = AppointmentStatus;
           patientDetails.DepartmentID = DepartmentID;
       }

       if ([responseCodeString intValue] == 2001 || [responseCodeString intValue] == -1001)
       {
          
       }
      
}

-(void) setPatientDetailsFromAPI
{
    NSDateFormatter *dfmt = [[NSDateFormatter alloc] init];
    [dfmt setDateFormat:@"dd-MM-yyyy"];
    
    for (int i=0; i<20; i++) {
        PatientDetails* patientDetails = [PatientDetails new];
        patientDetails.AppointementID = 1;
        patientDetails.PatTitle = [NSString stringWithFormat:@"Mr."];
        patientDetails.PatFirstname = [NSString stringWithFormat:@"FName%d", i+1];
        patientDetails.PatLastname = [NSString stringWithFormat:@"LName%d", i+1];
        
        patientDetails.PatientContactNumber = [NSString stringWithFormat:@"+918956498302"];
        
        NSString *dateString = [dfmt stringFromDate:[NSDate date]];
        patientDetails.AppointmentDate = [NSString stringWithFormat:@"%@",dateString];
        patientDetails.AppointmentTime = [NSString stringWithFormat:@"%@",@"02:23 PM"];
        
        patientDetails.DOB = [NSString stringWithFormat:@"%d/1/1993", i+1];
        
        patientDetails.MRN = [NSString stringWithFormat:@"MRN %d", i+1];
        patientDetails.NHSNumber = [NSString stringWithFormat:@"NHS London %d", i+1];
        
     
        patientDetails.PatientContactNumber2 = [NSString stringWithFormat:@"+918956498302"];
        
        
//
        
        patientDetails.AppointmentStatus = @"1";
        patientDetails.DepartmentID = [NSString stringWithFormat:@"%@",@"18929"];
//        patientDetails.emailId = [NSString stringWithFormat:@"patient%d@gml.com", i+1];
        
        
        [patientsDetailsArray addObject:patientDetails];
    }
    
    [self.tabelView reloadData];
}
-(void)viewWillAppear:(BOOL)animated
{
//    NSDate* date = [NSDate date];
     
}

-(void) setTextFieldDate:(NSDate*)date
{
    NSDateFormatter *dfmt = [[NSDateFormatter alloc] init];
      [dfmt setDateFormat:@"dd MMMM yyyy"];
      NSString *dateString = [dfmt stringFromDate:date];
      
      self.dateTextField.text = dateString;
}

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
//-(void)textFieldDidBeginEditing:(UITextField *)textField
//{
//      [self addDatePicker];
//}
-(void) showVideoCallingOptionsOrNumbers:(UIButton*)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tabelView];
    NSIndexPath *indexPath = [self.tabelView indexPathForRowAtPoint:buttonPosition];
    
    PatientDetails* pD = [patientsDetailsArray objectAtIndex:indexPath.row];
    
    if ([pD.PatientContactNumber2 isEqualToString:@""]  || pD.PatientContactNumber == nil) {
        [self showVideoCallingOptions:sender contactNo:pD.PatientContactNumber];
    }
    else
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tabelView];
        NSIndexPath *indexPath = [self.tabelView indexPathForRowAtPoint:buttonPosition];
        
        PatientDetails* pD = [patientsDetailsArray objectAtIndex:indexPath.row];
        alertController = [UIAlertController alertControllerWithTitle:@""
                                                              message:@"Select Contact Number to make a call"
                                                       preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* actionContact1 = [UIAlertAction actionWithTitle:pD.PatientContactNumber
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action)
                                         {
            
           [self showVideoCallingOptions:sender contactNo:pD.PatientContactNumber];
                 
            
        }];
        [alertController addAction:actionContact1];

        UIAlertAction* actionContact2 = [UIAlertAction actionWithTitle:pD.PatientContactNumber2
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action)
                                         {
            
               [self showVideoCallingOptions:sender contactNo:pD.PatientContactNumber];
            
        }]; //You can use a block here to handle a press on this button
       
        [alertController addAction:actionContact2];
        
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
}
-(void) showVideoCallingOptions:(UIButton*)sender contactNo:(NSString*)contactNo
{
   
    alertController = [UIAlertController alertControllerWithTitle:@""
                                                          message:@"Select an application to make a call"
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* actionWhatsapp = [UIAlertAction actionWithTitle:@"Whatsapp"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
        
       
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?phone=%@",contactNo]]];
        
    }]; //You can use a block here to handle a press on this button
    UIImage *img = [UIImage imageNamed:@"Whatsapp"];
    [actionWhatsapp setValue:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [alertController addAction:actionWhatsapp];

    UIAlertAction* actionFaceTime = [UIAlertAction actionWithTitle:@"FaceTime"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
        
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"facetime://%@",contactNo]]];
        
    }]; //You can use a block here to handle a press on this button
    img = [UIImage imageNamed:@"FaceTime"];
    [actionFaceTime setValue:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [alertController addAction:actionFaceTime];
    
//    UIAlertAction* actionGoogleDuo = [UIAlertAction actionWithTitle:@"Google Duo"
//                                                             style:UIAlertActionStyleDefault
//                                                           handler:^(UIAlertAction * action)
//                                     {
//
//
//
//    }]; //You can use a block here to handle a press on this button
//    img = [UIImage imageNamed:@"GoogleDuo"];
//    [actionGoogleDuo setValue:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
//    [alertController addAction:actionGoogleDuo];
    
    UIAlertAction* phoneCall = [UIAlertAction actionWithTitle:@"Phone Call"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",contactNo]]];

        
    }]; //You can use a block here to handle a press on this button
    img = [UIImage imageNamed:@"PhoneCall"];
    [phoneCall setValue:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [alertController addAction:phoneCall];
    
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
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tabelView];
    NSIndexPath *indexPath = [self.tabelView indexPathForRowAtPoint:buttonPosition];
    
    PatientDetails* pD = [patientsDetailsArray objectAtIndex:indexPath.row];
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
    actionDelete = [UIAlertAction actionWithTitle:@"Update"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
        
        switch (status) {
            case 2:
                pD.AppointmentStatus = @"2";
//                [[APIManager sharedManager] updateAppointmentStatus:[NSString stringWithFormat:@"%d",status] appointmentId:[NSString stringWithFormat:@"%ld",pD.AppointementID]];
                break;
            
            case 3:
                pD.AppointmentStatus = @"3";
//                [[APIManager sharedManager] updateAppointmentStatus:[NSString stringWithFormat:@"%d",status] appointmentId:[NSString stringWithFormat:@"%ld",pD.AppointementID]];
                break;
            
            case 6:
                pD.AppointmentStatus = @"6";
//                [[APIManager sharedManager] updateAppointmentStatus:[NSString stringWithFormat:@"%d",status] appointmentId:[NSString stringWithFormat:@"%ld",pD.AppointementID]];
                break;
            default:
                break;
        }
                      
        [patientsDetailsArray replaceObjectAtIndex:indexPath.row withObject:pD];
        
        NSArray* arr = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tabelView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionDelete];
    
    
    actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction * action)
                    {
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                        
                    }]; //You can use a block here to handle a press on this button
    
    [alertController addAction:actionCancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)addDatePicker
{
    picker = [[UIDatePicker alloc]init];
    picker.datePickerMode = UIDatePickerModeDate;

      [picker setDate:[NSDate date]];
      [picker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
      [self.dateTextField setInputView:picker];
      
      toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - picker.frame.size.height -40, [UIScreen mainScreen].bounds.size.width, 50)];
      toolbar.barStyle = UIBarStyleBlackTranslucent;
      toolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onDoneButtonClick)]];
      [toolbar sizeToFit];
      [self.view addSubview:toolbar];
}

-(void)updateTextField:(id)sender
{
  UIDatePicker *picker = (UIDatePicker*)self.dateTextField.inputView;
    
    [self setTextFieldDate:picker.date];
//  self.dateTextField.text = [NSString stringWithFormat:@"%@",picker.date];
}
//
//- (void)showDatePicker {
//    picker = [[UIDatePicker alloc] init];
//    picker.backgroundColor = [UIColor whiteColor];
//    [picker setValue:[UIColor blackColor] forKey:@"textColor"];
//
//    picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    picker.datePickerMode = UIDatePickerModeDate;
//
//    [picker addTarget:self action:@selector(dueDateChanged:) forControlEvents:UIControlEventValueChanged];
//    picker.frame = CGRectMake(0.0, 10, [UIScreen mainScreen].bounds.size.width/2, 150);
//    [self.view addSubview:picker];
//
//    toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, picker.frame.origin.y + picker.frame.size.height, [UIScreen mainScreen].bounds.size.width, 50)];
//    toolbar.barStyle = UIBarStyleBlackTranslucent;
//    toolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onDoneButtonClick)]];
//    [toolbar sizeToFit];
//    [self.view addSubview:toolbar];
//}

-(void) dueDateChanged:(UIDatePicker *)sender {

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    NSLog(@"Picked the date %@", [dateFormatter stringFromDate:[sender date]]);
//    YOUR_LABEL.TEXT = [dateFormatter stringFromDate:[sender date]];
}

-(void) removePickerAndDoneButton
{
    [toolbar removeFromSuperview];
       [picker removeFromSuperview];
       [self.dateTextField resignFirstResponder];
}
-(void)onDoneButtonClick {
   
    [self removePickerAndDoneButton];
}
//-(void) getContactPermission
//{
//   CNContactStore *store = [[CNContactStore alloc] init];
//    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        if (granted == YES) {
//            //keys with fetching properties
//            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
//            NSString *containerId = store.defaultContainerIdentifier;
//            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
//            NSError *error;
//            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
//            if (error) {
//                NSLog(@"error fetching contacts %@", error);
//            } else {
//                for (CNContact *contact in cnContacts) {
//                    // copy data to my custom Contacts class.
//                    Contact *newContact = [[Contact alloc] init];
//                    newContact.firstName = contact.givenName;
//                    newContact.lastName = contact.familyName;
//                    UIImage *image = [UIImage imageWithData:contact.imageData];
//                    newContact.image = image;
//                    for (CNLabeledValue *label in contact.phoneNumbers) {
//                        NSString *phone = [label.value stringValue];
//                        if ([phone length] > 0) {
//                            [contact.phones addObject:phone];
//                        }
//                    }
//                }
//            }
//        }
//    }];
//}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Appointments";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return patientsDetailsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    PatientDetails* patientDetails = [patientsDetailsArray objectAtIndex:indexPath.row];
    UILabel* patientName = [cell viewWithTag:101];
    UILabel* status = [cell viewWithTag:102];
    UIButton* statusButton = [cell viewWithTag:103];
    UILabel* dateTime = [cell viewWithTag:104];
    UIButton* callButton = [cell viewWithTag:105];
//    if ([cell viewWithTag:indexPath.row] != nil) {
//        [[cell viewWithTag:indexPath.row] removeFromSuperview];
//    }
//    callButton.tag = indexPath.row;
    if (status.text != nil) {
        status.text = @"";
    }
    
    switch ([patientDetails.AppointmentStatus intValue]) {
        case 1:
            status.text = @"New";
            break;
        case 2:
            status.text = @"Completed";
            break;
        case 3:
             status.text = @"Not Attended";
            break;
            
        case 6:
             status.text = @"Closed";
            break;
        default:
            status.text = @"Undefined";
            break;
    }
    
//    status.text = patientDetails.AppointmentStatus;
    
    [statusButton addTarget:self action:@selector(showStatusChangeOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    [callButton addTarget:self action:@selector(showVideoCallingOptionsOrNumbers:) forControlEvents:UIControlEventTouchUpInside];
    UILabel* contactNo1 = [cell viewWithTag:106];
    UILabel* contactNo2 = [cell viewWithTag:107];

    UILabel* dob = [cell viewWithTag:108];
//    UILabel* email = [cell viewWithTag:106];
    UILabel* hospitalNo = [cell viewWithTag:109];
    UILabel* nhsNo = [cell viewWithTag:110];
    
    patientName.text = [NSString stringWithFormat:@"%@ %@ %@", patientDetails.PatTitle, patientDetails.PatFirstname, patientDetails.PatLastname];
    
    contactNo1.text = patientDetails.PatientContactNumber;
    contactNo2.text = patientDetails.PatientContactNumber2;

    dateTime.text = [NSString stringWithFormat:@"%@ %@", patientDetails.AppointmentDate, patientDetails.AppointmentTime];
    dob.text = patientDetails.DOB;
//    email.text = patientDetails.emailId;
    hospitalNo.text = patientDetails.MRN;
    nhsNo.text = patientDetails.NHSNumber;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.splitViewController.isCollapsed == true || self.splitViewController == nil)
    {
        
        detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AppointmentDetailsViewController"];
        
        detailVC.selectedRow = indexPath.row ;
        detailVC.patientDetails = [patientsDetailsArray objectAtIndex:indexPath.row];
        detailVC.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self.navigationController presentViewController:detailVC animated:YES completion:nil];
        //                self.tableView.allowsMultipleSelection = NO;
        
    }
    else
    {
        [self setAudioDetailOrEmptyViewController:indexPath.row];
        
    }
    
//    [tableView beginUpdates]; // tell the table you're about to start making changes
//
//    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
//        self.expandedIndexPath = nil;
//    } else {
//        self.expandedIndexPath = indexPath;
//    }
//
//    [tableView endUpdates]; // tell the table you're done making your changes
}

-(void)setAudioDetailOrEmptyViewController:(int)selectedIndex
{
    
    
    if (self.splitViewController != nil && self.splitViewController.isCollapsed == false) // if not collapsed that is reguler width hnce ipad
    {
          
        if(patientsDetailsArray.count == 0) // if transferred count 0 then show empty VC  else show audio details
        {
            [self addEmptyVCToSplitVC];
        }
        else
        {
            [self addAudioDetailsVCToSplitVC:selectedIndex];
        }
            
        
    }
    
    
}

-(void)addEmptyVCToSplitVC
{
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EmptyViewController"];
    
    NSMutableArray* subVC = [[NSMutableArray alloc] initWithArray:[self.splitViewController viewControllers]];
    
    if (subVC.count > 1)
    {
        [subVC removeObjectAtIndex:1];
        
        [subVC addObject:vc];
        
    }
    else
    {
        [subVC addObject:vc];
    }
    
    [self.splitViewController setViewControllers:subVC];
    
}

-(void)addAudioDetailsVCToSplitVC:(int)selectedIndex
{
//    if (detailVC == nil)
//    {
        detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AppointmentDetailsViewController"];

//    }
    
    detailVC.delegate = self;
    detailVC.patientDetails = [patientsDetailsArray objectAtIndex:selectedIndex];

//    detailVC.selectedView = self.currentViewName;
    //                detailVC.listSelected = 0;
    
    detailVC.selectedRow = selectedIndex;
    
    [self.navigationController pushViewController:detailVC animated:true];
//    [self.splitViewController showDetailViewController:detailVC sender:self];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Compares the index path for the current cell to the index path stored in the expanded
    // index path variable. If the two match, return a height of 100 points, otherwise return
    // a height of 44 points.
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        return 200.0; // Expanded height
    }
    return 75.0; // Normal height
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)myClassDelegateMethod:(AppointmentDetailsViewController *)sender
{
    [self.tabelView reloadData];
    
    [self addEmptyVCToSplitVC];

}

- (IBAction)searchButtonClicked:(id)sender {
    
    [self removePickerAndDoneButton];
}
@end
