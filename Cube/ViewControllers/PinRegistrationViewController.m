//
//  PinRegistrationViewController.m
//  Cube
//
//  Created by mac on 29/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "PinRegistrationViewController.h"
#import "RegistrationViewController.h"
#import "LoginViewController.h"
#import "User.h"
#import "Keychain.h"
@interface PinRegistrationViewController ()

@end

@implementation PinRegistrationViewController
@synthesize pinCode1TextField,pinCode2TextField,pinCode3TextField,pinCode4TextField,pinCode5TextField,pinCode6TextField,pinCode7TextField,pinCode8TextField,submitButton,cancelButton,hud;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [pinCode1TextField becomeFirstResponder];

}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateUserResponse:) name:NOTIFICATION_ACCEPT_PIN_API
                                               object:nil];
    pinCode1TextField.delegate=self;
    pinCode2TextField.delegate=self;
    pinCode3TextField.delegate=self;
    pinCode4TextField.delegate=self;
    
    pinCode5TextField.delegate=self;
    pinCode6TextField.delegate=self;
    pinCode7TextField.delegate=self;
    pinCode8TextField.delegate=self;
    
    pinCode1TextField.layer.cornerRadius=4.0f;
    pinCode1TextField.layer.masksToBounds=YES;
    pinCode1TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode1TextField.layer.borderWidth= 1.0f;
    
    pinCode2TextField.layer.cornerRadius=4.0f;
    pinCode2TextField.layer.masksToBounds=YES;
    pinCode2TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode2TextField.layer.borderWidth= 1.0f;
    
    pinCode3TextField.layer.cornerRadius=4.0f;
    pinCode3TextField.layer.masksToBounds=YES;
    pinCode3TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode3TextField.layer.borderWidth= 1.0f;
    
    pinCode4TextField.layer.cornerRadius=4.0f;
    pinCode4TextField.layer.masksToBounds=YES;
    pinCode4TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode4TextField.layer.borderWidth= 1.0f;
    
    pinCode5TextField.layer.cornerRadius=4.0f;
    pinCode5TextField.layer.masksToBounds=YES;
    pinCode5TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode5TextField.layer.borderWidth= 1.0f;
    
    pinCode6TextField.layer.cornerRadius=4.0f;
    pinCode6TextField.layer.masksToBounds=YES;
    pinCode6TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode6TextField.layer.borderWidth= 1.0f;
    
    pinCode7TextField.layer.cornerRadius=4.0f;
    pinCode7TextField.layer.masksToBounds=YES;
    pinCode7TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode7TextField.layer.borderWidth= 1.0f;
    
    pinCode8TextField.layer.cornerRadius=4.0f;
    pinCode8TextField.layer.masksToBounds=YES;
    pinCode8TextField.layer.borderColor=[[UIColor grayColor]CGColor];
    pinCode8TextField.layer.borderWidth= 1.0f;

    submitButton.layer.cornerRadius=4.0f;
    cancelButton.layer.cornerRadius=4.0f;

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

- (IBAction)submitButtonClicked:(id)sender
{
    NSString* pin=[NSString stringWithFormat:@"%@%@%@%@",pinCode1TextField.text,pinCode2TextField.text,pinCode3TextField.text,pinCode4TextField.text];
    NSString* confirmPin=[NSString stringWithFormat:@"%@%@%@%@",pinCode5TextField.text,pinCode6TextField.text,pinCode7TextField.text,pinCode8TextField.text];
    
    if ([pin isEqualToString:confirmPin])
    {
        if ([pinCode1TextField.text isEqualToString:@""] || [pinCode2TextField.text isEqualToString:@""] || [pinCode3TextField.text isEqualToString:@""] || [pinCode4TextField.text isEqualToString:@""])
        {
            title=@"Incomplete PIN!";
            message=@"Please enter PIN code properly";
            alertController = [UIAlertController alertControllerWithTitle:title
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
            actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                        {
                            pinCode5TextField.text=@"";
                            pinCode6TextField.text=@"";
                            pinCode7TextField.text=@"";
                            pinCode8TextField.text=@"";
                            [pinCode5TextField becomeFirstResponder];
                        }]; //You can use a block here to handle a press on this button
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
        hud.minSize = CGSizeMake(150.f, 100.f);
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSString*     macId=[Keychain getStringForKey:@"udid"];

        [pinCode8TextField resignFirstResponder];
        [[APIManager sharedManager] acceptPinMacID:macId Pin:pin];
        }
    }
    else
    {
        
        title=@"Pin confirmation failed";
        message=@"Please cofirm PIN ";
        alertController = [UIAlertController alertControllerWithTitle:title
                                                              message:message
                                                       preferredStyle:UIAlertControllerStyleAlert];
        actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        pinCode5TextField.text=@"";
                        pinCode6TextField.text=@"";
                        pinCode7TextField.text=@"";
                        pinCode8TextField.text=@"";
                        [pinCode5TextField becomeFirstResponder];
                    }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    
    }
}

