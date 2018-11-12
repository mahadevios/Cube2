//
//  DownloadMetaDataJob.m
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "DownloadMetaDataJob.h"
#include <sys/xattr.h>
#import "AppDelegate.h"
#import "LoginViewController.h"

/*================================================================================================================================================*/

@implementation DownloadMetaDataJob
@synthesize downLoadEntityJobName;
@synthesize requestParameter;
@synthesize downLoadResourcePath;
@synthesize downLoadJobDelegate;
@synthesize httpMethod;

@synthesize addTrintsAfterSomeTimeTimer;
@synthesize currentSaveTrintIndex;
@synthesize isNewMatchFound;
@synthesize dataArray;
@synthesize downloadMethodType;
@synthesize session;
-(id) initWithdownLoadEntityJobName:(NSString *) jobName withRequestParameter:(id) localRequestParameter withResourcePath:(NSString *) resourcePath withHttpMethd:(NSString *) httpMethodParameter downloadMethodType:(NSString*)downloadMethodType
{
    self = [super init];
    if (self)
    {
        self.downLoadResourcePath = resourcePath;
        //self.requestParameter = localRequestParameter;
        self.downLoadEntityJobName = [[NSString alloc] initWithFormat:@"%@",jobName];
        self.httpMethod=httpMethodParameter;
        self.dataArray=localRequestParameter;
        self.isNewMatchFound = [NSNumber numberWithInt:1];
        self.downloadMethodType = downloadMethodType;
    }
    return self;
}

/*================================================================================================================================================*/

#pragma mark -
#pragma mark StartMetaDataDownload
#pragma mark -

-(void)startMetaDataDownLoad
{
    [self sendNewRequestWithResourcePath:downLoadResourcePath withRequestParameter:dataArray withJobName:downLoadEntityJobName withMethodType:httpMethod];
}


-(void) sendNewRequestWithResourcePath:(NSString *) resourcePath withRequestParameter:(NSMutableArray *)array withJobName:(NSString *)jobName withMethodType:(NSString *) httpMethodParameter
{
    responseData = [NSMutableData data];
    
//    NSArray *params = [self.requestParameter objectForKey:REQUEST_PARAMETER];
//    
//    NSMutableString *parameter = [[NSMutableString alloc] init];
//    for(NSString *strng in params)
//    {
//        if([[params objectAtIndex:0] isEqualToString:strng]) {
//            [parameter appendFormat:@"%@", strng];
//        } else {
//            [parameter appendFormat:@"&%@", strng];
//        }
//    }
    
    NSString *webservicePath = [NSString stringWithFormat:@"%@/%@",BASE_URL_PATH,resourcePath];
   // NSString *webservicePath = [NSString stringWithFormat:@"%@/%@?%@",BASE_URL_PATH,resourcePath,parameter];

    NSURL *url = [[NSURL alloc] initWithString:[webservicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [request setHTTPMethod:httpMethodParameter];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSError* error;
    

    
    //NSDictionary* dic=[array objectAtIndex:0];
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:&error];
    
    
    [request setHTTPBody:requestData];
//    NSError* error;
//    NSData *requestData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:&error];


    
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%@",urlConnection);
}




/*================================================================================================================================================*/

#pragma mark -
#pragma mark - URL connection callbacks
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[responseData setLength:0];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    statusCode = (int)[httpResponse statusCode];
    ////NSLog(@"Status code: %d",statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
//    NSLog(@"%@",data);
    
	[responseData appendData:data];
}


- (NSString *)shortErrorFromError:(NSError *)error
{
   
    return [error localizedDescription];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Failed %@",error.description);
    NSLog(@"%@ Entity Job -",self.downLoadEntityJobName);
    
    
//    if ([self.downLoadEntityJobName isEqualToString:CHECK_DEVICE_REGISTRATION])
//    {
        //        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        //        [appDelegate hideIndefiniteProgressView];
        
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:[self shortErrorFromError:error] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
    
    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error Occured!" withMessage:@"Please Try Again" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    ////NSLog(@"Success");
    
    NSError *error;
//    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:responseData
//                                                                 options:NSUTF8StringEncoding
//                                                                   error:&error];
    
    
    NSString *encryptedResponse = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSUTF8StringEncoding
                                                               error:&error];
    
