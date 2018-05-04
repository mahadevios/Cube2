//
//  ViewController.h
//  DocxReadingDemo
//
//  Created by mac on 23/01/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DDXML.h"


#import "AppPreferences.h"

@interface EditDocxViewController : UIViewController<NSXMLParserDelegate,UIDocumentInteractionControllerDelegate,UITextViewDelegate>
{
    NSXMLParser * parser;
    NSString* parsedString;
}
@property (weak, nonatomic) IBOutlet UITextView *referenceTextView;
@property(nonatomic) int textViewCount;

@property(nonatomic) BOOL textAdded;
@property(nonatomic) BOOL elementChanged;
@property(nonatomic,strong) NSMutableArray* modifiedTextViewTagsArray;
@property(nonatomic,strong) NSMutableDictionary* XPathForTextViewDict;
@property(nonatomic,strong) NSMutableDictionary* elementIndexDict;
@property(nonatomic,strong) NSMutableDictionary* textViewContentHeightDict;

@property(nonatomic,strong) NSString* bundleFileName;
@property(nonatomic,strong) NSString* unzipFolderName;
@property(nonatomic,strong) NSString* zipDocxFileName;

@property(nonatomic,strong) DDXMLDocument *theDocument;
- (IBAction)saveEditedFile:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *saveDocxButton;
@property (weak, nonatomic) IBOutlet UIButton *viewDocxButton;

- (IBAction)unZipDoc:(id)sender;
- (IBAction)zipDoc:(id)sender;
- (IBAction)parseXMLFiles:(id)sender;
- (IBAction)viewNewlyCreatedDocx:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *insideView;
- (IBAction)backButtonClicked:(id)sender;

@end

