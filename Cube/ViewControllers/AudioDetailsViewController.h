//
//  AudioDetailsViewController.h
//  Cube
//
//  Created by mac on 28/07/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioSessionManager.h"
#import "PopUpCustomView.h"
@interface AudioDetailsViewController : UIViewController<AVAudioPlayerDelegate,UIGestureRecognizerDelegate>
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
    bool moreButtonPressed;
    UIView * overlay;
    UIBackgroundTaskIdentifier task;
    UITableViewCell *cell;
    NSArray* departmentNamesArray;
    UITapGestureRecognizer* tap;

}
@property(nonatomic)long selectedRow;
@property(nonatomic,strong)NSString* selectedView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (weak, nonatomic) IBOutlet UIButton *transferDictationButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteDictationButton;
- (IBAction)moreButtonClicked:(id)sender;


- (IBAction)editRecordingButtonPressed:(id)sender;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)deleteDictation:(id)sender;
- (IBAction)playRecordingButtonPressed:(id)sender;
- (IBAction)transferDictationButtonClicked:(id)sender;
@end
