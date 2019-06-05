//
//  ViewController.m
//  DocxReadingDemo
//
//  Created by mac on 23/01/18.
//  Copyright © 2018 Xanadutec. All rights reserved.
//

#import "EditDocxViewController.h"
#import "ZipArchive.h"
#import "SSZipArchive.h"

@interface EditDocxViewController ()



@end

@implementation EditDocxViewController

@synthesize referenceTextView,textViewCount,scrollView,insideView,textAdded,elementChanged,modifiedTextViewTagsArray,XPathForTextViewDict,theDocument,elementIndexDict,bundleFileName,zipDocxFileName,unzipFolderName,textViewContentHeightDict;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    modifiedTextViewTagsArray = [NSMutableArray new];
    
    textViewContentHeightDict = [NSMutableDictionary new];
    referenceTextView.translatesAutoresizingMaskIntoConstraints = true;
    [referenceTextView sizeToFit];
    referenceTextView.scrollEnabled = false;
    textViewCount = 2;

    self.navigationItem.title=@"Custom Docx Editor";
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController:)];
    
    [self.tabBarController.tabBar setHidden:YES];

//    insideView.layer.borderColor = [UIColor darkGrayColor].CGColor;
//    insideView.layer.borderWidth = 2.0;
   
    //    bundleFileName = @"Docx2";
//    unzipFolderName = @"Docx2";
//    zipDocxFileName = @"Docx2Zipped";
    bundleFileName = @"sample";
    unzipFolderName = @"sampleFolder1";
    zipDocxFileName = @"sampleDocx";
//    bundleFileName = @"TemplateDocx1";
//    unzipFolderName = @"TemplateDocx1";
//    zipDocxFileName = @"TemplateDocx1Zipped";
//    bundleFileName = @"TemplateDocx2";
//    unzipFolderName = @"TemplateDocx2";
//    zipDocxFileName = @"TemplateDocx2Zipped";
    // Do any additional setup after loading the view, typically from a nib.
    
    self.saveDocxButton.layer.cornerRadius = 4.0;
    
    self.saveDocxButton.layer.borderWidth = 1.0;
//    3,122,255
    self.saveDocxButton.layer.borderColor = [UIColor colorWithRed:3/255.0 green:122/255.0 blue:1 alpha:1.0].CGColor;
    
    self.viewDocxButton.layer.cornerRadius = 4.0;
    
    self.viewDocxButton.layer.borderWidth = 1.0;
    
    self.viewDocxButton.layer.borderColor = [UIColor colorWithRed:3/255.0 green:122/255.0 blue:1 alpha:1.0].CGColor;
    
    [self copyBundleDocxFileToDirectory];
    
    [self unZipToMakeXML];
    
    [self parseXMLFiles:nil];
}

- (IBAction)backButtonClicked:(id)sender
{
    [self popViewController:sender];
}
-(void)popViewController:(id)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{

        if ([elementName isEqualToString:@"w:p"])
        {
//            if (!(textViewCount == 1))
//            {
//                UITextView* referenceTextView = [insideView viewWithTag:textViewCount];
//                UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(referenceTextView.frame.origin.x, referenceTextView.frame.origin.y+referenceTextView.frame.size.height, self.view.frame.size.width, referenceTextView.frame.size.height)];


//                NSLayoutConstraint *leading =[NSLayoutConstraint
//                                               constraintWithItem:textView
//                                               attribute:NSLayoutAttributeLeading
//                                               relatedBy:NSLayoutRelationEqual
//                                               toItem:insideView
//                                               attribute:NSLayoutAttributeLeading
//                                               multiplier:1.0f
//                                               constant:0.f];
//
//                NSLayoutConstraint *yPosition =[NSLayoutConstraint
//                                              constraintWithItem:textView
//                                              attribute:NSLayoutAttributeTopMargin
//                                              relatedBy:NSLayoutRelationEqual
//                                              toItem:insideView
//                                              attribute:NSLayoutAttributeBaseline
//                                              multiplier:1.0f
//                                              constant:50.f];
//
//                NSLayoutConstraint *height = [NSLayoutConstraint
//                                              constraintWithItem:textView
//                                              attribute:NSLayoutAttributeHeight
//                                              relatedBy:NSLayoutRelationEqual
//                                              toItem:nil
//                                              attribute:NSLayoutAttributeNotAnAttribute
//                                              multiplier:0
//                                              constant:30];
//
//                [textView addConstraint:leading];
//
//                [textView addConstraint:yPosition];
//
//                [textView addConstraint:height];

//                UITextView* textView = [[UITextView alloc] init];
//
//                textViewCount++;
//
//                textView.tag = textViewCount;
//
//                [insideView addSubview:textView];
//            }
//            else
//            {
//              textViewCount++;
//            }


//            if (attributeDict.count == 1 && textViewCount != 2)
//            {
//
//            }
//            else
//            {
               elementChanged = true;
            
                UITextView* referenceTextView = [insideView viewWithTag:textViewCount];
                
                UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(referenceTextView.frame.origin.x, referenceTextView.frame.origin.y+referenceTextView.frame.size.height, self.view.frame.size.width, 30)];
                
                //    UITextView* textView = [[UITextView alloc] init];
                textViewCount++;
                
                textView.tag = textViewCount;
                
                [insideView addSubview:textView];
                
            //}
           
            NSLog(@"textview count = %d",textViewCount);

        }
}
          
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
          //NSLog(@"Did end element");
