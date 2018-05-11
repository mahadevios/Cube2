//
//  SelectDepartmentViewController.m
//  Cube
//
//  Created by mac on 27/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "SelectDepartmentViewController.h"
#import "MainTabBarViewController.h"
#import "LoginViewController.h"
#import "DepartMent.h"
#import "RegistrationViewController.h"
#import "MainTabBarViewController.h"
#import "SharedSession.h"
#import "AppDelegate.h"

@interface SelectDepartmentViewController ()

@end

@implementation SelectDepartmentViewController
@synthesize tableView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Select Department";
    self.navigationItem.hidesBackButton=YES;

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Database* db=[Database shareddatabase];
    departmentNameArray= [db getDepartMentNames];
    return departmentNameArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UILabel* departmentNameLabel=[cell viewWithTag:101];
    departmentNameLabel.text=[departmentNameArray objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];

    UITableViewCell* cell=[tableview cellForRowAtIndexPath:indexPath];
    UILabel* departmentNameLabel= [cell viewWithTag:101];
    //MainTabBarViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarViewController"];
    // LoginViewController* vc=[self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    // [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"] animated:YES completion:nil];
    //[vc dismissViewControllerAnimated:YES completion:nil];
   DepartMent* deptObj= [[Database shareddatabase] getDepartMentFromDepartmentName:departmentNameLabel.text];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deptObj];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SELECTED_DEPARTMENT_NAME];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoadedFirstTime"];

    MainTabBarViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarViewController"];

   // [[Database shareddatabase] setDepartment];//to insert default department for imported files

    [[Database shareddatabase] setDepartment];//to insert default department for imported files
   // [self needsUpdate];
    
    
     NSURLSession*  session = [SharedSession getSharedSession:[APIManager sharedManager]];
    
//    [self.view endEditing:true];
    

    
    [self dismissViewControllerAnimated:true completion:nil];

    [[self presentingViewController] dismissViewControllerAnimated:true completion:nil];
//
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:vc];

    
//    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
//
//    [appDelegate.window setRootViewController:vc];
   // [self dismissViewControllerAnimated:NO completion:^{[self checkAndDismissViewController];}];
    
    //    [self performSelector:@selector(checkAndDismissViewController) withObject:nil afterDelay:0.5];
    //[self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarViewController"] animated:YES];
    //NSLog(@"%@",self.navigationController);
    
}
//-(BOOL) needsUpdate
//{
//    //    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    //    NSString* appID = infoDictionary[@"CFBundleIdentifier"];
//    //    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
//    //    NSData* data = [NSData dataWithContentsOfURL:url];
//    //    NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    //
//    //    if ([lookup[@"resultCount"] integerValue] == 1){
//    //        NSString* appStoreVersion = lookup[@"results"][0][@"version"];
//    //        NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
//    ////        if (![appStoreVersion isEqualToString:currentVersion]){
//    ////            NSLog(@"Need to update [%@ != %@]", appStoreVersion, currentVersion);
//    ////            return YES;
//    ////        }
//    //        if ([appStoreVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
//    //            // *** Present alert about updating to user ***
//    //            NSLog(@"Need to update [%@ != %@]", appStoreVersion, currentVersion);
//    //                        return YES;
//    //        }
//    //    }
//    
//    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSString* appID = infoDictionary[@"CFBundleIdentifier"];
//    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
//    NSURLSession         *  session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *  theTask = [session dataTaskWithRequest: [NSURLRequest requestWithURL: url] completionHandler:
//                                       ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
//                                       {
//                                           NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                           if ([lookup[@"resultCount"] integerValue] == 1)
//                                           {
//                                               
//                                               NSString* appStoreVersion = lookup[@"results"][0][@"version"];
//                                               NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
//                                               
//                                               if (![appStoreVersion isEqualToString:currentVersion])
//                                               {
//                                                   NSLog(@"Need to update [%@ != %@]", appStoreVersion, currentVersion);
//                                                   //                                                        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Received" withMessage:@"" withCancelText:@"Cancel" withOkText:@"Ok" withAlertTag:1000];
//                                                   
//                                                   alertController = [UIAlertController alertControllerWithTitle:@"Update available for Cube dictate"
//                                                                                                         message:nil
//                                                                                                  preferredStyle:UIAlertControllerStyleAlert];
//                                                   actionDelete = [UIAlertAction actionWithTitle:@"Update"
//                                                                                           style:UIAlertActionStyleDefault
//                                                                                         handler:^(UIAlertAction * action)
//                                                                   {
//                                                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.com/apps/CubeDictate"]];
//                                                                   }]; //You can use a block here to handle a press on this button
//                                                   [alertController addAction:actionDelete];
//                                                   
//                                                   
//                                                   actionCancel = [UIAlertAction actionWithTitle:@"Later"
//                                                                                           style:UIAlertActionStyleCancel
//                                                                                         handler:^(UIAlertAction * action)
//                                                                   {
//                                                                       [alertController dismissViewControllerAnimated:YES completion:nil];
//                                                                       
//                                                                   }]; //You can use a block here to handle a press on this button
//                                                   [alertController addAction:actionCancel];
//                                                   
//                                                   [[[[UIApplication sharedApplication] keyWindow] rootViewController]  presentViewController:alertController animated:YES completion:nil];
//                                                   
//                                                   //return YES;
//                                               }
//                                               //                                           if ([appStoreVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
//                                               //                                               // *** Present alert about updating to user ***
//                                               //
//                                               //                                               [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Received" withMessage:@"" withCancelText:@"Cancel" withOkText:@"Ok" withAlertTag:1000];
//                                               //                                           }
//                                           }
//                                       }];
//    
//    [theTask resume];
//    return NO;
//}
//
- (void) checkAndDismissViewController
{
    [self.view endEditing:YES];
    id viewController = [self topViewController];
    if([viewController isKindOfClass:[LoginViewController class]]){
        //do something
        [viewController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

- (void)didReceiveMemoryWarning
{
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