//    encryptedResponse = nil;
    
    if ([encryptedResponse containsString:@"ExceptionMessage"] || [encryptedResponse containsString:@"ExceptionType"] || [encryptedResponse containsString:@"Message"] || [encryptedResponse containsString:@"StackTrace"] || encryptedResponse == nil)
    {
        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        
        return;
    }
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encryptedResponse options:0];
    
    NSData* data=[decodedData AES256DecryptWithKey:SECRET_KEY];
    
    NSString* responseString=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSDictionary *response;
    if (responseString!=nil)
    {
        responseString=[responseString stringByReplacingOccurrencesOfString:@"True" withString:@"1"];
        responseString=[responseString stringByReplacingOccurrencesOfString:@"False" withString:@"0"];
        
        NSData *responsedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        //NSData *responsedData1 = [responseString dataUsingEncoding:NSDataBase64Encoding64CharacterLineLength];

        response = [NSJSONSerialization JSONObjectWithData:responsedData
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&error];

    }
    
//    NSString *response1 = [NSJSONSerialization JSONObjectWithData:responseData
//                                                             options:NSJSONReadingAllowFragments
//                                                               error:&error];
//    NSData *decryptedData = [RNDecryptor decryptData:responseData
//                                        withSettings:kRNCryptorAES256Settings
//                                            password:SECRET_KEY
//                                               error:&error];
//    NSString *encString = [decryptedData base64EncodedStringWithOptions:0];
    //NSLog(@"Job Name = %@ Response %@",self.downLoadEntityJobName,response);
    //NSLog(@"%@",response);
    
//    if ([self.downLoadEntityJobName isEqualToString:CHECK_DEVICE_REGISTRATION])
//    {
//        if (response != nil)
//        {
//            if ([[response objectForKey:@"code"] isEqualToString:SUCCESS])
//            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_DEVICE_REGISTRATION object:response];
//                
//                
//            }else
//            {
//                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//            }
//        }else
//        {
//            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//        }
//    }
 
  



if([self.downLoadEntityJobName isEqualToString:CHECK_DEVICE_REGISTRATION])

