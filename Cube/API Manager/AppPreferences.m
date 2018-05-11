//
//  AppPreferences.m
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "AppPreferences.h"
#include <sys/xattr.h>
#import "AppDelegate.h"


@implementation AppPreferences
@synthesize currentSelectedItem;
@synthesize alertDelegate;
@synthesize isReachable;
@synthesize  userObj;

static AppPreferences *singleton = nil;

// Shared method
+(AppPreferences *) sharedAppPreferences
{
    if (singleton == nil)
    {
        singleton = [[AppPreferences alloc] init];
    }
    
    return singleton;
}


// Init method
-(id) init
{
    self = [super init];
    
    if (self)
    {
        self.currentSelectedItem = 0;
        //[self startReachabilityNotifier];
    }
    
    return self;
}


/*================================================================================================================================================*/


-(void) startReachabilityNotifier
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           //NSLog(@"Reachable");
                           isReachable = YES;
                       });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           //NSLog(@"Not Reachable");
                           isReachable = NO;
                           
                       });
    };
    
    [reach startNotifier];
}

/*================================================================================================================================================*/

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        //NSLog(@"Reachable");
        isReachable = YES;
    }
    else
    {
        //NSLog(@"Not Reachable");
        isReachable = NO;
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showNoInternetMessage) userInfo:nil repeats:NO];
    }
}

-(void) showNoInternetMessage
{
//    if (![self isReachable])
//    {
//        [self showAlertViewWithTitle:@"No internet connection" withMessage:@"Please turn on your inernet connection to access this feature" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }
}

/*=================================================================================================================================================*/

-(void) showHudWithTitle:(NSString*)title detailText:(NSString*)detailText
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:true];
    
    hud.tag = 789;
    
    hud.minSize = CGSizeMake(150.0, 100.0);
    
    hud.label.text = title;
    
    hud.detailsLabel.text = detailText;
}


-(void) showAlertViewWithTitle:(NSString *) title withMessage:(NSString *) message withCancelText:(NSString *) cancelText withOkText:(NSString *) okText withAlertTag:(int) tag
{
    
    dispatch_queue_t currentQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(currentQueue, ^
                   {
                       __block UIAlertView *alertView  = nil;
                       
                       dispatch_sync(currentQueue, ^
                                     {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelText otherButtonTitles:okText, nil];
                                             alertView.tag = tag;
                                         });
                                        
                                         
                                     });
                       
                       dispatch_sync(dispatch_get_main_queue(), ^
                                     {
                                         [alertView show];

                                     });
                   });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.alertDelegate appPreferencesAlertButtonWithIndex:(int)buttonIndex withAlertTag:alertView.tag];
}



- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

-(void)createDatabaseReplica
{
    NSString *destpath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Cube_DB_Replica.sqlite"];
    // NSString *sourcepath=[[NSBundle mainBundle]pathForResource:@"Cube_DB" ofType:@"sqlite"];
    NSString *sourcepath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Cube_DB.sqlite"];
    
    NSLog(@"%@",NSHomeDirectory());
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:destpath])
    {
        //  NSLog(@"%@",NSHomeDirectory());
        
        [[NSFileManager defaultManager] copyItemAtPath:sourcepath toPath:destpath error:nil];
    }
    else
    {
        [[NSFileManager defaultManager] removeItemAtPath:destpath error:nil];
        
        [[NSFileManager defaultManager] copyItemAtPath:sourcepath toPath:destpath error:nil];
        
    }
    
}







@end
