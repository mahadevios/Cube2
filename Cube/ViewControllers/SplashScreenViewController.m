//
//  SplashScreenViewController.m
//  Cube
//
//  Created by mac on 31/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "LoginViewController.h"
#import "RegistrationViewController.h"
#import "PinRegistrationViewController.h"
#import "UIDevice+Identifier.h"
#import "PopUpCustomView.h"
#import "NSData+AES256.h"
#import "Keychain.h"
#import "TandCViewController.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController
@synthesize hud;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    [[APIManager sharedManager] checkDeviceRegistrationMacID:macId];
    
   

    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceRegistrationResponseCheck:) name:NOTIFICATION_CHECK_DEVICE_REGISTRATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeAlertView) name:kReachabilityChangedNotification
                                               object:nil];
    
    NSString*  macId = @"";
    macId = [Keychain getStringForKey:@"udid"];
    
    
    if (macId.length <= 0 || macId == nil)
    {
        macId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [Keychain setString:macId forKey:@"udid"];
    }
    
    //NSLog(@"%@",macId);
    
    //    hud.minSize = CGSizeMake(150.f, 100.f);
    //    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    hud.mode = MBProgressHUDModeIndeterminate;
    //    hud.label.text = @"Loading";
    //    hud.detailsLabel.text = @"Please wait";
    
    
    //[self checkDeviceRegistration];
//    NSLog(@"Registering for push notifications...");
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    if ([AppPreferences sharedAppPreferences].recordNewOffline == YES)
    {
        //        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"dismiss"];
        
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
        
        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"] animated:YES completion:nil];
    }
    else
    {
        [self performSelector:@selector(checkDeviceRegistration) withObject:nil afterDelay:0.0];

    }
    


}
-(void)checkDeviceRegistration
{
    NSString*     macId=[Keychain getStringForKey:@"udid"];
    //macId=[NSString stringWithFormat:@"%@1234",macId];
    if ([AppPreferences sharedAppPreferences].isReachable)
    {
        if (!APIcalled)
        {
            
            [[APIManager sharedManager] checkDeviceRegistrationMacID:macId];
            APIcalled=true;
        }
    }
    else
    {
//        UIView* view=[[[UIApplication sharedApplication] keyWindow] viewWithTag:222];
//        UIView* popupView= [view viewWithTag:223];
//        UIButton* retryButton= [popupView viewWithTag:225];
//        [retryButton setEnabled:YES];
        [self addAlertView];
//        [retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    }
}

-(void)addAlertView
{
//   NSArray* subviews= [[UIApplication sharedApplication] keyWindow].subviews;
//    bool alreadyAdded = false;
//    for (int i=0; i<subviews.count; i++)
//    {
//       UIView* view= [subviews objectAtIndex:i];
//        if (view.tag==222)
//        {
//            alreadyAdded=YES;
//        }
//    }
    //[[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    
    UIView* view=[[[UIApplication sharedApplication] keyWindow] viewWithTag:222];
   
    
    if (view==NULL)
    {
//        UIView* internetMessageView=   [[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.10, self.view.center.y-50,self.view.frame.size.width*0.80, 100) offlineFrame:CGRectMake(0, self.view.center.y+150,self.view.frame.size.width, 50) senderForInternetMessage:self];
        
//  UIView* internetMessageView=   [[PopUpCustomView alloc]initWithFrame:CGRectMake(0, self.view.center.y+100,self.view.frame.size.width, 80) offlineFrame:CGRectMake(0, self.view.center.y+150,self.view.frame.size.width, 50) senderForInternetMessage:self];
        
          UIView* internetMessageView=   [[PopUpCustomView alloc]initWithFrame:CGRectMake(20, self.view.center.y+50,self.view.frame.size.width-40, 120) offlineFrame:CGRectMake(20, self.view.center.y+150,self.view.frame.size.width, 50) senderForInternetMessage:self];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:internetMessageView];
    }
    else
    {
        UIView* popupView= [view viewWithTag:223];
        UIButton* retryButton= [popupView viewWithTag:225];
        [retryButton setEnabled:YES];
        
       [retryButton setTitleColor:[UIColor colorWithRed:17/255.0 green:146/255.0 blue:(CGFloat)78/255.0 alpha:1] forState:UIControlStateNormal];
        
    }
   
   
        
    
}
-(void)refresh:(UIButton*)sender
{
    //sender.userInteractionEnabled=NO;
    [sender setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
     [sender setEnabled:NO];
   // NSString*     macId=[Keychain getStringForKey:@"udid"];

    [self performSelector:@selector(checkDeviceRegistration) withObject:nil afterDelay:0.1];
    //[[APIManager sharedManager] checkDeviceRegistrationMacID:macId];
    
}

-(void)goOfflineButtonClicked:(UIButton*)sender
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];
    
     [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"] animated:NO completion:nil];
}