{
    
    if (response != nil)
    {
//        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:response1 options:0];
//        NSData* data=[decodedData AES256DecryptWithKey:SECRET_KEY];
//        NSString* responseString=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        
//        responseString=[responseString stringByReplacingOccurrencesOfString:@"True" withString:@"1"];
//        responseString=[responseString stringByReplacingOccurrencesOfString:@"False" withString:@"0"];
//
//        NSData *responsedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
//        
//        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responsedData
//                                                                                options:NSJSONReadingAllowFragments
//                                                                                  error:&error];
        
        NSLog(@"%@",error);
//        const unsigned char *ptr = [data bytes];
//        
//        for(int i=0; i<[data length]; ++i) {
//            unsigned char c = *ptr++;
//            NSLog(@"char=%c hex=%x", c, c);
//        }
//
//        NSArray* arrayOfStrings = [strr componentsSeparatedByString:@","];
//
//        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayOfStrings options:NSJSONWritingPrettyPrinted error:&error];
//        NSDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
//
//        NSString* sdf=[strr stringByReplacingOccurrencesOfString:@"," withString:@";"];
//        
//        NSData* dataone=[sdf dataUsingEncoding:NSUTF8StringEncoding];
//        
//       
//
//        id json = [NSJSONSerialization JSONObjectWithData:dataone options:NSJSONReadingAllowFragments error:nil];

       // NSString* sttt=[jsonResponse valueForKey:@"code"];
        NSString* code=[response objectForKey:RESPONSE_CODE];
        NSString* pinVerify=[response objectForKey:RESPONSE_PIN_VERIFY];

        
        if ([code intValue]==401 && [pinVerify intValue]==0)
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_DEVICE_REGISTRATION object:response];
            
            
        }
        else
        if ([code intValue]==200 && [pinVerify intValue]==0)
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_DEVICE_REGISTRATION object:response];
            
            
        }
        else
        if ([code intValue]==200 && [pinVerify intValue]==1)
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_DEVICE_REGISTRATION object:response];
            
            
        }
        else
        {
            [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Can't connect to the sever, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }else
    {
        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
}




if ([self.downLoadEntityJobName isEqualToString:AUTHENTICATE_API])
{
    
    if (response != nil)
    {
    [response objectForKey:@"code"];
        if ([[response objectForKey:@"code"]intValue]==200)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AUTHENTICATE_API object:response];
            
            
        }else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AUTHENTICATE_API object:response];

        }
    }else
    {
        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
}
//
//
if ([self.downLoadEntityJobName isEqualToString:ACCEPT_PIN_API])
{
    
    if (response != nil)
    {
        
        if ([[response objectForKey:@"code"]intValue]==200)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ACCEPT_PIN_API object:response];
            
            
        }
        else
        {
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }else
    {
        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
}
//
if ([self.downLoadEntityJobName isEqualToString:VALIDATE_PIN_API])
{
    
    if (response != nil)
    {
        
        if ([[response objectForKey:@"code"]intValue]==200)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_VALIDATE_PIN_API object:response];
            
            
        }else
            if ([[response objectForKey:@"code"]intValue]==401)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_VALIDATE_PIN_API object:response];
        }
    }else
    {
        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
}
//
//
if ([self.downLoadEntityJobName isEqualToString:DICTATIONS_INSERT_API])
{
    
    if (response != nil)
    {
        
        if ([[response objectForKey:@"code"] isEqualToString:SUCCESS])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DICTATIONS_INSERT_API object:response];
            
            
        }else
        {
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }else
    {
        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
}
    
    if ([self.downLoadEntityJobName isEqualToString:SEND_DICTATION_IDS_API])
    {
        
        if (response != nil)
        {
            [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
            
            if ([[response objectForKey:@"code"] isEqualToString:@"200"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEND_DICTATION_IDS_API object:response];
                
                
            }
            else
            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEND_DICTATION_IDS_API object:response];
//                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Message" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
            }
        }else
        {
            [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }
    
    if ([self.downLoadEntityJobName isEqualToString:SEND_COMMENT_API])
    {
        
        if (response != nil)
        {
            [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
            
            if ([[response objectForKey:@"code"] isEqualToString:@"200"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEND_COMMENT_API object:response];
                
                
            }else
            {
                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
            }
        }else
        {
            [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }
    
    if ([self.downLoadEntityJobName isEqualToString:DATA_SYNCHRONISATION_API])
    {
        
        if (response != nil)
        {
            
            if ([[response objectForKey:@"code"] isEqualToString:SUCCESS])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DATA_SYNCHRONISATION_API object:response];
                
                
            }else
            {
                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
            }
        }else
        {
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }
//
    
    if ([self.downLoadEntityJobName isEqualToString:FILE_DOWNLOAD_API])
    {
        
        if (response != nil)
        {
            
            if ([[response objectForKey:@"code"] isEqualToString:@"200"])
            {
                
                NSString* path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"doc"];
                
                NSString* byteCodeString = [response valueForKey:@"ByteDocForDownload"];
                
                NSString* DictationID = [response valueForKey:@"DictationID"];
                
                NSString* fileName = [[Database shareddatabase] getfileNameFromDictationID:DictationID];
                
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:byteCodeString options:0];
                
                //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                
                //NSString *documentsDirectory = [paths objectAtIndex:0];
                
                //NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile4.doc"];
                
                //bool isWritten = [decodedData writeToFile:appFile atomically:YES];
                
                NSString* destpath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Downloads/%@",fileName]];
                
                NSString* newDestPath = [destpath stringByAppendingPathExtension:@"doc"];
                
                NSString* filePath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Downloads"]];
                
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:newDestPath])
                {
                    NSError* error;
                    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
                    
                   BOOL iswritten =  [decodedData writeToFile:newDestPath atomically:YES];
                    
                }
                else
                {
                    [decodedData writeToFile:destpath atomically:YES];
                    
                }
                
                [[Database shareddatabase] updateDownloadingStatus:DOWNLOADED dictationId:8103552];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_DOWNLOAD_API object:response];
                
                
            }else
            {
                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
            }
        }else
        {
            [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }

    
    if ([self.downLoadEntityJobName isEqualToString:PIN_CANGE_API])
    {
        
        if (response != nil)
        {
            
            if ([[response objectForKey:@"code"]intValue]==200)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PIN_CANGE_API object:response];
                
                
            }else
            {
                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Pin changed failed, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
            }
        }else
        {
            [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }


}





