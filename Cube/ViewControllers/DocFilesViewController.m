//
//  DocFilesViewController.m
//  Cube
//
//  Created by mac on 20/11/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import "DocFilesViewController.h"
#import "Database.h"
#import "APIManager.h"
#import "AppPreferences.h"
#import "Constants.h"
#import "PopUpCustomView.h"

@interface DocFilesViewController ()

@end

@implementation DocFilesViewController
@synthesize overLayView,scrollView,commentTextView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateSendIdsResponse:) name:NOTIFICATION_SEND_DICTATION_IDS_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateFileDownloadResponse:) name:NOTIFICATION_FILE_DOWNLOAD_API
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(validateCommentResponse:) name:NOTIFICATION_SEND_COMMENT_API
                                               object:nil];
    self.navigationItem.title=@"Doc Files";
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    
//    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"More"] style:UIBarButtonItemStylePlain target:self action:@selector(showUserSettings:)];
    
    self.completedFilesResponseArray = [NSMutableArray new];

    self.uploadedFilesArray = [NSMutableArray new];
    
    self.completedFilesForTableViewArray = [NSMutableArray new];
    
    self.downloadingFilesDictationIdsArray = [NSMutableArray new];
    
    self.uploadedFilesArray = [[Database shareddatabase] getUploadedFileList];
    
    NSArray* uploadedFilesDictationIdArray = [[Database shareddatabase] getUploadedFilesDictationIdList];
    
    NSString* uploadedFilesDictationIdString = [uploadedFilesDictationIdArray componentsJoinedByString:@","];
    
    //uploadedFilesDictationIdString = [uploadedFilesDictationIdString stringByAppendingString:@",6987636"];
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        [[AppPreferences sharedAppPreferences] showHudWithTitle:@"Loading Files" detailText:@"Please wait.."];
        
        [[APIManager sharedManager] sendDictationIds:uploadedFilesDictationIdString];
    }
    
    [self.tabBarController.tabBar setHidden:YES];

   // self.navigationController.navigationBar.translucent = NO;

    // Do any additional setup after loading the view.
}

-(void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)validateSendIdsResponse:(NSNotification*)obj
{
    NSString* response = obj.object;
    
    NSArray* completedFilesResponseArray = [response valueForKey:@"CompletedList"];
    
    
//    NSData* completedFilesResponseData = [completedFilesResponseString dataUsingEncoding:NSUTF8StringEncoding];
//
//    NSError* error;
    //    NSError* error;

//
    
//    NSArray* completedFilesResponseArray = [NSJSONSerialization JSONObjectWithData:completedFilesResponseData options:NSJSONReadingAllowFragments error:&error];
    
    [self.completedFilesResponseArray removeAllObjects];

    [self.completedFilesForTableViewArray removeAllObjects];

    for (int i=0; i<completedFilesResponseArray.count; i++)
    {
        NSDictionary* dic = [completedFilesResponseArray objectAtIndex:i];
        
        NSString* dictationId = [dic valueForKey:@"DictationID"];
        
        [self.completedFilesResponseArray addObject:dictationId];
    }
    
    for (int i=0; i<self.uploadedFilesArray.count; i++)
    {
        AudioDetails* audioDetails = [self.uploadedFilesArray objectAtIndex:i];
        
        NSString* dictationId = [NSString stringWithFormat:@"%d", audioDetails.mobiledictationidval];
        
        if ([self.completedFilesResponseArray containsObject:dictationId])
        {
//            [self.completedFilesResponseArray removeObject:audioDetails];
            [self.completedFilesForTableViewArray addObject:audioDetails];
        }
        else
        {
//            [self.completedFilesForTableViewArray addObject:audioDetails];
        }
    }
    
    
    [self.tableView reloadData];

}