-(void)removeAlertView
{
    if ([AppPreferences sharedAppPreferences].isReachable && (self.isViewLoaded && self.view.window))
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];//to remove no internet message
        NSString*     macId=[Keychain getStringForKey:@"udid"];
        //macId=[NSString stringWithFormat:@"%@123456",macId];
        if (!APIcalled)
        {

            [[APIManager sharedManager] checkDeviceRegistrationMacID:macId];
            APIcalled=true;

        }

    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERNET_MESSAGE object:nil];

    }

}
-(void)deviceRegistrationResponseCheck:(NSNotification *)responseDictObject
{
    
    NSDictionary* responseDict=responseDictObject.object;
    NSString* responseCodeString=  [responseDict valueForKey:RESPONSE_CODE];
    NSString* responsePinString=  [responseDict valueForKey:RESPONSE_PIN_VERIFY];
    NSString* tAndcString=  [responseDict valueForKey:RESPONSE_TC_FLAG];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [hud hideAnimated:YES];
    if ([responseCodeString intValue]==401 && [responsePinString intValue]==0)
    {
        //gotResponse=true;
        
        RegistrationViewController* regiController=(RegistrationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RegistrationViewController"];
        [self presentViewController:regiController animated:NO completion:NULL];
//        [[UIApplication sharedApplication].keyWindow.window.rootViewController presentViewController:regiController
//                                                     animated:NO
//                                                   completion:nil];
        
//        [[UIApplication sharedApplication].keyWindow.window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];

        
    }
    else
        if ([responseCodeString intValue]==200 && [responsePinString intValue]==0)
        {
            // gotResponse=true;
//            [[UIApplication sharedApplication].keyWindow.window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            
            PinRegistrationViewController* regiController=(PinRegistrationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PinRegistrationViewController"];
            [self presentViewController:regiController animated:NO completion:NULL];

//            [[UIApplication sharedApplication].keyWindow.window.rootViewController presentViewController:regiController
//                                                         animated:NO
//                                                       completion:nil];
            
        }
        else
            if ([responseCodeString intValue]==200 && [responsePinString intValue]==1 && [tAndcString intValue] == 0)
            {
                //gotResponse=true;
                
                TandCViewController *viewController = (TandCViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TandCViewController"];
                //[self.window makeKeyAndVisible];
                [self presentViewController:viewController animated:NO completion:NULL];
                
                //                [[UIApplication sharedApplication].keyWindow.window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                //
                
                
                //                [[UIApplication sharedApplication].keyWindow.window.rootViewController presentViewController:viewController
                //                                                             animated:NO
                //                                                           completion:nil];
                //
                
            }
        else
            if ([responseCodeString intValue]==200 && [responsePinString intValue]==1 && [tAndcString intValue] == 1)
            {
                //gotResponse=true;

                LoginViewController *viewController = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                //[self.window makeKeyAndVisible];
                [self presentViewController:viewController animated:NO completion:NULL];

//                [[UIApplication sharedApplication].keyWindow.window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
//                
                
                
//                [[UIApplication sharedApplication].keyWindow.window.rootViewController presentViewController:viewController
//                                                             animated:NO
//                                                           completion:nil];
//                
                
            }
            else
            {
                if ([[AppPreferences sharedAppPreferences] isReachable])
                {
                    //NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"macid=%@",macID],nilID
                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Something went wrong!" withMessage:@"Please try again" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                   
                }
                else
                {
                    
                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
                }

                
            }
    
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    //NSLog(@"disappesred");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