-(void)validateUserResponse:(NSNotification*)responseDictObj
{
   NSDictionary* responseDict= responseDictObj.object;
    NSString* responseCodeString=  [responseDict valueForKey:RESPONSE_CODE];
    NSString* responsePinString=  [responseDict valueForKey:RESPONSE_PIN_VERIFY];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [hud hideAnimated:YES];

    if ([responseCodeString intValue]==401 && [responsePinString intValue]==0)
    {
        
       
        title=@"Pin registration failed";
        message=@"Please try again ";
        alertController = [UIAlertController alertControllerWithTitle:title
                                                              message:message
                                                       preferredStyle:UIAlertControllerStyleAlert];
        actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        pinCode1TextField.text=@"";
                        pinCode2TextField.text=@"";
                        pinCode3TextField.text=@"";
                        pinCode4TextField.text=@"";
                        pinCode5TextField.text=@"";
                        pinCode6TextField.text=@"";
                        pinCode7TextField.text=@"";
                        pinCode8TextField.text=@"";
                        [pinCode1TextField becomeFirstResponder];
                    }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    
    }
    if ([responseCodeString intValue]==200 && [responsePinString intValue]==1)
    {
        
        title=@"Note:";
        message=@"Pin code is registered successfully. To login you have to re-enter registered pin code and submit it.";
        alertController = [UIAlertController alertControllerWithTitle:title
                                                              message:message
                                                       preferredStyle:UIAlertControllerStyleAlert];
        actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                    {
                        [pinCode8TextField resignFirstResponder];

                       LoginViewController* regiController=(LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//                        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
//                        
//                        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:regiController
//                                           animated:NO
//                                         completion:nil];
                        [self presentViewController:regiController animated:NO completion:nil];

                    }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    }

    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength==1)
    {
        [self performSelector:@selector(resignResponder:) withObject:textField afterDelay:0.0];
    }
    return newLength <= 1;
}

-(void)resignResponder:(id)sender
{
    if (sender ==pinCode1TextField ||sender ==pinCode2TextField ||sender ==pinCode3TextField ||sender ==pinCode4TextField )
    {
        
        if (sender==pinCode1TextField)
        {
            [pinCode2TextField becomeFirstResponder];
            
        }
        if (sender==pinCode2TextField)
        {
            [pinCode3TextField becomeFirstResponder];
            
        }
        if (sender==pinCode3TextField)
        {
            [pinCode4TextField becomeFirstResponder];
            
        }
    }
    
    if (sender ==pinCode5TextField ||sender ==pinCode6TextField ||sender ==pinCode7TextField ||sender ==pinCode8TextField )
    {
        
        if (sender==pinCode5TextField)
        {
            [pinCode6TextField becomeFirstResponder];
            
        }
        if (sender==pinCode6TextField)
        {
            [pinCode7TextField becomeFirstResponder];
            
        }
        if (sender==pinCode7TextField)
        {
            [pinCode8TextField becomeFirstResponder];
            
        }
        if (sender==pinCode8TextField)
        {
            [pinCode8TextField resignFirstResponder];
            
        }
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==pinCode8TextField)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)caneclButtonClicked:(id)sender
{
    pinCode1TextField.text=@"";
    pinCode2TextField.text=@"";
    pinCode3TextField.text=@"";
    pinCode4TextField.text=@"";
    pinCode5TextField.text=@"";
    pinCode6TextField.text=@"";
    pinCode7TextField.text=@"";
    pinCode8TextField.text=@"";
    [pinCode1TextField becomeFirstResponder];
    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Hit home button to exit" withMessage:@"" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
}
@end