-(void)validateFileDownloadResponse:(NSNotification*)obj
{
    NSDictionary* response = obj.object;
    
    //NSString* byteCodeString = [response valueForKey:@"ByteDocForDownload"];
    
//    NSString* dictationId = [response valueForKey:@"DictationId"];
    //NSString* dictationId = @"8103552";

    NSString* dictationID = [response valueForKey:@"DictationID"];

    for (int i = 0; i< self.completedFilesForTableViewArray.count; i++)
    {
        AudioDetails* audioDetails = [self.completedFilesForTableViewArray objectAtIndex:i];
        
        if (audioDetails.mobiledictationidval == [dictationID intValue])
        {
            audioDetails.downloadStatus = DOWNLOADED;
            
            [self.completedFilesForTableViewArray replaceObjectAtIndex:i withObject:audioDetails];
            
            [self.tableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:i inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    [[Database shareddatabase] updateDownloadingStatus:DOWNLOADED dictationId:[dictationID intValue]];
}

-(void)validateCommentResponse:(NSNotification*)notification
{
    NSDictionary* dict = notification.object;
    
    NSString* code = [dict valueForKey:@"code"];
    
    NSString* dictationID = [dict valueForKey:@"DictationID"];

    
    [self removeCommentView];

}
-(void)addMoreView:(TableViewButton*)sender
{
    CGRect rect = sender.frame;
    [self addPopView:sender];
}

-(void)addCommentView:(TableViewButton*)sender
{
    
//    overLayView = [[UIView alloc] initWithFrame:CGRectMake(sender.frame.origin.x, sender.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    
//    [self.navigationController.navigationBar setHidden:true];
    
    overLayView = [[UIView alloc] initWithFrame:self.view.frame];

    overLayView.tag = 222;
    
    overLayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    UITapGestureRecognizer* tapToDismissNotif = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    
    [overLayView addGestureRecognizer:tapToDismissNotif];
    
    tapToDismissNotif.delegate = self;
    
//    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, -100, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73)];
//
//    self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.1, self.view.frame.size.height*0.09, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1, -self.view.frame.size.height, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73)];
    
//    self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.1, self.view.frame.size.height*0.09, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);
    
    scrollView.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    scrollView.backgroundColor = [UIColor whiteColor];
    
    UIView* insideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, 500)];
    
    insideView.backgroundColor = [UIColor whiteColor];
    
    scrollView.layer.cornerRadius = 4.0;
    
    insideView.layer.cornerRadius = 4.0;
    
    UILabel* referenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(insideView.frame.size.width/2 - 60, 10, 120, 35)];
    
    referenceLabel.textAlignment = NSTextAlignmentCenter;
    
    
    
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"Approve"])
    {
        referenceLabel.text = @"Comment & Approve";
    }
    else
    {
        referenceLabel.text = @"Comment & For Approval";
    }
    referenceLabel.textColor = [UIColor appOrangeColor];
    
    UIImageView* referenceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(insideView.frame.size.width/2 - 60, 14, 17, 23)];
    
    referenceImageView.image = [UIImage imageNamed:@"Referral"];
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, referenceLabel.frame.origin.y + referenceLabel.frame.size.height + 10, insideView.frame.size.width, 2)];
    
    lineView.backgroundColor = [UIColor appOrangeColor];
    
    commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(insideView.frame.size.width*0.07, lineView.frame.origin.y + lineView.frame.size.height + 20, insideView.frame.size.width*0.86, 110)];
    
    //UIView* paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    
    //textField.leftView = paddingView;
    
    //textField.leftViewMode = UITextFieldViewModeAlways;
    
    commentTextView.font = [UIFont systemFontOfSize:14.0];
    
    commentTextView.delegate = self;
    
    TableViewButton* submitButton = [[TableViewButton alloc] initWithFrame:CGRectMake(commentTextView.frame.origin.x+commentTextView.frame.size.width*0.05, commentTextView.frame.origin.y + commentTextView.frame.size.height + 20, commentTextView.frame.size.width*0.9, 35)];
    
    submitButton.layer.cornerRadius = 4.0;
    
    submitButton.indexPathRow = sender.indexPathRow;
    
    submitButton.backgroundColor = [UIColor appOrangeColor];
    
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    
    submitButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [submitButton addTarget:self action:@selector(submitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
//    textView.placeholder = @"Comment here";
    
    commentTextView.layer.borderColor = [UIColor colorWithRed:196/255.0 green: 204/255.0 blue: 210/255.0 alpha: 1.0].CGColor;
    
    commentTextView.layer.borderWidth = 1.0;
    
    commentTextView.layer.cornerRadius = 4.0;
    
    [insideView addSubview:referenceLabel];
    [insideView addSubview:referenceImageView];
    [insideView addSubview:lineView];
    [insideView addSubview:commentTextView];
    
    [insideView addSubview:submitButton];
    
    [scrollView addSubview:insideView];
    
    [overLayView addSubview:scrollView];
    
//    [self.view addSubview:overLayView];

    [[UIApplication sharedApplication].keyWindow addSubview:overLayView];

    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0.1 options:UIViewAnimationOptionTransitionCurlDown animations:^{

//            self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.1, self.view.frame.size.height*0.09, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);

        self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.1, self.view.frame.size.height*0.09, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);
        
        } completion:^(BOOL finished) {

        }];
    
