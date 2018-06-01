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
    
    
    if ([self.downLoadEntityJobName isEqualToString:CHECK_DEVICE_REGISTRATION])
    {
        //        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        //        [appDelegate hideIndefiniteProgressView];
        
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:[self shortErrorFromError:error] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
        
    }
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
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Can't connect to the sever, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }else
    {
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
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SEND_DICTATION_IDS_API object:response];
//                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Message" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
            }
        }else
        {
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
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"Something went wrong, Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }


}



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




        }
        else
        {



            //NSLog(@"%@",fileName);


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


    dispatch_async(dispatch_get_main_queue(), ^{

        float progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
        //NSLog(@"progress %f",progress);

        NSString* progressPercent= [NSString stringWithFormat:@"%f",progress*100];



    });



}
//
//
//
-(void)downloadFileUsingNSURLSession:(NSString*)str

{

    if ([[AppPreferences sharedAppPreferences] isReachable])
    {

        dispatch_async(dispatch_get_main_queue(), ^
                       {

                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                               [self downloadFile:dataArray];

                           });

                       });



    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your internet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
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
