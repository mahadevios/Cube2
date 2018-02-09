//
//  RegistrationViewController.m
//  Cube
//
//  Created by mac on 12/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "RegistrationViewController.h"
#import "PinRegistrationViewController.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"
#import "Keychain.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController
@synthesize IDTextField,passwordTextfield;
@synthesize submitButton,cancelButton,hud,window;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    submitButton.layer.cornerRadius=7.0f;
    cancelButton.layer.cornerRadius=7.0f;
    IDTextField.layer.cornerRadius=7.0f;
    passwordTextfield.layer.cornerRadius=7.0f;
    IDTextField.layer.borderColor=[UIColor grayColor].CGColor;
    passwordTextfield.layer.borderColor=[UIColor grayColor].CGColor;
    IDTextField.layer.borderWidth=1.0f;
    passwordTextfield.layer.borderWidth=1.0f;

    IDTextField.delegate=self;
    passwordTextfield.delegate=self;
    
    [IDTextField becomeFirstResponder];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uIdPwdResponseCheck:) name:NOTIFICATION_AUTHENTICATE_API
                                               object:nil];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)uIdPwdResponseCheck:(NSNotification* )dictObj
{
    NSDictionary* dict=dictObj.object;
    NSString* responseCodeString=  [dict valueForKey:RESPONSE_CODE];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [hud hideAnimated:YES];

    if ([responseCodeString intValue]==200)
    {
        PinRegistrationViewController* regiController=(PinRegistrationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PinRegistrationViewController"];
        //NSLog(@"%@",[UIApplication sharedApplication].keyWindow.rootViewController);
//        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:regiController
//                           animated:NO
//                         completion:nil];
        [passwordTextfield resignFirstResponder];
        [self presentViewController:regiController animated:NO completion:nil];
        //[self dismissViewControllerAnimated:NO completion:nil];
        
    }
    if ([responseCodeString intValue]==401)
    {
        //[self dismissViewControllerAnimated:NO completion:nil];
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Authentication failed!" withMessage:@"Account id or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        IDTextField.text=nil;
        passwordTextfield.text=nil;
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

- (IBAction)backButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)submitButtonClicked:(id)sender
{
    if (IDTextField.text.length==0 || passwordTextfield.text.length==0)
    {
        
        NSString* title;
        NSString* message;
        UIAlertController *alertController;
        UIAlertAction *actionOk;
                   title=@"Incomplete Data";
            message=@"Id or password cannot be null";
            alertController = [UIAlertController alertControllerWithTitle:title
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
            actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
                            
                        }]; //You can use a block here to handle a press on this button
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
        

    }
    else
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.minSize = CGSizeMake(150.f, 100.f);

        hud.label.text = @"Validating...";
        hud.detailsLabel.text = @"Please wait";
        NSString*  macId=[Keychain getStringForKey:@"udid"];


        [[APIManager sharedManager] authenticateUserMacID:macId password:passwordTextfield.text username:IDTextField.text];
    }
}
- (IBAction)cancelButtonClicked:(id)sender
{
    IDTextField.text=@"";
    passwordTextfield.text=@"";
    [IDTextField becomeFirstResponder];
    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Hit home button to exit" withMessage:@"" withCancelText:nil withOkText:@"OK" withAlertTag:1000];}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==IDTextField)
    {
        [passwordTextfield becomeFirstResponder];
    }
    else
        [passwordTextfield resignFirstResponder];
    return  YES;
}


@end