//    overLayView.transform = CGAffineTransformMakeScale(0.01, 0.01);
//    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        overLayView.transform = CGAffineTransformIdentity;
//    } completion:^(BOOL finished){
//        // do something once the animation finishes, put it here
//    }];
}


-(void)addDetailsViewindexPathRow:(long)indexPathRow
{
    
    //    overLayView = [[UIView alloc] initWithFrame:CGRectMake(sender.frame.origin.x, sender.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    
//    [self.navigationController.navigationBar setHidden:true];
//
    overLayView = [[UIView alloc] initWithFrame:self.view.frame];

    overLayView.tag = 222;

    overLayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//
    UITapGestureRecognizer* tapToDismissNotif = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(crossButtonTapped:)];

    [overLayView addGestureRecognizer:tapToDismissNotif];
//
    tapToDismissNotif.delegate = self;
    
    //    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, -100, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73)];
    //
    //    self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.1, self.view.frame.size.height*0.09, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);
//    long indexPathRow = sender.indexPathRow;
    
    AudioDetails* audioDetails = [self.completedFilesForTableViewArray objectAtIndex:indexPathRow];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    
     self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.05, -self.view.frame.size.height, self.view.frame.size.width*0.9, self.view.frame.size.height*0.73);
    
    scrollView.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = false;
    

    scrollView.backgroundColor = [UIColor whiteColor];
    
    UIView* insideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, 500)];
    
    insideView.backgroundColor = [UIColor whiteColor];
    
    scrollView.layer.cornerRadius = 4.0;
    
    insideView.layer.cornerRadius = 4.0;
    
    UILabel* referenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(insideView.frame.size.width/2 - 60, 12, 120, 40)];
    
    referenceLabel.textAlignment = NSTextAlignmentCenter;
    
    referenceLabel.text = @"Details";
    
    referenceLabel.font = [UIFont systemFontOfSize:18];
    
    referenceLabel.textColor = [UIColor appOrangeColor];
    
    UIImageView* crossImageView = [[UIImageView alloc] initWithFrame:CGRectMake(insideView.frame.size.width - 40, 20, 20, 20)];
    
    crossImageView.image = [UIImage imageNamed:@"Cross"];
    
    UIButton* crossButton = [[UIButton alloc] initWithFrame:CGRectMake(insideView.frame.size.width - 60, 0, 60, 60)];
    
