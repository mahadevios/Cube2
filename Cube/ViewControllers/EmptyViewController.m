//
//  EmptyViewController.m
//  Cube
//
//  Created by mac on 22/05/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "EmptyViewController.h"
#import "AppPreferences.h"

@interface EmptyViewController ()

@end

@implementation EmptyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([self.usedByVCName isEqualToString:@"VRSVC"])
    {
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - self.splitViewController.primaryColumnWidth, self.view.frame.size.height)];

        self.webView.delegate = self;

        self.textFileContentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - self.splitViewController.primaryColumnWidth, self.view.frame.size.height)];
        
        
        [self setEmptyVCForDocFileView:0];
    }
}

-(void)setEmptyVCForDocFileView:(int)index
{
    if (self.splitViewController != nil && self.splitViewController.isCollapsed == false) // if not collapsed that is reguler width hnce ipad
    {
        if (self.dataToShowCount > 0)
        {
            [self showDocxFile:self.docxFileToShowPath];
        }
    }
}

-(void)showDocxFile:(NSString*)docxFileToShowPath
{

    
//    [[AppPreferences sharedAppPreferences] showHudWithTitle:@"Opening File" detailText:@"Please wait.."];
//
//    if ([self.view viewWithTag:1000] == nil)
//    {
//        [self.view addSubview:self.webView];
//
//        self.webView.tag = 1000;
//    }
//
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:docxFileToShowPath isDirectory:NO]]];

    if ([self.view viewWithTag:2000] == nil)
    {
        [self.view addSubview:self.textFileContentTextView];
        
        self.textFileContentTextView.tag = 2000;
    }
    
    NSURL* url = [NSURL fileURLWithPath:docxFileToShowPath isDirectory:NO];
    
    self.textFileContentTextView.text = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

}

-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    
    return self;
}

-(void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller
{
    //dispatch_async(dispatch_get_main_queue(), ^{
    
    [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
    
    //});
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
