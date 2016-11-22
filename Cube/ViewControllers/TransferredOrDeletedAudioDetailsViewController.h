//
//  TransferredOrDeletedAudioDetailsViewController.h
//  Cube
//
//  Created by mac on 29/08/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioSessionManager.h"
#import "PopUpCustomView.h"

@interface TransferredOrDeletedAudioDetailsViewController : UIViewController<AVAudioPlayerDelegate>

{
    NSDictionary* result;
    UIAlertController *alertController;
    UIAlertAction *actionDelete;
    UIAlertAction *actionCancel;
    BOOL deleted;
    NSDictionary* audiorecordDict;
    UISlider* audioRecordSlider;
    UIView* sliderPopUpView;
    UIView* popupView;
    PopUpCustomView* forTableViewObj;
    UITableViewCell *cell;
    NSArray* departmentNamesArray;
    UITapGestureRecognizer* tap;
}
@property(nonatomic)long listSelected;
@property(nonatomic)long selectedRow;
- (IBAction)backButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteDictationButton;
- (IBAction)playRecordingButtonPressed:(id)sender;
- (IBAction)deleteRecordinfButtonPressed:(id)sender;
- (IBAction)resendButtonClckied:(id)sender;
- (IBAction)moreButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@end