//          if ([elementName isEqualToString:@"root"])
//              {
    if ([elementName isEqualToString:@"w:p"])
    {
                  NSLog(@"rootelement end");
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    


    
      UITextView* textView = [insideView viewWithTag:textViewCount];
    
      if (elementChanged == false)
      {
          parsedString = [parsedString stringByAppendingString:string];
          
          textView.text = parsedString;
          
          
      }
      else
      {
          parsedString = @"";
          
         textView.text = string;
          
          parsedString = string;
          
//          textView.translatesAutoresizingMaskIntoConstraints = true;
//
//          [textView sizeToFit];
//
//          textView.scrollEnabled = false;

      }
    
    CGRect frame = textView.frame;
    frame.size.height = textView.contentSize.height;
    textView.frame = frame;
//
    textView.scrollEnabled = YES;
    textView.contentSize = [textView sizeThatFits:textView.frame.size];
    textView.delegate = self;

//
//     textView.translatesAutoresizingMaskIntoConstraints = true;
//
//     [textView sizeToFit];
//     textView.scrollEnabled = false;

    
    elementChanged = false;
              
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    CGRect contentRect = CGRectZero;
    
    for (UIView *view in self.insideView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    
    self.scrollView.contentSize = contentRect.size;
}
-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    NSLog(@"%@",validationError.localizedDescription);
    
}





- (IBAction)unZipDoc:(id)sender
{
//    ZipArchive* zip = [ZipArchive new];
//
//
//
//
//    NSString* unzipPath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Kuldeep"]];
  
        
//
//        BOOL unzip = [zip UnzipOpenFile:[[NSBundle mainBundle] pathForResource:@"shaila" ofType:@"docx"]]; // first unzip the file
//
//
//        NSString* unZippedFilePath = [[NSString stringWithFormat:@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) lastObject]] stringByAppendingPathComponent:@"shaila"];
//
//        BOOL isWritten = [zip UnzipFileTo:unZippedFilePath overWrite:true];
//
//        [zip UnzipCloseFile];
//
//    }
   // [self unZipToMakeDocx];
    
}

-(void)copyBundleDocxFileToDirectory
{
    NSString* sourcePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",bundleFileName] ofType:@"docx"];

    NSString* destDocxPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.docx",zipDocxFileName]];

    [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destDocxPath error:nil];
    NSLog(@"");
}

-(BOOL)unZipToMakeXML
{
    NSString* unzipPath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",unzipFolderName]];
    
    //
    //
//    NSError* err;
//    if([[NSFileManager defaultManager] fileExistsAtPath:unzipPath])
//    {
//        [[NSFileManager defaultManager] removeItemAtPath:unzipPath error:&err];
//    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:unzipPath])
    {
        NSError* error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:unzipPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:unzipPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
        NSString* zipPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",bundleFileName] ofType:@"docx"];
        
       BOOL docxCreated =  [SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath];
        
        return docxCreated;
    }
    
    
    return true;
}