//
-(void)downloadFile:(NSArray*)dataArray
{
//    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;


   
    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, FILE_DOWNLOAD_API]];

   
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    [request setHTTPMethod:@"POST"];


    
    NSError* error;


    // NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%ld*%d*%d",macId,filesizeint,deptObj.Id,1,0];

    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    //    NSError* error;



    // create body

    NSData *requestData = [NSJSONSerialization dataWithJSONObject:dataArray options:kNilOptions error:&error];
    
    
    
    [request setHTTPBody:requestData];




    session = [SharedSession getSharedSession:[APIManager sharedManager]];

    //
    [request setHTTPMethod:@"POST"];


    NSURLSessionDownloadTask* downloadTask = [session downloadTaskWithRequest:request];

    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       //NSLog(@"Reachable");

                   });





    [downloadTask resume];

}





-(void)uploadDocxFileAfterGettingdatabaseValues:(NSString*)fileName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //    [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    });
    
    
    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"Documents/%@/%@",DOCX_FILES_FOLDER_NAME,fileName] ];
    
    NSURL* url =[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, DOCX_FILE_UPLOAD_API]];
    
    
    
    NSString *boundary = [[APIManager sharedManager] generateBoundaryString];
    
//    NSDictionary *params = @{@"filename"     : docxFileName,
//                             };
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
//    long filesizelong=[[APIManager sharedManager] getFileSize:filePath];
//    
//    int filesizeint=(int)filesizelong;
//    
//    NSString* macId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MacId"];
    
    
//    if (departmentId == 0)
//    {
//        departmentId= [[Database shareddatabase] getDepartMentIdForFileName:docxFileName];
//
//    }
    
//    NSString* authorisation = [NSString stringWithFormat:@"%@*%d*%d*%d",macId,filesizeint,departmentID,mobileDictationIdVal];

    NSString* authorisation;

    for(int i=0; i<headerParameter.count;i++)
    {
        if (i!=headerParameter.count-1)
        {
            [authorisation stringByAppendingString:[NSString stringWithFormat:@"*%@",[headerParameter objectAtIndex:i]]];
        }
    }
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //    NSError* error;
    
    
    NSData* jsonData=[authorisation dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    [request setValue:str2 forHTTPHeaderField:@"Authorization"];
    
    // create body
    
    NSData *httpBody = [[APIManager sharedManager] createBodyWithBoundary:boundary parameters:requestParameter paths:@[filePath] fieldName:fileName];
    
    request.HTTPBody = httpBody;
    
    
    session = [SharedSession getSharedSession:self];
    
    //
    [request setHTTPMethod:@"POST"];
    
    
    NSURLSessionUploadTask* uploadTask = [session uploadTaskWithRequest:request fromData:nil];
    
    NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)uploadTask.taskIdentifier]];
    
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       //NSLog(@"Reachable");
                       
                       [[Database shareddatabase] insertTaskIdentifier:[NSString stringWithFormat:@"%@",taskIdentifier] fileName:fileName];
                   });
    
    [uploadTask resume];
    
}