//    [crossButton setImage:[UIImage imageNamed:@"Referral"] forState:UIControlStateNormal];
    
    [crossButton setBackgroundColor:[UIColor clearColor]];
    
    [crossButton addTarget:self action:@selector(crossButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, referenceLabel.frame.origin.y + referenceLabel.frame.size.height + 10, insideView.frame.size.width, 2)];
    
    //lineView.backgroundColor = [UIColor appOrangeColor];
    float titleLabelXPosition = insideView.frame.size.width*0.05;
    float titleValueLabelXPosition = insideView.frame.size.width*0.49;

    UILabel* audioIdTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelXPosition, referenceLabel.frame.origin.y + referenceLabel.frame.size.height+7 , insideView.frame.size.width*0.4, 30)];
    
    audioIdTitleLabel.textColor = [UIColor colorWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0];
    
    audioIdTitleLabel.font = [UIFont systemFontOfSize:14];
    
    audioIdTitleLabel.text = @"Audio ID";
    
    UILabel* audioIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleValueLabelXPosition, referenceLabel.frame.origin.y + referenceLabel.frame.size.height+7, insideView.frame.size.width*0.5, 30)];

    audioIdLabel.font = [UIFont systemFontOfSize:14];

    audioIdLabel.text = audioDetails.fileName;
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(10, audioIdTitleLabel.frame.origin.y + audioIdTitleLabel.frame.size.height + 5, insideView.frame.size.width-20, 1)];
    separatorLineView.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    
    
    UILabel* dictatedByTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelXPosition, separatorLineView.frame.origin.y + 10 , insideView.frame.size.width*0.5, 30)];
    
    dictatedByTitleLabel.textColor = [UIColor colorWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0];
    
    dictatedByTitleLabel.font = [UIFont systemFontOfSize:14];
    
    dictatedByTitleLabel.text = @"Dictated By";
    
    UILabel* dictatedByLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleValueLabelXPosition, separatorLineView.frame.origin.y + 10, insideView.frame.size.width*0.4, 30)];
    
    dictatedByLabel.font = [UIFont systemFontOfSize:14];
    
    dictatedByLabel.text = @"Test Consultant 1";
    
    UIView* separatorLineView1 = [[UIView alloc] initWithFrame:CGRectMake(10, dictatedByLabel.frame.origin.y + dictatedByLabel.frame.size.height + 5, insideView.frame.size.width-20, 1)];
    separatorLineView1.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    
    
    UILabel* dictatedOnTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelXPosition, separatorLineView1.frame.origin.y + 10 , insideView.frame.size.width*0.4, 30)];
    
    dictatedOnTitleLabel.textColor= [UIColor colorWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0];
    
    dictatedOnTitleLabel.font = [UIFont systemFontOfSize:14];
    
    dictatedOnTitleLabel.text = @"Dictated On";
    
    UILabel* dictatedOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleValueLabelXPosition, separatorLineView1.frame.origin.y + 10, insideView.frame.size.width*0.5, 30)];
    
    dictatedOnLabel.font = [UIFont systemFontOfSize:14];
    
    dictatedOnLabel.text = [NSString stringWithFormat:@"%@",audioDetails.recordingDate];
    
    UIView* separatorLineView2 = [[UIView alloc] initWithFrame:CGRectMake(10, dictatedOnLabel.frame.origin.y + dictatedOnLabel.frame.size.height + 5, insideView.frame.size.width-20, 1)];
    separatorLineView2.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];

    UILabel* uploadedDateTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelXPosition, separatorLineView2.frame.origin.y + 10 , insideView.frame.size.width*0.4, 30)];
    
    uploadedDateTitleLabel.textColor = [UIColor colorWithRed:148/255.0 green:148/255.0 blue:148/255.0 alpha:1.0];
    
    uploadedDateTitleLabel.font = [UIFont systemFontOfSize:14];
    
    uploadedDateTitleLabel.text = @"Transfer Date";
    
    UILabel* uploadedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleValueLabelXPosition, separatorLineView2.frame.origin.y + 10, insideView.frame.size.width*0.5, 30)];
    
    uploadedDateLabel.font = [UIFont systemFontOfSize:14];
    
    uploadedDateLabel.text = audioDetails.transferDate;
    
    UIView* separatorLineView3 = [[UIView alloc] initWithFrame:CGRectMake(10, uploadedDateLabel.frame.origin.y + uploadedDateLabel.frame.size.height + 5, insideView.frame.size.width-20, 1)];
    separatorLineView3.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    //textField.leftView = paddingView;
    
    //textField.leftViewMode = UITextFieldViewModeAlways;
    
    commentTextView.font = [UIFont systemFontOfSize:14.0];
    
    commentTextView.delegate = self;
    
    [insideView addSubview:referenceLabel];
    [insideView addSubview:crossButton];
    [insideView addSubview:crossImageView];

    [insideView addSubview:audioIdTitleLabel];
    [insideView addSubview:audioIdLabel];
    [insideView addSubview:separatorLineView];
    
    [insideView addSubview:dictatedByTitleLabel];
    [insideView addSubview:dictatedByLabel];
    [insideView addSubview:separatorLineView1];
    
    [insideView addSubview:dictatedOnTitleLabel];
    [insideView addSubview:dictatedOnLabel];
    [insideView addSubview:separatorLineView2];
    
    [insideView addSubview:uploadedDateTitleLabel];
    [insideView addSubview:uploadedDateLabel];
    [insideView addSubview:separatorLineView3];
    
    [scrollView addSubview:insideView];
    
    [overLayView addSubview:scrollView];
    
    [[UIApplication sharedApplication].keyWindow addSubview:overLayView];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.1 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        
        //            self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.1, self.view.frame.size.height*0.09, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);
        self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.05, self.view.frame.size.height*0.09, self.view.frame.size.width*0.9, self.view.frame.size.height*0.73);

        //self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
    
    //    overLayView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    //    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    //        overLayView.transform = CGAffineTransformIdentity;
    //    } completion:^(BOOL finished){
    //        // do something once the animation finishes, put it here
    //    }];
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Comment here"])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        textView.text = @"Comment here";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

