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

@synthesize referenceTextView,textViewCount,scrollView,insideView,textAdded,elementChanged,modifiedTextViewTagsArray,XPathForTextViewDict,theDocument, relsDocument,elementIndexDict,bundleFileName,zipDocxFileName,unzipFolderName,textViewContentHeightDict;
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

   
//    bundleFileName = @"Patient Letter Template";
//    unzipFolderName = @"sample3Folder";
//    zipDocxFileName = @"Patient Letter Template";

    bundleFileName = @"Operative Note Different Template";
    unzipFolderName = @"sample3Folder";
    zipDocxFileName = @"Operative Note Different Template";

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
    
   
}


-(void)viewDidAppear:(BOOL)animated
{
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

               elementChanged = true;
            
                UITextView* referenceTextView = [insideView viewWithTag:textViewCount];
                
                UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(referenceTextView.frame.origin.x, referenceTextView.frame.origin.y+referenceTextView.frame.size.height, self.view.frame.size.width, 30)];
                
                //    UITextView* textView = [[UITextView alloc] init];
                textViewCount++;
                
                textView.tag = textViewCount;
                
                [insideView addSubview:textView];

           
           

        }
}
          
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
          //NSLog(@"Did end element");
//          if ([elementName isEqualToString:@"root"])
//              {
    if ([elementName isEqualToString:@"w:p"])
    {
                
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
    NSError* err;
    if([[NSFileManager defaultManager] fileExistsAtPath:unzipPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:unzipPath error:&err];
    }
    
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
    [self parseXML];
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


-(void)parseXML
{
    
    textViewCount = 2;
    
    long totalTextHeight = 250;
    
    bool isGroupElement = false;
    
    float groupElementHeight = 0.0;
    
    NSString* filePath = [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/word/document",unzipFolderName]] stringByAppendingPathExtension:@"xml"];
    
    //    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"document" ofType:@"xml"];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    
    theDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    
    
    //NSArray *results = [theDocument nodesForXPath:@"/bookstore/book[price>35]" error:&error];
    //NSArray *results = [theDocument nodesForXPath:@"w:p" error:&error];
    XPathForTextViewDict = [NSMutableDictionary new];
    
    elementIndexDict = [NSMutableDictionary new];
    
    DDXMLElement* rootElement = [theDocument rootElement] ;
    
    [rootElement nextNode];
    [rootElement nextSibling];
    
    NSArray* bodyElementArray = [rootElement elementsForName:@"w:body"];
    
    DDXMLElement* bodyElement = [bodyElementArray objectAtIndex:0];
    
    // get page width, height and margins
    NSArray* docPropArray = [bodyElement elementsForName:@"w:sectPr"];
    
    DDXMLElement* docPropElement = [docPropArray objectAtIndex:0];
    
    NSArray* pgSzArray = [docPropElement elementsForName:@"w:pgSz"];
    
    DDXMLElement* pgSzElement = [pgSzArray objectAtIndex:0];
    
    NSArray* pgMarArray = [docPropElement elementsForName:@"w:pgMar"];
    
    DDXMLElement* pgMarElement = [pgMarArray objectAtIndex:0];
    float width = self.view.frame.size.width;
    NSString* docWidthTwip = [[pgSzElement attributeForName:@"w:w"] stringValue];
    NSString* docHeightTwip = [[pgSzElement attributeForName:@"w:h"] stringValue];
    
    float iOSValueOfOneTwip = width/[docWidthTwip intValue];
    float iOSExpectedDocHeight = iOSValueOfOneTwip * [docHeightTwip intValue];
    
    NSString* pageTopMarginTwip = [[pgMarElement attributeForName:@"w:top"] stringValue];
    NSString* pageRightMarginTwip = [[pgMarElement attributeForName:@"w:right"] stringValue];
    NSString* pageLeftMarginTwip = [[pgMarElement attributeForName:@"w:left"] stringValue];
    //    NSString* bottomMarginTwip = [[pgMarElement attributeForName:@"w:bottom"] stringValue];

    //<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="708" w:footer="708" w:gutter="0"/>
//    float docWidth = [docWidthTwip intValue] * iOSValueOfOneTwip;
//    float docHeight = [docHeightTwip intValue] * iOSValueOfOneTwip;
    float pageTopMarginIOS = [pageTopMarginTwip intValue] * iOSValueOfOneTwip;
    float pageRightMarginIOS = [pageRightMarginTwip intValue] * iOSValueOfOneTwip;
    float pageLeftMarginIOS = [pageLeftMarginTwip intValue] * iOSValueOfOneTwip;
    //    float docBottomMargin = [bottomMarginTwip intValue] * iOSValueOfOneTwip;

    NSArray* paragraphArray = [bodyElement elementsForName:@"w:p"];
    
    for (DDXMLElement *paragraph in paragraphArray)
    {
        NSMutableArray *runningArray = [paragraph elementsForName:@"w:r"];
        
        if (runningArray.count > 0) {
            
          
            
            //DDXMLNode* node = [paragraph nextNode];
//            UIView* referenceTextView;
            
            UIView* referenceTextView = [insideView viewWithTag:textViewCount];
            
//            if ([referenceView isKindOfClass:[UITextView class]]) {
//                referenceTextView = referenceView;
//            }
            
            UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(pageLeftMarginIOS, referenceTextView.frame.size.height + referenceTextView.frame.origin.y, self.view.frame.size.width-pageRightMarginIOS-pageLeftMarginIOS, 45)];
            
            [textView setBackgroundColor:[UIColor clearColor]];
            
            textView.returnKeyType = UIReturnKeyDone;
            
            textViewCount++;
            
            textView.tag = textViewCount;
            
            textView.delegate = self;
            
            [XPathForTextViewDict setObject:[paragraph XPath] forKey:[NSString stringWithFormat:@"%ld",(long)textView.tag]];
            
            [elementIndexDict setObject:[NSString stringWithFormat:@"%ld",paragraph.index] forKey:[NSString stringWithFormat:@"%ld",(long)textView.tag]];
            
            
            for (int i =0;i<runningArray.count;i++)
            {
                DDXMLElement *runningElement = [runningArray objectAtIndex:i];
                
                NSArray* pictArray;
                NSArray *textArray = [runningElement elementsForName:@"w:t"];
                
                if (textArray.count>0)
                {
                    isGroupElement = false;
                    
                    DDXMLElement* ele = [textArray objectAtIndex:0];
                    
                    DDXMLNode* str = [ele childAtIndex:0];
                    
                    textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"%@",str]];
                    
                    NSString* updatedString = [textView.text stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                    
                    updatedString = [updatedString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                    
                    updatedString = [updatedString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                    
                    textView.text = updatedString;
                    
                    CGRect frame = textView.frame;
                    
                    frame.size.height = textView.contentSize.height;
                    
                    textView.frame = frame;
                    
                    [textViewContentHeightDict setObject: [NSString stringWithFormat:@"%f",textView.contentSize.height] forKey:[NSString stringWithFormat:@"%ld",textView.tag]];
                    
                }
                else if((pictArray = [runningElement elementsForName:@"w:pict"]).count > 0){
                    
                    isGroupElement = true;
                    
                    DDXMLElement* pictureElement = [pictArray objectAtIndex:0];
                    
                    NSArray* groupArray = [pictureElement elementsForName:@"v:group"];
                    
                    DDXMLElement* groupElement = [groupArray objectAtIndex:0];
                    
                    //DDXMLElement* ee = [[groupElement parent] parent];
                    DDXMLNode* styleNode = [groupElement attributeForName:@"style"];
                    
                    DDXMLNode* groupCoordOriginNode = [groupElement attributeForName:@"coordorigin"];
                    
                    DDXMLNode* groupCoordSizeNode = [groupElement attributeForName:@"coordsize"];
                    
                    NSString* groupCoordOriginString = [groupCoordOriginNode stringValue];
                    
                    NSString* groupCoordSizeString = [groupCoordSizeNode stringValue];
                    
                    NSArray* groupCoordOriginArray = [groupCoordOriginString componentsSeparatedByString:@","];
                    
                    NSArray* groupCoordSizeArray = [groupCoordSizeString componentsSeparatedByString:@","];
                    
                    float groupCoordOriginX = 0.0, groupCoordOriginY = 0.0, groupCoordWidth = 0.0, groupCoordHeight = 0.0;
                    if (groupCoordOriginArray.count == 2) {
                        groupCoordOriginX = [[groupCoordOriginArray objectAtIndex:0] floatValue];
                        groupCoordOriginY = [[groupCoordOriginArray objectAtIndex:1] floatValue];
                        
                    }
                    if (groupCoordSizeArray.count == 2) {
                        groupCoordWidth = [[groupCoordSizeArray objectAtIndex:0] floatValue];
                        groupCoordHeight = [[groupCoordSizeArray objectAtIndex:1] floatValue];
                    }
                    NSString* styleString = [styleNode stringValue];
                    
                    NSArray* styleAttribute = [styleString componentsSeparatedByString:@";"];
                    
                    NSMutableDictionary* styleDict = [NSMutableDictionary new];
                    for (NSString* att in styleAttribute) {
                        NSArray* styleKey = [att componentsSeparatedByString:@":"];
                        [styleDict setObject:[styleKey objectAtIndex:1] forKey:[styleKey objectAtIndex:0]];
                    }
                    NSString* groupHeightPtString = [styleDict valueForKey:@"height"];
                    NSString* groupWidthPtString = [styleDict valueForKey:@"width"];
                    NSString* groupLeftMarginPtString = [styleDict valueForKey:@"margin-left"];
                    NSString* groupTopMarginPtString = [styleDict valueForKey:@"margin-top"];
                    NSString* pos = [styleDict valueForKey:@"position"];
                    
                    float groupLeftMarginWRTiOS = 0.0, groupTopMarginWRTiOS = 0.0, groupWidthWRTiOS = 0.0, groupHeightWRTiOS = 0.0;
                    float groupHeightIOS, groupWidthIOS, groupLeftMarginIOS = 0.0, groupTopMarginIOS = 0.0;
                    
                    float groupLeftMarginCalculatedPt = 0.0;
                    float groupAndPageLeftMarginPt = 0.0;
                    
                    if ([groupHeightPtString containsString:@"pt"]) {
                        if ([groupHeightPtString length] > 0) {
                            groupHeightPtString = [groupHeightPtString substringToIndex:[groupHeightPtString length] - 2]; // remove "pt" suffix to get float value
                            groupHeightIOS = [groupHeightPtString floatValue] * 20 * iOSValueOfOneTwip; // ht is in points so one point  = 20 twip
                            groupHeightWRTiOS = groupHeightIOS;
                        }
                    }
                    if ([groupWidthPtString containsString:@"pt"]) {
                        if ([groupWidthPtString length] > 0) {
                            groupWidthPtString = [groupWidthPtString substringToIndex:[groupWidthPtString length] - 2];
                            groupWidthWRTiOS = [groupWidthPtString floatValue] * 20 * iOSValueOfOneTwip;
                        }
                    }
                    if ([groupLeftMarginPtString containsString:@"pt"]) {
                        if ([groupLeftMarginPtString length] > 0) {
                            groupLeftMarginPtString = [groupLeftMarginPtString substringToIndex:[groupLeftMarginPtString length] - 2];
                            groupAndPageLeftMarginPt = ([pageLeftMarginTwip floatValue]/20) + [groupLeftMarginPtString floatValue];
                            groupLeftMarginIOS = [groupLeftMarginPtString floatValue] * 20 * iOSValueOfOneTwip;
                            groupLeftMarginWRTiOS =  pageLeftMarginIOS + groupLeftMarginIOS;
                            //                            groupLeftMarginWRTiOS = pageLeftMarginIOS + groupLeftMarginPt;
                        }
                    }
                    if ([groupTopMarginPtString containsString:@"pt"]) {
                        if ([groupTopMarginPtString length] > 0) {
                            groupTopMarginPtString = [groupTopMarginPtString substringToIndex:[groupTopMarginPtString length] - 2];
                            groupTopMarginIOS = [groupTopMarginPtString floatValue] * 20 * iOSValueOfOneTwip;
                            groupTopMarginWRTiOS = pageTopMarginIOS + groupTopMarginIOS;
                        }
                    }
                    
                    groupElementHeight = groupHeightWRTiOS;
                    
                    
                    NSArray* groupElementChildrenArray = [groupElement children];
                    
                    UIView* groupElementView = [[UIView alloc] initWithFrame: CGRectMake(groupLeftMarginWRTiOS, groupTopMarginWRTiOS, groupWidthWRTiOS, groupHeightWRTiOS)];
                    
                    for (DDXMLElement* groupChildElement in groupElementChildrenArray) {
                        NSString *elementPathString = groupChildElement.XPath.lastPathComponent;
                        NSString *elementNameString = [elementPathString lastPathComponent];
                        
                        if ([elementNameString containsString:@"shape"] && ![elementNameString containsString:@"shapetype"]) {
                            
                            DDXMLNode* styleNode = [groupChildElement attributeForName:@"style"];
                            
                            NSString* styleString = [styleNode stringValue];
                            
                            NSArray* styleAttribute = [styleString componentsSeparatedByString:@";"];
                            
                            NSMutableDictionary* styleDict = [NSMutableDictionary new];
                            for (NSString* att in styleAttribute) {
                                NSArray* styleKey = [att componentsSeparatedByString:@":"];
                                [styleDict setObject:[styleKey objectAtIndex:1] forKey:[styleKey objectAtIndex:0]];
                            }
                            NSString* ht = [styleDict valueForKey:@"height"];
                            NSString* wt = [styleDict valueForKey:@"width"];
                            NSString* left = [styleDict valueForKey:@"left"];
                            NSString* top = [styleDict valueForKey:@"top"];
                            NSString* pos = [styleDict valueForKey:@"position"];
                            
//                            float groupAndPageLeft = [groupLeftMarginPtString floatValue] + ([pageLeftMarginTwip floatValue]/20);
//
                            
//                            float groupElementLeftPosition = ([left floatValue]*iOSValueOfOneTwip) + groupLeftMarginIOS ;
//                            float groupElementTopPosition = ([top floatValue]*iOSValueOfOneTwip) + groupTopMarginIOS;
//                            float groupElementWidth = ([wt floatValue]*iOSValueOfOneTwip);
//                            float groupElementHeight = ([ht floatValue]*iOSValueOfOneTwip);
                            
//                            float groupElementLeftPosition = ((groupAndPageLeftMarginPt/groupCoordOriginX) * [left floatValue])*iOSValueOfOneTwip*20;
//                            float groupElementTopPosition = (groupTopMarginWRTiOS/groupCoordOriginY) * [top floatValue];
//                            float groupElementWidth = (groupWidthWRTiOS/groupCoordWidth) * [wt floatValue];
//                            float groupElementHeight = (groupHeightWRTiOS/groupCoordHeight) * [ht floatValue];
                            
                            float groupElementLeftPosition = (([left floatValue] - groupCoordOriginX)*iOSValueOfOneTwip) ; // minus groupCoordOriginX i.e. start from the origin
                            float groupElementTopPosition = (([top floatValue] - groupCoordOriginY)*iOSValueOfOneTwip);
                            float groupElementWidth = ([wt floatValue]*iOSValueOfOneTwip);
                            float groupElementHeight = ([ht floatValue]*iOSValueOfOneTwip);
                            
                            //v:image, v:textbox
                            NSArray* imageElementArray = [groupChildElement elementsForName:@"v:imagedata"];
                            
                            if (imageElementArray.count > 0) {
                               DDXMLElement* imageElement = [imageElementArray firstObject];
                                NSString* relationId = [[imageElement attributeForName:@"r:id"] stringValue];
                                
                                NSString* filePath = [[[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/word/_rels/document",unzipFolderName]] stringByAppendingPathExtension:@"xml"] stringByAppendingPathExtension:@"rels"];
                                
                                DDXMLDocument* relsDocument = [self parseXmlFromPath:filePath];
                                
                                DDXMLElement* relsRootElement = [relsDocument rootElement];
                                
                                NSString* imagePath;
                                NSArray* relationshipElementArray = [relsRootElement elementsForName:@"Relationship"];
                                for (DDXMLElement* relationshipElement in relationshipElementArray) {
                                   NSString* elementRelationId = [[relationshipElement attributeForName:@"Id"] stringValue];
                                    
                                    if ([elementRelationId isEqualToString:relationId]) {
                                       
                                        NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/word",unzipFolderName]];
                                        
                                        
                                       imagePath = [[relationshipElement attributeForName:@"Target"] stringValue];
                                       
                                        imagePath = [filePath stringByAppendingPathComponent:imagePath];
                                        break;
                                    }
                                }

                                if (imagePath != nil) {
                                    UIImageView* shapeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(groupElementLeftPosition, groupElementTopPosition, groupElementWidth, groupElementHeight)];
                                    
                                    shapeImageView.image = [UIImage imageWithContentsOfFile:imagePath];
                 
                                    [groupElementView addSubview:shapeImageView];
                                }
                            }
                            else{
                                NSArray* textboxElementArray = [groupChildElement elementsForName:@"v:textbox"];
                                
                                if (textboxElementArray.count > 0) {
                                    
                                  DDXMLElement* textboxElement =  [textboxElementArray firstObject];
                                    
                                  NSArray* txbxContentElementArray =  [textboxElement elementsForName:@"w:txbxContent"];
                                    
                                    if (txbxContentElementArray.count > 0) {
                                        
                                      DDXMLElement* txbxContentElement =  [txbxContentElementArray firstObject];
                                        
                                        NSArray* paragraphArray = [txbxContentElement elementsForName:@"w:p"];
                                        
                                        UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(groupElementLeftPosition, groupElementTopPosition, groupElementWidth, groupElementHeight)];
                                        
                                        [textView setBackgroundColor:[UIColor clearColor]];
                                        
                                        [textView setTextAlignment:NSTextAlignmentRight]; // Note: set statically, fetch the property then set
                                        
                                        for (int i =0 ; i < paragraphArray.count; i++)
                                        {
                                            if (i !=0) {
                                                textView.text = [textView.text stringByAppendingString:@"\n"];
                                            }
                                            DDXMLElement* paragraph = [paragraphArray objectAtIndex:i];
                                            
                                            // parahraph can have running elements or smartTags or so on
                                            NSArray *runningArray = [paragraph elementsForName:@"w:r"];
                                            
                                            if (runningArray.count > 0) {
                                                
                                                for (int i = 0; i < runningArray.count; i++) {
                                                    
                                                    DDXMLElement* runningElement = [runningArray objectAtIndex:i];
                                                    
                                                   
                                                    
                                                    NSArray *textArray = [runningElement elementsForName:@"w:t"];
                                                    
                                                    if (textArray.count>0)
                                                    {
                                                        isGroupElement = false;
                                                        
                                                        DDXMLElement* ele = [textArray objectAtIndex:0];
                                                        
                                                        DDXMLNode* str = [ele childAtIndex:0];
                                                        
                                                        [textView setFont:[UIFont fontWithName:@"Arial" size:5.4]];
                                                        
                                                        textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"%@",str]];
                                                        
                                                        NSString* updatedString = [textView.text stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                                                        
                                                        updatedString = [updatedString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                                                        
                                                        updatedString = [updatedString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                                                        
                                                        textView.text = updatedString;
                                                        
//                                                        CGRect frame = textView.frame;
//
//                                                        frame.size.height = textView.contentSize.height;
//
//                                                        textView.frame = frame;
                                                        
                                                        [textViewContentHeightDict setObject: [NSString stringWithFormat:@"%f",textView.contentSize.height] forKey:[NSString stringWithFormat:@"%ld",textView.tag]];
                                                        
                                                        [groupElementView addSubview:textView];
                                                    }

                                                }
                                                
                                            }
                                            
                                                NSArray *smartTagElementArray = [paragraph elementsForName:@"w:smartTag"];

                                                if (smartTagElementArray.count > 0) {
                                                    
                                                  DDXMLElement* smartTagElement =  [smartTagElementArray objectAtIndex:0];
                                                    
                                                  NSArray* innerSmartTagElementArray =  [smartTagElement elementsForName:@"w:smartTag"];
                                                    
                                                    if (innerSmartTagElementArray.count > 0) {
                                                        DDXMLElement* innerSmartTagElement =  [innerSmartTagElementArray objectAtIndex:0];
                                                        
                                                        NSArray* runningArray =    [innerSmartTagElement elementsForName:@"w:r"];
                                                        
                                                        if (runningArray.count > 0) {
                                                          DDXMLElement* runningElement =  [runningArray objectAtIndex:0];
                                                            
                                                          NSArray* textArray =  [runningElement elementsForName:@"w:t"];
                                                            
                                                            if (textArray.count > 0) {
                                                              DDXMLElement* textElement =  [textArray objectAtIndex:0];
                                                                
                                                              DDXMLNode* str =  [textElement childAtIndex:0];
                                                                
                                                                [textView setFont:[UIFont fontWithName:@"Arial" size:5.4]];
                                                                
                                                                textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"%@",str]];
                                                                
                                                                NSString* updatedString = [textView.text stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                                                                
                                                                updatedString = [updatedString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                                                                
                                                                updatedString = [updatedString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                                                                
                                                                textView.text = updatedString;
                                                                
        //                                                        CGRect frame = textView.frame;
        //
        //                                                        frame.size.height = textView.contentSize.height;
        //
        //                                                        textView.frame = frame;
                                                                
                                                                [textViewContentHeightDict setObject: [NSString stringWithFormat:@"%f",textView.contentSize.height] forKey:[NSString stringWithFormat:@"%ld",textView.tag]];
                                                                
                                                                [groupElementView addSubview:textView];
                                                            }
                                                        }

                                                    }
                                                }
                                            
                                        }
                                    }
                                }
                            }
                            
                           
                            
                        }
                        
                        //                    bool str1 = groupEle.XPath.absolutePath;
                        //                    NSString *str2 = groupEle.XPath.decomposedStringWithCanonicalMapping;
                        //                    NSString *str3 = groupEle.XPath.decomposedStringWithCompatibilityMapping;
                        
                        NSArray* shapeTypeArray;
                    }
                    textView.tag = 0;
                    
                    groupElementView.tag = textViewCount;
                    
                    totalTextHeight = totalTextHeight + groupElementView.frame.size.height;
                    
                    [insideView addSubview:groupElementView];
                    //                NSArray* shapeTypeArray = [groupElement elementsForName:@"v:shapetype"];
                    //                NSArray* shapeArray = [groupElement elementsForName:@"v:shape"];
                    //
                    //                DDXMLElement* shapeLement = [shapeArray objectAtIndex:0];
                    //                NSArray* imageDataArray = [shapeLement elementsForName:@"imagedata"];
                    //                DDXMLElement* imageDataElement = [imageDataArray objectAtIndex:0];
                }
                else if((pictArray = [runningElement elementsForName:@"w:tab"]).count > 0){
                    
                    NSString *elementPathString = runningElement.XPath;
                    NSLog(@"ele");
                }
//                else{
//                    textViewCount--;
//
//                    textView.tag = 0;
//
//                    textView.delegate = nil;
//
//                    [XPathForTextViewDict removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)textView.tag]];
//
//                    [elementIndexDict removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)textView.tag]];
//                }
                
            }
            
            if (textView.text.length > 0) { // dont add paragraph/runElement that dont have any content
            
            totalTextHeight = totalTextHeight + textView.frame.size.height;
            
            [insideView addSubview:textView];
            }
            else{ // if no text that may mean <w:r> with <w:tab>(atleast for the current nhs template) and no text...but you have to add the textfield since when you will fetch y posn and height in next loop you should get the below textfield.
                

                CGRect frame = textView.frame;

                frame.size.height = 35;
                frame.size.width = 0;

                textView.frame = frame;
                [insideView addSubview:textView];
            }
            
            
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
}

-(DDXMLDocument*) parseXmlFromPath:(NSString*)filePath
{
    
    
    //    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"document" ofType:@"xml"];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    
    relsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    
    
    return relsDocument;
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

     NSData* data = [theDocument XMLData];
    // NSString* editedFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/editedXML5"]] stringByAppendingPathExtension:@"xml"];
    
    NSError* err;
    NSString* editedFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/word/document",unzipFolderName]] stringByAppendingPathExtension:@"xml"];

    if([[NSFileManager defaultManager] fileExistsAtPath:editedFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:editedFilePath error:&err];
    }


    BOOL written = [data writeToFile:editedFilePath atomically:true];
    
    return written;

}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
   
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
    else if (runningPropElement != nil)
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

            
            UITextView* nextTextView = [insideView viewWithTag:i];

            CGRect nextFrame = nextTextView.frame;
            
            nextTextView.frame = CGRectMake(nextTextView.frame.origin.x, nextTextView.frame.origin.y+changedContentHeight, nextFrame.size.width, nextFrame.size.height);
            
            
            NSArray* constraints = [nextTextView constraints];
            
            for (NSLayoutConstraint* constraint in constraints)
            {
                [nextTextView removeConstraint:constraint];
            }
            
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