//-(void)parseFile:(NSString*)unZipFileName
//{
//    NSString* filePath = [[NSString stringWithFormat:@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) lastObject]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/word/document.xml",unZipFileName]];
//
//    NSURL *url = [[NSURL alloc]initWithString:filePath];
//    parser = [[NSXMLParser alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath:filePath]];
//
//    [parser setDelegate:self];
//    BOOL result = [parser parse];
//}
- (IBAction)zipDoc:(id)sender
{



}

-(BOOL)unZipToMakeDocx
{
     BOOL created =  [SSZipArchive createZipFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.docx",zipDocxFileName]] withContentsOfDirectory:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",unzipFolderName]]];
    
    return created;
}

- (IBAction)parseXMLFiles:(id)sender
{
    //[self parseFile:@"Kuldeep"];
    //[self viewXMLFile:@"document"];
    scrollView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    scrollView.layer.borderWidth = 2.0;
    [self startParsingUsingKissXML];
    [sender setUserInteractionEnabled:false];
}

- (IBAction)viewNewlyCreatedDocx:(id)sender
{
    [self viewDocxFile:zipDocxFileName];
}

-(void)viewDocxFile:(NSString*)fileName
{
    NSString* destpath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",fileName]];
    
    NSString* newDestPath = [destpath stringByAppendingPathExtension:@"docx"];
    
    UIDocumentInteractionController* interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:newDestPath]];
    
    interactionController.delegate = self;
    
    [interactionController presentPreviewAnimated:true];
    
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



// KissXML