-(void)submitButtonClicked:(TableViewButton*)sender
{
    if ([commentTextView.text  isEqual: @""])
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Invalid Comment" withMessage:@"Please enter a valid comment" withCancelText:@"Cancel" withOkText:@"Ok" withAlertTag:1000];
    }
    else
    {
        AudioDetails* audioDetails = [self.completedFilesForTableViewArray objectAtIndex:sender.indexPathRow];
        [[APIManager sharedManager] sendComment:commentTextView.text dictationId:[NSString stringWithFormat:@"%d",audioDetails.mobiledictationidval]];
        [commentTextView resignFirstResponder];
    }
    
}

-(void)tapped:(UIGestureRecognizer*)touch
{
    
    [self removeCommentView];
//    overLayView.transform = CGAffineTransformIdentity;
//    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        overLayView.transform = CGAffineTransformMakeScale(0.01, 0.01);
//    } completion:^(BOOL finished){
//         [overLayView removeFromSuperview];
//    }];
}

-(void)crossButtonTapped:(UIButton*)touch
{
//    [self.navigationController.navigationBar setHidden:false];

    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.1 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        
        //            self.scrollView.frame = CGRectMake(-self.view.frame.size.width, -self.view.frame.size.height*0.09, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);

        self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.1, -self.view.frame.size.height, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);
        //[self.scrollView removeFromSuperview];
        overLayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];

        
    } completion:^(BOOL finished) {
        
        [[[UIApplication sharedApplication].keyWindow viewWithTag:222] removeFromSuperview];

//        [[self.view viewWithTag:222] removeFromSuperview];
        
    }];
    
}