#pragma mark: NSURLSession Delgates


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    
    if (!(data == nil))
    {
        NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)dataTask.taskIdentifier]];
        
        
        
        NSError* error1;
        NSString* encryptedString = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingAllowFragments
                                                                      error:&error1];
        
        
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encryptedString options:0];
        NSData* data1=[decodedData AES256DecryptWithKey:SECRET_KEY];
        NSString* responseString=[[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        responseString=[responseString stringByReplacingOccurrencesOfString:@"True" withString:@"1"];
        responseString=[responseString stringByReplacingOccurrencesOfString:@"False" withString:@"0"];
        
        NSData *responsedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        result = [NSJSONSerialization JSONObjectWithData:responsedData
                                                 options:NSJSONReadingAllowFragments
                                                   error:nil];
        
        NSString* returnCode= [result valueForKey:@"code"];
        
        if ([returnCode longLongValue]==200)
        {
//            NSString* idvalString= [result valueForKey:@"mobiledictationidval"];
//            NSString* date= [[APIManager sharedManager] getDateAndTimeString];
//            Database* db=[Database shareddatabase];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               //NSLog(@"Reachable");
                               NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];
                               
                              
                               if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
                               {
                                   [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                                   
                                   NSLog(@"%ld",[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count);
                                   
                               }
                               else
                               {
                                   [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                               }
                              
                               
                               if (fileName != nil)
                               {
                                   [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict removeObjectForKey:fileName];
                                   
                               }
                               
                               [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:fileName];
                               
                               [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPLOAD_NEXT_FILE object:fileName];
                             
                           });
            
            
        }
        else
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               //NSLog(@"Reachable");
                               NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];
                               
                               [[Database shareddatabase] deleteIdentifierFromDatabase:taskIdentifier];
                               
                               [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict removeObjectForKey:fileName];
                               NSLog(@"%@",result);
                               
                               
                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                   
                                   if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
                                   {
                                       [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                                       
                                       NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
                                       
                                       [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
                                       
                                       [[APIManager sharedManager] uploadDocxFileToServer:nextFileToBeUpload];
                                       
                                       NSLog(@"%ld",[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count);
                                       
                                   }
                                   else
                                   {
                                       [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                                   }
                         
                               });
                               
                           });
 
            
        }
        
        
        
        
        
        
    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)dataTask didCompleteWithError:(NSError *)error
{
    //[dataTask resume];
    NSLog(@"error code:%ld",(long)error.code);
    
    NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)dataTask.taskIdentifier]];
    
    if (error)
    {
        if (error.code == -999)
        {
            NSLog(@"cancelled from app delegate");
            
            NSLog(@"%@",error.localizedDescription);
            
        }
        else
        {
            
            NSLog(@"%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];
                //
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
                    {
                        
                        [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                        
                        NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
                        
                        [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
                        
                        [[APIManager sharedManager] uploadDocxFileToServer:nextFileToBeUpload];
                        
                        NSLog(@"%ld",[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count);
                        
                    }
                    else
                    {
                        [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                    }
                    
                 
                });
                
                
                
            });
          
        }
        
    }
    else
    {
       
    }
    
}
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    
   
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        float progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
//        //NSLog(@"progress %f",progress);
//
//        NSString* progressPercent= [NSString stringWithFormat:@"%f",progress*100];
//
//        int progressPercentInInt=[progressPercent intValue];
//
//        progressPercent=[NSString stringWithFormat:@"%d",progressPercentInInt];
//
//        NSString* progressShow= [NSString stringWithFormat:@"%@%%",progressPercent];
//
//        NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier]];
//
//        NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];
//
//        NSLog(@"%@: %@",fileName,progressPercent);
//
//
//        if (([AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict.count==0))
//        {
//            [AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict = [NSMutableDictionary new];
//
//            if (!(fileName== nil))
//            {
//                if ([progressShow isEqual:@"100%"])
//                {
//                    progressShow = @"99%";
//                }
//                [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict setValue:progressShow forKey:fileName];
//            }
//
//        }
//        else
//        {
//            if (!(fileName== nil))
//            {
//                if ([progressShow isEqual:@"100%"])
//                {
//                    progressShow = @"99%";
//                }
//                [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict setValue:progressShow forKey:fileName];
//            }
//
//        }
//
//
//    });
    
 
}

//
//
//- (void)URLSession:(NSURLSession *)session
//              task:(NSURLSessionTask *)task
// needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
//{
//
//
//}
//
//-(void)uploadFileToServer:(NSString*)str jobName:(NSString*)jobName
//{
//
//    [self uploadFileToServerUsingNSURLSession:str];
//
//}

@end

/*================================================================================================================================================*/