-(void)startParsingUsingKissXML
{
    NSError *error;
    
//    NSString* filePath = [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Kuldeep/word/document"]] stringByAppendingPathExtension:@"xml"];
    NSString* filePath = [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/TemplateDocx1/word/document"]] stringByAppendingPathExtension:@"xml"];

    NSString* content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    [self parseXML:content];
    
}


-(void)parseXML:(NSString*)source
{
    
    textViewCount = 2;
    
    long totalTextHeight = 250;

    NSString* filePath = [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/word/document",unzipFolderName]] stringByAppendingPathExtension:@"xml"];

//    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"document" ofType:@"xml"];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];

    theDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    
    
    //NSArray *results = [theDocument nodesForXPath:@"/bookstore/book[price>35]" error:&error];
    //NSArray *results = [theDocument nodesForXPath:@"w:p" error:&error];
    XPathForTextViewDict = [NSMutableDictionary new];
    
    elementIndexDict = [NSMutableDictionary new];

    DDXMLElement* ele = [theDocument rootElement] ;
    
    NSArray* arr = [ele elementsForName:@"w:body"];
    
    DDXMLElement* bodyElement = [arr objectAtIndex:0];
    
    NSArray* paragraphArray = [bodyElement elementsForName:@"w:p"];
    
    for (DDXMLElement *paragraph in paragraphArray)
    {
        NSLog(@"para text = %@", paragraph);

        //DDXMLNode* node = [paragraph nextNode];
        UITextView* referenceTextView = [insideView viewWithTag:textViewCount];

        
        UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(referenceTextView.frame.origin.x, referenceTextView.frame.size.height + referenceTextView.frame.origin.y, self.view.frame.size.width-10, 45)];
        
        textView.returnKeyType = UIReturnKeyDone;
        
        textViewCount++;
        
        textView.tag = textViewCount;
        
        textView.delegate = self;
        
        [XPathForTextViewDict setObject:[paragraph XPath] forKey:[NSString stringWithFormat:@"%ld",(long)textView.tag]];

        [elementIndexDict setObject:[NSString stringWithFormat:@"%ld",paragraph.index] forKey:[NSString stringWithFormat:@"%ld",(long)textView.tag]];
        
        //CGSize size = CGSizeMake(insideView.frame.size.width, insideView.frame.size.height);
        
        // paragraph has two childs w:pPr, w:r
        
//        NSArray* paragraphAttributeArray = [paragraph elementsForName:@"w:pPr"];
//
//        [xmlAttributeDict setObject:[paragraphAttributeArray objectAtIndex:0] forKey:[NSString stringWithFormat:@"%ld", textView.tag]];
        
        NSMutableArray *runningArray = [paragraph elementsForName:@"w:r"];
        
//        BOOL textAdded = false;
        for (int i =0;i<runningArray.count;i++)
        {
            DDXMLElement *runningElement = [runningArray objectAtIndex:i];
            
//            NSArray* runningElementChildrenArray = [runningElement children];
//            
//            for (int j =0;i<runningElementChildrenArray.count;j++)
//            {
//                NSString* childName = [runningElement childAtIndex:j].name;
//
//                NSArray *textArray = [runningElement elementsForName:childName];
//
//            }
            NSArray *textArray = [runningElement elementsForName:@"w:t"];
            
           // DDXMLNode *textArray1 = [runningElement attributeForName:@"w:t"];

            if (textArray.count>0)
            {
                
                DDXMLElement* ele = [textArray objectAtIndex:0];
                
                DDXMLNode* str = [ele childAtIndex:0];
                
                textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"%@",str]];
                
                //textView.text = [textView.text stringByAddingPercentEncodingWithAllowedCharacters:(set)];
                NSString* updatedString = [textView.text stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                
                updatedString = [updatedString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                
                updatedString = [updatedString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];

                textView.text = updatedString;
                
//                NSLog(@"TextView text = %d", textView.text);
//
//                NSLog(@"level = %ld",str.level);
//
//                NSLog(@"index = %ld",str.index);

                CGRect frame = textView.frame;
                
                frame.size.height = textView.contentSize.height;
                
                textView.frame = frame;
                
                [textViewContentHeightDict setObject: [NSString stringWithFormat:@"%f",textView.contentSize.height] forKey:[NSString stringWithFormat:@"%ld",textView.tag]];
                
               
//                NSLog(@"element :%@",str);
//                
//                NSLog(@"textViewCount :%d",textViewCount);
                
               
            }

            
           
            
        }
//        for (int i = 1; i<runningArray.count; i++)
//        {
//            [runningArray removeObjectAtIndex:1];
//        }
        totalTextHeight = totalTextHeight + textView.frame.size.height;

        [insideView addSubview:textView];

        
        //
        //        for (int i = 0; i < [paragraph childCount]; i++)
        //        {
        //            DDXMLNode *node = [paragraph childAtIndex:i];
        //
        //            NSString *name = [node name];
        //
        //            NSString *value = [node stringValue];
        //
        //            NSLog(@"%@:%@",name,value);
        //
        //        }
        
    }
    
    if (insideView.frame.size.height < totalTextHeight)
    {
        CGRect frame = insideView.frame;

        frame.size.height = totalTextHeight;

        insideView.frame = frame;

        CGSize size = CGSizeMake(insideView.frame.size.width, insideView.frame.size.height);
        
        self.scrollView.contentSize = size;
        
        NSLayoutConstraint *height = [NSLayoutConstraint
                                                      constraintWithItem:insideView
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                      toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:0
                                                      constant:size.height];
        
        [insideView addConstraint:height];
    }
   
    
    
}



- (IBAction)saveEditedFile:(id)sender
{
    [self.view endEditing:YES];
    NSError *error;
    
    NSString* filePath = [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/word/document",unzipFolderName]] stringByAppendingPathExtension:@"xml"];
    
    NSString* content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    BOOL saved = [self saveEditedFileResource:content];
    
    if (saved == true)
    {
        BOOL docxCreated = [self unZipToMakeDocx];
        
        if (docxCreated == true)
        {
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"File Saved Successfully!" withMessage:@"File saved successfully, click View Docx button to view the file." withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
        }
        else
        {
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Save Failed!" withMessage:@"Something went wrong, unable to save the File" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];

        }

    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Save Failed!" withMessage:@"Something went wrong, unable to save the File" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
    }
   
}

-(BOOL)saveEditedFileResource:(NSString*)source
{
//    NSError *error = nil;
//
//    textViewCountForEdit = 2;
//
//    DDXMLDocument *theDocument = [[DDXMLDocument alloc] initWithXMLString:source options:0 error:&error];
//
//    DDXMLElement* ele = [theDocument rootElement] ;
//
//    NSArray* arr = [ele elementsForName:@"w:body"];
//
//    DDXMLElement* bodyElement = [arr objectAtIndex:0];
//
//    DDXMLElement* bodyElement1 = [bodyElement valueForKeyPath:@"w:p"];
//
//
//    NSArray* paragraphArray = [bodyElement elementsForName:@"w:p"];
//
////    for (DDXMLElement *paragraph in paragraphArray)
//        for (int j =0;j<paragraphArray.count;j++)
//
//    {
//
//        UITextView* referenceTextView = [insideView viewWithTag:textViewCountForEdit];
//
////        UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(referenceTextView.frame.origin.x, referenceTextView.frame.size.height + referenceTextView.frame.origin.y, self.view.frame.size.width, 45)];
//
//        textViewCountForEdit++;
//
//       // textView.tag = textViewCountForEdit;
//
//       // textView.delegate = self;
//        DDXMLElement *paragraph = [paragraphArray objectAtIndex:j];
//        NSArray *runningArray = [paragraph elementsForName:@"w:r"];
//
////        for (DDXMLElement *runningElement in runningArray)
//        NSString* wholeString;
//        for (int i =0;i<runningArray.count;i++)
//
//        {
//            DDXMLElement *runningElement = [runningArray objectAtIndex:i];
//            NSArray *textArray = [runningElement elementsForName:@"w:t"];
//
//
//            if (textArray.count>0)
//            {
//                //DDXMLElement* ele = [textArray objectAtIndex:0];
//
//                //wholeString = [wholeString stringByAppendingString:[NSString stringWithFormat:@"%@",[ele childAtIndex:0]]];
//                //DDXMLNode* str = [ele childAtIndex:0];
//
//                if([modifiedTextViewTagsArray containsObject:[NSString stringWithFormat:@"%d",textViewCountForEdit]] && i==runningArray.count-1)
//                {
//                    //[ele removeChildAtIndex:0];
//
//
//
//                    UITextView* textView = [insideView viewWithTag:textViewCountForEdit];
//
//                    DDXMLNode* str = [DDXMLNode textWithStringValue:textView.text];
//
//
////                    for (int i =0;i<runningArray.count;i++)
////                    {
//                    [bodyElement removeChildAtIndex:j];
//
//                   // [bodyElement addChild:str];
//
//                    [bodyElement insertChild:str atIndex:j];
//                    //}
//                    NSLog(@"TextView tag = %d", textView.tag);
//                }
////                textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"%@",str]];
////
////                CGRect frame = textView.frame;
////                frame.size.height = textView.contentSize.height;
////                textView.frame = frame;
//
//
//                //NSLog(@"element :%@",str);
//                NSLog(@"textViewCount :%d",textViewCountForEdit);
//
//            }
//
//        }
//       // [insideView addSubview:textView];
//
//    }
     NSData* data = [theDocument XMLData];
    // NSString* editedFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/editedXML5"]] stringByAppendingPathExtension:@"xml"];
    
    NSError* err;
    NSString* editedFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/word/document",unzipFolderName]] stringByAppendingPathExtension:@"xml"];

    if([[NSFileManager defaultManager] fileExistsAtPath:editedFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:editedFilePath error:&err];
    }
    NSLog(@"doc = %@", theDocument.XMLString);

    BOOL written = [data writeToFile:editedFilePath atomically:true];
    
    return written;

}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"");
    return true;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(![modifiedTextViewTagsArray containsObject:[NSString stringWithFormat:@"%ld",(long)textView.tag]])
    {
        [modifiedTextViewTagsArray addObject:[NSString stringWithFormat:@"%ld",(long)textView.tag]];
    }
    
    int textViewIndex = [[elementIndexDict objectForKey:[NSString stringWithFormat:@"%ld",(long)textView.tag]] intValue];
    
    NSString* path = [XPathForTextViewDict objectForKey:[NSString stringWithFormat:@"%ld",(long)textView.tag]];
    
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"/w:"];
    
    path = [path stringByReplacingOccurrencesOfString:@"/w:text[1]" withString:@""];
    
    DDXMLElement* bodyElement = [[theDocument rootElement] childAtIndex: 0];
    
    // proprty settings code
    // get old paraelement and its property
    DDXMLElement* oldParaElement = [bodyElement childAtIndex:textViewIndex]; // get the old paragraph to get running ele. prop
    
    NSArray* paraPropertyArray = [oldParaElement elementsForName:@"w:pPr"];

    // get oldRunningElementArray from paraElement
    NSArray* oldRunningElementArray = [oldParaElement elementsForName:@"w:r"];  // get running ele. from old para
    
    DDXMLElement* runningPropElement;
    
    // get oldrunning property from oldRunningElementArray
    for (DDXMLElement* runningElement in oldRunningElementArray)
    {
        NSArray* runningPropArray = [runningElement elementsForName:@"w:rPr"];  // get running prop ele.
        
        for (DDXMLElement* _runningPropElement in runningPropArray)
        {
            runningPropElement = [_runningPropElement copy];
        }
    }
  
    DDXMLElement* runningElement = [DDXMLElement elementWithName:@"w:r" stringValue:@""];

    DDXMLElement* textElement = [DDXMLElement elementWithName:@"w:t" stringValue:textView.text];

    DDXMLElement* paraElement = [DDXMLElement elementWithName:@"w:p" stringValue:@""];

    //if textView is empty
    if (oldRunningElementArray.count == 0)
    {
        runningPropElement = [DDXMLElement elementWithName:@"w:rPr" stringValue:@""];
        
        [runningElement addChild:runningPropElement];
    }
    else
    {
        [runningElement addChild:[runningPropElement copy]];
    }
    
    for (DDXMLElement* ele in paraPropertyArray)
    {
        [paraElement addChild:[ele copy]];

    }
        
    [runningElement addChild:textElement];
        
    [paraElement addChild:runningElement];
        
    [bodyElement insertChild:paraElement atIndex:textViewIndex];

    [bodyElement removeChildAtIndex:textViewIndex+1];
    
    
    

    CGFloat fixedWidth = textView.frame.size.width;

    CGRect newFrame = textView.frame;

    newFrame.size = CGSizeMake(fixedWidth,textView.contentSize.height);

    textView.frame = newFrame;
    

    // set the remaining text field which are below the current textfield
    double preContentHeight = [[textViewContentHeightDict objectForKey:[NSString stringWithFormat:@"%ld",textView.tag]] doubleValue];

    double currentContentHeight = textView.contentSize.height;
    
    double changedContentHeight = currentContentHeight  - preContentHeight;

    for (long i = textView.tag+1; i<textViewCount; i++)
    {
        if (changedContentHeight != 0)
        {
//            double preContentHeight = [[textViewContentHeightDict objectForKey:[NSString stringWithFormat:@"%ld",textView.tag]] doubleValue];
//
//            double currentContentHeight = textView.contentSize.height;
//
//            double changedContentHeight = currentContentHeight  + preContentHeight;
            
            UITextView* nextTextView = [insideView viewWithTag:i];

            CGRect nextFrame = nextTextView.frame;
            
            nextTextView.frame = CGRectMake(nextTextView.frame.origin.x, nextTextView.frame.origin.y+changedContentHeight, nextFrame.size.width, nextFrame.size.height);
            
            
            NSArray* constraints = [nextTextView constraints];
            
            for (NSLayoutConstraint* constraint in constraints)
            {
                [nextTextView removeConstraint:constraint];
            }
            
//            [textViewContentHeightDict setObject:[NSString stringWithFormat:@"%f",currentContentHeight] forKey:[NSString stringWithFormat:@"%ld",i]
//             ];
            
        }
       
    }
    
    [textViewContentHeightDict setObject:[NSString stringWithFormat:@"%f",currentContentHeight] forKey:[NSString stringWithFormat:@"%ld",textView.tag]
     ];



}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"])
    {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
