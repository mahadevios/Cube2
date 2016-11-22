//
//  RegistrationViewController.h
//  Cube
//
//  Created by mac on 12/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface RegistrationViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)backButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *IDTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
- (IBAction)submitButtonClicked:(id)sender;
@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) MBProgressHUD *hud;

@end