-(void)removeCommentView
{
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.1 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        
        //            self.scrollView.frame = CGRectMake(-self.view.frame.size.width, -self.view.frame.size.height*0.09, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);
        
        self.scrollView.frame = CGRectMake(self.view.frame.size.width*0.1, -self.view.frame.size.height, self.view.frame.size.width*0.8, self.view.frame.size.height*0.73);
        
    } completion:^(BOOL finished) {
        
//        [[self.view viewWithTag:222] removeFromSuperview];
        [[[UIApplication sharedApplication].keyWindow viewWithTag:222] removeFromSuperview];

//        [self.navigationController.navigationBar setHidden:false];

    }];
    
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:111];

    UIView* commentOrDetailsView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:222];

    if(touch.view == commentOrDetailsView || touch.view == popUpView)
    {
        return true;
    }
    else
    {
        return false;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return 3;
    return self.completedFilesForTableViewArray.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    AudioDetails* audioDetails = [self.completedFilesForTableViewArray objectAtIndex:indexPath.row];

//    TableViewButton* commentButton = [cell viewWithTag:102];
//    commentButton.indexPathRow = indexPath.row;
//    [commentButton addTarget:self action:@selector(addCommentView:) forControlEvents:UIControlEventTouchUpInside];

//    UIButton* detailsButton = [cell viewWithTag:103];
//    [detailsButton addTarget:self action:@selector(addDetailsView:) forControlEvents:UIControlEventTouchUpInside];

    TableViewButton* downloadButton = [cell viewWithTag:104];
    [downloadButton addTarget:self action:@selector(downloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    downloadButton.indexPathRow = indexPath.row;
    
    TableViewButton* approveButton = [cell viewWithTag:101];
    [approveButton addTarget:self action:@selector(addCommentView:) forControlEvents:UIControlEventTouchUpInside];
    approveButton.indexPathRow = indexPath.row;

    TableViewButton* forApprovalButton = [cell viewWithTag:106];
    [forApprovalButton addTarget:self action:@selector(addCommentView:) forControlEvents:UIControlEventTouchUpInside];
    forApprovalButton.indexPathRow = indexPath.row;
    
    TableViewButton* moreButton = [cell viewWithTag:701];
    [moreButton addTarget:self action:@selector(addMoreView:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.indexPathRow = indexPath.row;
    
    if (audioDetails.downloadStatus == DOWNLOADING)
    {
        [downloadButton setTitle:@"Downloading" forState:UIControlStateNormal];
    }
    else if (audioDetails.downloadStatus == DOWNLOADED)
    {
        [downloadButton setTitle:@"View" forState:UIControlStateNormal];

    }
    else
    {
        [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    }
    
    UILabel* fileNameLabel = [cell viewWithTag:105];

    fileNameLabel.text = audioDetails.fileName;
    
    NSString* destpath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Downloads/%@",audioDetails.fileName]];
    
    NSString* newDestPath = [destpath stringByAppendingPathExtension:@"doc"];
    
    NSError* error;
    NSString* content = [NSString stringWithContentsOfFile:newDestPath encoding:NSMacOSRomanStringEncoding error:&error];
//    UILabel* inCompleteDictationLabel=[cell viewWithTag:101];
//    UILabel* noDictationLabel=[cell viewWithTag:102];
    
    
   
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //MainTabBarViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarViewController"];
   
    
}

-(void)approveButtonClicked:(UIButton*)sender
{
    
}
//-(void)commentButtonClicked:(TableViewButton*)sender
//{
//
//}
//-(void)detailsButtonClicked:(UIButton*)sender
//{
//
//}
-(void)downloadButtonClicked:(TableViewButton*)sender
{
    int indexPathRow = sender.indexPathRow;
    
    AudioDetails* audioDetails = [_completedFilesForTableViewArray objectAtIndex:indexPathRow];
    
    int dictationId = audioDetails.mobiledictationidval;
    
    NSString* fileName = [[Database shareddatabase] getfileNameFromDictationID:[NSString stringWithFormat:@"%d", dictationId]];
   // [[APIManager sharedManager] downloadFileUsingConnection:[NSString stringWithFormat:@"%d",dictationId]];

    if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Download"])
    {
        //[[APIManager sharedManager] downloadFileUsingConnection:@"6753263"];
        [[APIManager sharedManager] downloadFileUsingConnection:[NSString stringWithFormat:@"%d",dictationId]];

        [[Database shareddatabase] updateDownloadingStatus:DOWNLOADING dictationId:audioDetails.mobiledictationidval];
        
        audioDetails.downloadStatus = DOWNLOADING;
        
        [self.completedFilesForTableViewArray replaceObjectAtIndex:indexPathRow withObject:audioDetails];
        
        
        [self.tableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:indexPathRow inSection:0], nil]  withRowAnimation:UITableViewRowAnimationNone];
    }
    else
        if ([[sender titleForState:UIControlStateNormal]  isEqual: @"View"])

    {
        NSString* destpath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Downloads/%@",fileName]];

        NSString* newDestPath = [destpath stringByAppendingPathExtension:@"doc"];
        
        UIDocumentInteractionController* interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:newDestPath]];
        
        interactionController.delegate = self;
        
        [interactionController presentPreviewAnimated:true];
    }
   
}

-(CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
    
}
-(UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
   return self.view;
    
}

-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    
    return self;
}


-(void)showUserSettings:(id)sender
{
//    [self addPopView];
}


-(void)addPopView:(TableViewButton*)sender
{
    self.selectedRow = sender.indexPathRow;
    
   NSIndexPath* indexPath = [NSIndexPath indexPathForRow:sender.indexPathRow inSection:0];
   UITableViewCell* tappedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView* moreImageView = [tappedCell viewWithTag:702];
    NSArray* subViewArray=[NSArray arrayWithObjects:@"Info.",@"Edit Docx",@"Delete Docx", nil];
//    UIView* pop=[[PopUpCustomView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+self.view.frame.size.width-175, self.view.frame.origin.y+20, 160, 126) andSubViews:subViewArray :self];
//    UIView* pop=[[PopUpCustomView alloc]initWithFrame:CGRectMake(tappedCell.frame.size.width-175, tappedCell.frame.size.height + tappedCell.frame.origin.y+10, 160, 126) andSubViews:subViewArray :self];

    double navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    double popUpViewXPosition = moreImageView.frame.origin.x  - moreImageView.frame.size.width - 160;
    double popUpViewYPosition = navigationBarHeight + tappedCell.frame.origin.y + moreImageView.frame.origin.y + 20;

    UIView* pop=[[PopUpCustomView alloc]initWithFrame:CGRectMake(popUpViewXPosition, popUpViewYPosition, 160, 126) andSubViews:subViewArray :self];

    [[[UIApplication sharedApplication] keyWindow] addSubview:pop];

//    [tappedCell addSubview:pop];
    
}

-(void)dismissPopView:(id)sender
{
    
    UIView* popUpView= [[[UIApplication sharedApplication] keyWindow] viewWithTag:111];
    if ([popUpView isKindOfClass:[UIView class]])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    }
    
}
-(void)Info
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    
    [self addDetailsViewindexPathRow:self.selectedRow];
//    [self.navigationController presentViewController:[self.storyboard  instantiateViewControllerWithIdentifier:@"UserSettingsViewController"] animated:YES completion:nil];
}

-(void)EditDocx
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    
    
    [self.navigationController presentViewController:[self.storyboard  instantiateViewControllerWithIdentifier:@"EditDocxViewController"] animated:YES completion:nil];
}

-(void)DeleteDocx
{
    [[[[UIApplication sharedApplication] keyWindow] viewWithTag:111] removeFromSuperview];
    
    
    [self.navigationController presentViewController:[self.storyboard  instantiateViewControllerWithIdentifier:@"UserSettingsViewController"] animated:YES completion:nil];
}

-(void)deleteRecording
{
    alertController = [UIAlertController alertControllerWithTitle:@"Delete?"
                                                          message:DELETE_MESSAGE
                                                   preferredStyle:UIAlertControllerStyleAlert];
    actionDelete = [UIAlertAction actionWithTitle:@"Delete"
                                            style:UIAlertActionStyleDestructive
                                          handler:^(UIAlertAction * action)
                    {
                        
//                        for (int i = 0; i< self.completedFilesForTableViewArray.count; i++)
//                        {
                               AudioDetails* audioDetails = [self.completedFilesForTableViewArray objectAtIndex:self.selectedRow];
                            
                                audioDetails.downloadStatus = DOWNLOADED;
                                
                                [self.completedFilesForTableViewArray replaceObjectAtIndex:self.selectedRow withObject:audioDetails];
                                
                                [self.tableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:self.selectedRow inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
//                        }
                        [[Database shareddatabase] updateDownloadingStatus:DOWNLOADEDANDDELETED dictationId:audioDetails.mobiledictationidval];
//                        APIManager* app=[APIManager sharedManager];
//
//                        Database* db=[Database shareddatabase];
//
//                        NSString* fileName=[audiorecordDict valueForKey:@"RecordItemName"];
//
//                        NSString* dateAndTimeString=[app getDateAndTimeString];
//
//                        [db updateAudioFileStatus:@"RecordingDelete" fileName:fileName dateAndTime:dateAndTimeString];
//
//                        [app deleteFile:[NSString stringWithFormat:@"%@backup",fileName]];
//
//                        BOOL delete= [app deleteFile:fileName];
//
//                        if ([self.selectedView isEqualToString:@"Imported"])
//                        {
//                            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARED_GROUP_IDENTIFIER];
//
//                            // NSString* sharedAudioFolderPathString=[sharedDefaults objectForKey:@"audioFolderPath"];
//
//                            NSMutableArray* sharedAudioNamesArray=[NSMutableArray new];
//
//                            NSArray* copyArray=[NSArray new];
//
//                            copyArray=[sharedDefaults objectForKey:@"audioNamesArray"];
//
//                            sharedAudioNamesArray=[copyArray mutableCopy];
//
//                            NSMutableArray* forDeleteStatusProxyArray = [NSMutableArray new];
//
//                            for (int i=0; i<sharedAudioNamesArray.count; i++)
//                            {
//
//                                NSString* fileNameWithoutExtension=[[sharedAudioNamesArray objectAtIndex:i] stringByDeletingPathExtension];
//
//                                NSString* pathExtension= [[sharedAudioNamesArray objectAtIndex:i] pathExtension];
//
//                                NSString* fileNameWithExtension=[NSString stringWithFormat:@"%@.%@",fileName,pathExtension];
//                                //
//                                if ([sharedAudioNamesArray containsObject:fileNameWithExtension])
//                                {
//                                    [sharedAudioNamesArray removeObject:fileNameWithExtension];
//
//                                    break;
//
//                                }
//
//                            }
//
//                            [sharedDefaults setObject:sharedAudioNamesArray forKey:@"audioNamesArray"];
//
//                            [sharedDefaults synchronize];
//                        }
//                        if (delete)
//                        {
//                            [self dismissViewControllerAnimated:YES completion:nil];
//                        }
//
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
