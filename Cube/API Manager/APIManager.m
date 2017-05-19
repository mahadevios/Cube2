//
//  APIManager.m
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "APIManager.h"
#import "AppDelegate.h"
#import "Constants.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DepartMent.h"
#import "UIDevice+Identifier.h"
#import "TransferListViewController.h"
#import "NSData+AES256.h"
#import "SharedSession.h"


@implementation APIManager
@synthesize incompleteFileTransferCount,inCompleteFileTransferNamesArray,transferFailedCount,todaysFileTransferCount,awaitingFileTransferCount,awaitingFileTransferNamesArray,deletedListArray,transferredListArray,responsesData,session;
static APIManager *singleton = nil;

// Shared method
+(APIManager *) sharedManager
{
    if (singleton == nil)
    {
        singleton = [[APIManager alloc] init];
        
        return singleton;
        //[[AppPreferences sharedAppPreferences] startReachabilityNotifier];
    }
    else
    
    
    return singleton;
}

// Init method
-(id) init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

#pragma mark
#pragma mark ValidateUser API
#pragma mark

//-(void) validateUser:(NSString *) usernameString andPassword:(NSString *) passwordString
//{
//    if ([[AppPreferences sharedAppPreferences] isReachable])
//    {
//        NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"username=%@",usernameString], [NSString stringWithFormat:@"password=%@",passwordString] ,nil];
//
//        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
//
//        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:USER_LOGIN_API withRequestParameter:dictionary withResourcePath:USER_LOGIN_API withHttpMethd:POST];
//        [downloadmetadatajob startMetaDataDownLoad];
//    }
//    else
//    {
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }
//}

-(void)uploadNextFile
{
    if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
    {
       // [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
        
        NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
        
        [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
        
        [self uploadFileToServer:nextFileToBeUpload];
        
        
        
        NSLog(@"%ld",[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count);
        
    }
    else
    {
       // [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
    }

}

-(NSString*)getDateAndTimeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATE_TIME_FORMAT;
    NSString* recordCreatedDateString = [formatter stringFromDate:[NSDate date]];
    return recordCreatedDateString;
}
-(uint64_t)getFileSize:(NSString*)filePath
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;

    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath  error:&error];

    if (dictionary)
    {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];

    }
    else
    {
       // NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalSpace;
}

-(NSString*)getMacId
{
   return [[UIDevice currentDevice] identifierForVendor1];

}

-(uint64_t)getFreeDiskspace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace=((totalFreeSpace/(1024ll))/1024ll);
        //        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
       // NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}


-(BOOL)deleteFile:(NSString*)fileName
{
    NSError* error;
    NSString* filePath=[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,fileName]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return  false;
    }
    else
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        return true;
    }
}

-(void) checkDeviceRegistrationMacID:(NSString*)macID
{
    
    self.responsesData = [NSMutableDictionary new];
   
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];//to remove no internet message
        
        
        NSError* error;
        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macID,@"macid", nil];

        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        

        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];

       
        
        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];

        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:CHECK_DEVICE_REGISTRATION withRequestParameter:array withResourcePath:CHECK_DEVICE_REGISTRATION withHttpMethd:POST];
        [downloadmetadatajob startMetaDataDownLoad];

    }

        //
    
            else
    {
     //UIView* internetMessageView=   [[PopUpCustomView alloc]initWithFrame:CGRectMake(12, 100, 200, 200) senderForInternetMessage:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERNET_MESSAGE object:nil];

        
    }
    
}
//-(void) checkDeviceRegistrationMacIDEncr:(NSData *)macID
//{
//    
//    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
//    
//    
//    if ([[AppPreferences sharedAppPreferences] isReachable])
//    {
//        //NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"macid=%@",macID],nilID
//        [[[[UIApplication sharedApplication] keyWindow] viewWithTag:222] removeFromSuperview];//to remove no internet message
//        
//        
//        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macID,@"macid", nil];
//        
//        // NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
//        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary1, nil];
//        
//        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:CHECK_DEVICE_REGISTRATION withRequestParameter:array withResourcePath:CHECK_DEVICE_REGISTRATION withHttpMethd:POST];
//        [downloadmetadatajob startMetaDataDownLoad];
//    }
//    else
//    {
//        //UIView* internetMessageView=   [[PopUpCustomView alloc]initWithFrame:CGRectMake(12, 100, 200, 200) senderForInternetMessage:self];
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INTERNET_MESSAGE object:nil];
//        
//        
//    }
//    
//}

//-(void) checkDeviceRegistrationMacID:(NSString*) macID
//{
//    if ([[AppPreferences sharedAppPreferences] isReachable])
//    {
//        NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"macid=%@",macID],nil];
//        
//        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
//        
//        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:CHECK_DEVICE_REGISTRATION withRequestParameter:dictionary withResourcePath:CHECK_DEVICE_REGISTRATION withHttpMethd:POST];
//        [downloadmetadatajob startMetaDataDownLoad];
//    }
//    else
//    {
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }
//    
//}


-(void) authenticateUserMacID:(NSString*) macID password:(NSString*) password username:(NSString* )username
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
//        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macID,@"macid",password,@"pwd",username,@"username", nil];
//        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary1, nil];

        NSError* error;
        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macID,@"macid",password,@"pwd",username,@"username", nil];
        
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        
        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
        
        
        
        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:AUTHENTICATE_API withRequestParameter:array withResourcePath:AUTHENTICATE_API withHttpMethd:POST];
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
}

-(void) acceptPinMacID:(NSString*) macID Pin:(NSString*)pin
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
//        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macID,@"macid",pin,@"PIN", nil];
//        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary1, nil];
        
        
        NSError* error;
        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macID,@"macid",pin,@"PIN", nil];
        
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        
        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
        
        
        
        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:ACCEPT_PIN_API withRequestParameter:array withResourcePath:ACCEPT_PIN_API withHttpMethd:POST];
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
}

-(void) validatePinMacID:(NSString*) macID Pin:(NSString*)pin
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
//        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macID,@"macid",pin,@"PIN", nil];
//        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary1, nil];
        NSError* error;
        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:macID,@"macid",pin,@"PIN", nil];
        
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        
        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
        
        
        
        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];

        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:VALIDATE_PIN_API withRequestParameter:array withResourcePath:VALIDATE_PIN_API withHttpMethd:POST];
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
}

-(void)mobileDictationsInsertMobileStatus:(NSString* )mobilestatus OriginalFileName:(NSString*)OriginalFileName andMacID:(NSString*)macID
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"mobilestatus=%@",mobilestatus], [NSString stringWithFormat:@"OriginalFileName=%@",OriginalFileName] ,[NSString stringWithFormat:@"macID=%@",macID],nil];
        
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:DICTATIONS_INSERT_API withRequestParameter:dictionary withResourcePath:DICTATIONS_INSERT_API withHttpMethd:POST];
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
}

-(void)mobileDataSynchronisationMobileStatus:(NSString*)mobilestatus OriginalFileName:(NSString*)OriginalFileName macID:(NSString*)macid DeleteFlag:(NSString*)DeleteFlag
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"mobilestatus=%@",mobilestatus], [NSString stringWithFormat:@"OriginalFileName=%@",OriginalFileName] ,[NSString stringWithFormat:@"macID=%@",macid],nil];
        
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
        
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:DATA_SYNCHRONISATION_API withRequestParameter:dictionary withResourcePath:DATA_SYNCHRONISATION_API withHttpMethd:POST];
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
}


//-(void)uploadFileFilename:(NSString*)filename macID:(NSString*)macID fileSize:(NSString*)filesize
//{
//    if ([[AppPreferences sharedAppPreferences] isReachable])
//    {
//        NSArray *params = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"filename=%@",filename], [NSString stringWithFormat:@"macID=%@",macID] ,[NSString stringWithFormat:@"filesize=%@",filesize],nil];
//        
//        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:params,REQUEST_PARAMETER, nil];
//        
//        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:FILE_UPLOAD_API withRequestParameter:dictionary withResourcePath:FILE_UPLOAD_API withHttpMethd:POST];
//        [downloadmetadatajob startMetaDataDownLoad];
//    }
//    else
//    {
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//    }
//    
//    
//}

-(void)changePinOldPin:(NSString*)oldpin NewPin:(NSString*)newpin macID:(NSString*)macID
{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        
//        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:oldpin,@"oldpin",newpin,@"newpin",macID,@"macid", nil];
//        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary1, nil];

        NSError* error;
        NSDictionary *dictionary1 = [[NSDictionary alloc] initWithObjectsAndKeys:oldpin,@"oldpin",newpin,@"newpin",macID,@"macid", nil];
        
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary1
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        
        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
        
        
        
        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        NSDictionary *dictionary2 = [[NSDictionary alloc] initWithObjectsAndKeys:str2,@"encDevChkKey", nil];
        
        NSMutableArray* array=[NSMutableArray arrayWithObjects:dictionary2, nil];
        DownloadMetaDataJob *downloadmetadatajob=[[DownloadMetaDataJob alloc]initWithdownLoadEntityJobName:PIN_CANGE_API withRequestParameter:array withResourcePath:PIN_CANGE_API withHttpMethd:POST];
        [downloadmetadatajob startMetaDataDownLoad];
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
    
    
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
//    NSMutableData *responseData = self.responsesData[@(dataTask.taskIdentifier)];
//    if (!responseData) {
//        responseData = [NSMutableData dataWithData:data];
//        //self.responsesData[@(dataTask.taskIdentifier)] = responseData;
//    } else {
//        [responseData appendData:data];
//    }
    
//    NSString* fileName = self.responsesData[@(dataTask.taskIdentifier)];
    
    if (!(data == nil))
    {
        NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)dataTask.taskIdentifier]];
        
//        NSString* fileName;
//        
//        dispatch_async(dispatch_get_main_queue(), ^
//                       {
//                           //NSLog(@"Reachable");
        
        

//                           fileName = fileName1;
//                       });
        
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
                               NSString* idvalString= [result valueForKey:@"mobiledictationidval"];
                               NSString* date= [[APIManager sharedManager] getDateAndTimeString];
                               Database* db=[Database shareddatabase];
                               
                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  //NSLog(@"Reachable");
                                                   NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];
                                                  
                                                  [db updateAudioFileUploadedStatus:@"Transferred" fileName:fileName dateAndTime:date mobiledictationidval:[idvalString longLongValue]];
                                                  
                                                  [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUploaded" fileName:fileName];

                                                  
                                                  [[Database shareddatabase] deleteIdentifierFromDatabase:taskIdentifier];
                                                  
                                                  
                                                 // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                      
                                                      if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
                                                      {
                                                          [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                                                          
//                                                          NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
//                                                          
//                                                          [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
//                                                          
//                                                          [self uploadFileToServer:nextFileToBeUpload];
                                                          
                                                          
                                                          
                                                          NSLog(@"%ld",[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count);
                                                          
                                                      }
                                                      else
                                                      {
                                                       [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                                                      }
                                                      

                                                      
                                                 // });
                                                  
                                                  if (fileName != nil)
                                                  {
                                                      [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict removeObjectForKey:fileName];
                                                      // NSLog(@"%@",[NSString stringWithFormat:@"%@ uploaded successfully",str]);
                                                      
                                                      [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"%@ uploaded successfully",fileName] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
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
                                                  
                                                   [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:fileName dateAndTime:@"" mobiledictationidval:0];
                                                  [[Database shareddatabase] deleteIdentifierFromDatabase:taskIdentifier];

                                                   [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:nil];
                                                  
                                                    [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict removeObjectForKey:fileName];
                                                  NSLog(@"%@",result);
                                                  [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:@"File uploading failed" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                                                  
                                                  
                                                  
                                                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                      
                                                      if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
                                                      {
                                                          [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                                                          
                                                          NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
                                                          
                                                          [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
                                                          
                                                          [self uploadFileToServer:nextFileToBeUpload];
                                                          
                                                          
                                                          
                                                          NSLog(@"%ld",[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count);
                                                          
                                                      }
                                                      else
                                                      {
                                                          [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                                                      }
                                                      
                                                      
                                                      
                                                  });

                                              });
                             
                              
                               
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
        if (error.code == -999)
        {
            NSLog(@"cancelled from app delegate");

            NSLog(@"%@",error.localizedDescription);

        }
        else
        {
//          NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)dataTask.taskIdentifier]];
        
        
       // if (error.code == -997)
       // {
//            //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                
//                [dataTask cancel];
//
          NSLog(@"%@",error);
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];
//

                    
                    [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:fileName dateAndTime:@"" mobiledictationidval:0];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:nil];
                    
                    NSLog(@"%@",fileName);
                    
                   // NSLog(@"%@",result);
                    
                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"Server connection lost!,file uploading failed"] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];

//                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"%ld %@ %@",(long)error.code,error.localizedDescription,error.localizedRecoverySuggestion] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
                        {
                            
                            [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                            
                            NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
                            
                            [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
                            
                            [self uploadFileToServer:nextFileToBeUpload];
                            
                           // [[Database shareddatabase] deleteIdentifierFromDatabase:taskIdentifier];

                            
                            NSLog(@"%ld",[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count);
                            
                        }
                        else
                        {
                            [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
                        }
                        
                         //dispatch_async(dispatch_get_main_queue(), ^{
                             

                         //});
                        
                    });
                    


                });
//
//                //[UIApplication sharedApplication].idleTimerDisabled = YES;
//           // });
        
      //  }
        }
        
    }
    else
    {
        //[dataTask cancel];
        
//        dispatch_async(dispatch_get_main_queue(), ^
//                       {
//                           //NSLog(@"Reachable");
//                           NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];
//                           
//                           [[Database shareddatabase] deleteIdentifierFromDatabase:taskIdentifier];
//
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//            if ([AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count>0)
//            {
//                [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
//                
////                NSString* nextFileToBeUpload = [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray objectAtIndex:0];
////                
////                [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray removeObjectAtIndex:0];
////                
////                [self uploadFileToServer:nextFileToBeUpload];
//                
//                
//                
//                NSLog(@"%ld",[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray.count);
//                
//            }
//            else
//            {
//                [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray removeObject:fileName];
//            }
//            
//            
//            
//        });
//                           
//                       });

        //[dataTask cancel];
    }
    
}
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    
//    int64_t totalBytesSent1=0;
//
//    if (totalBytesSent>(totalBytesExpectedToSend*0.1))
//    {
//        totalBytesSent1 = totalBytesSent-totalBytesExpectedToSend*0.02;
//
//    }
//    if (totalBytesSent1<=0)
//    {
//        totalBytesSent1 = 0;
//    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
//                   {
//
//                   });
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        float progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
        //NSLog(@"progress %f",progress);
        
        NSString* progressPercent= [NSString stringWithFormat:@"%f",progress*100];
        
        int progressPercentInInt=[progressPercent intValue];
        
        progressPercent=[NSString stringWithFormat:@"%d",progressPercentInInt];
        
        NSString* progressShow= [NSString stringWithFormat:@"%@%%",progressPercent];
        
        NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier]];
    
        NSString* fileName = [[Database shareddatabase] getfileNameFromTaskIdentifier:taskIdentifier];

        NSLog(@"%@: %@",fileName,progressPercent);
        
        
        if (([AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict.count==0))
        {
            [AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict = [NSMutableDictionary new];
            
            if (!(fileName== nil))
            {
                if ([progressShow isEqual:@"100%"])
                {
                    progressShow = @"99%";
                }
                [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict setValue:progressShow forKey:fileName];
            }
            
        }
        else
        {
            if (!(fileName== nil))
            {
                if ([progressShow isEqual:@"100%"])
                {
                    progressShow = @"99%";
                }
                [[AppPreferences sharedAppPreferences].fileNameSessionIdentifierDict setValue:progressShow forKey:fileName];
            }
            
        }

    
    });
    
  //  NSString* progressAndFileName = [[progressShow stringByAppendingString:@"%@$"] stringByAppendingString:fileName];
   
  //  [self performSelectorInBackground:@selector(updateProgressDataAndforFileName:) withObject:progressAndFileName];
   // [self performSelector:@selector(updateProgressDataAndforFileName:) withObject:progressAndFileName afterDelay:0.5];
    
    
  
   // NSDictionary* dict = [NSDictionary new];

}



-(void)uploadFileToServerUsingNSURLSession:(NSString*)str

{
   
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           departmentId= [[Database shareddatabase] getDepartMentIdForFileName:str];
                           transferStatus=[[Database shareddatabase] getTransferStatus:str];
                           mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:str];
                           
                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                               
                               [self uploadFileAfterGettingdatabaseValues:str departmentID:departmentId transferStatus:transferStatus mobileDictationIdVal:mobileDictationIdVal];
                               
                           });
                           
                       });
        

    
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
    
}

-(void)uploadFileAfterGettingdatabaseValues:(NSString*)str departmentID:(int)departmentID transferStatus:(int)transferStatus mobileDictationIdVal:(int)mobileDictationIdVal
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,str] ];
    
    NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, FILE_UPLOAD_API]];
    
    NSString *boundary = [self generateBoundaryString];
    
    NSDictionary *params = @{@"filename"     : str,
                             };
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    long filesizelong=[[APIManager sharedManager] getFileSize:filePath];
    
    int filesizeint=(int)filesizelong;
    
    // NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
    //DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];//    if ([[[NSUserDefaults standardUserDefaults]
    
    
    //NSString* macId=[Keychain getStringForKey:@"udid"];
    
    NSString* macId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MacId"];
    
    if (transferStatus==0)
        transferStatus=1;
    else if(transferStatus==1)
    {
        transferStatus=5;
    }
    else if(transferStatus==3)
    {
        transferStatus=5;
    }
    else if(transferStatus==2)
    {
        transferStatus=1;
    }
    else if(transferStatus==4)
    {
        transferStatus=5;
    }
    
    if (departmentId == 0)
    {
        departmentId= [[Database shareddatabase] getDepartMentIdForFileName:str];
        
    }
    
    // NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%ld*%d*%d",macId,filesizeint,deptObj.Id,1,0];
    NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%d*%d*%d",macId,filesizeint,departmentID,transferStatus,mobileDictationIdVal];
    
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //    NSError* error;
    
    
    NSData* jsonData=[authorisation dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
    
    
    
    NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
    
    [request setValue:str2 forHTTPHeaderField:@"Authorization"];
    
    // create body
    
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:params paths:@[filePath] fieldName:str];
    
    
    

    
    request.HTTPBody = httpBody;
    
//    NSInputStream *readData = [[NSInputStream alloc] initWithData:httpBody];
//    [readData open];
//    
//    request.HTTPBodyStream = readData;
//    
//    [readData close];
    
    session = [SharedSession getSharedSession:[APIManager sharedManager]];
    
    //
    [request setHTTPMethod:@"POST"];
    
    
    NSURLSessionUploadTask* uploadTask = [session uploadTaskWithRequest:request fromData:nil];
//    NSURLSessionUploadTask* uploadTask = [session uploadTaskWithStreamedRequest:request];
    
    
    
    
    NSString* taskIdentifier = [[NSString stringWithFormat:@"%@",session.configuration.identifier] stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)uploadTask.taskIdentifier]];
    
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       //NSLog(@"Reachable");
                       
                       [[Database shareddatabase] insertTaskIdentifier:[NSString stringWithFormat:@"%@",taskIdentifier] fileName:str];
                   });
    
    
    
    
    
    [uploadTask resume];

}


- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{

    
}

-(void)uploadFileToServer:str
{
    if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count<2)
    {
        if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count == 1)
        {
            NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,[[AppPreferences sharedAppPreferences].filesInUploadingQueueArray objectAtIndex:0]] ];
            
            long firstFileSize = [self getFileSize:filePath];

            if (firstFileSize>30000000)
            {
                [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
            }
            
            else
            {
                filePath = [NSHomeDirectory() stringByAppendingPathComponent:
                            [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,str]];
                long secondFileSize = [self getFileSize:filePath];

                if (secondFileSize>30000000)
                {
                    [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
                }
                
                else
                {
                    [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray addObject:str];
                    [self uploadFileToServerUsingNSURLSession:str];
                }
            }
        }
        
        else
        {
            [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray addObject:str];
            [self uploadFileToServerUsingNSURLSession:str];
        }

    }
    else
    {
        [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
    }
    //[self uploadFileToServerUsingNSURLConnection:str];

}

//-(void)uploadFileToServer:str
//{
//if ([AppPreferences sharedAppPreferences].filesInUploadingQueueArray.count<2)
//{
//    [[AppPreferences sharedAppPreferences].filesInUploadingQueueArray addObject:str];
//    [self uploadFileToServerUsingNSURLSession:str];
//    
//}
//else
//{
//    [[AppPreferences sharedAppPreferences].filesInAwaitingQueueArray addObject:str];
//}
//}
-(void)uploadFileToServerUsingNSURLConnection:(NSString*)str

{
    if ([[AppPreferences sharedAppPreferences] isReachable])
    {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        
        NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"Documents/%@/%@.wav",AUDIO_FILES_FOLDER_NAME,str] ];
        
        NSURL* url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL_PATH, FILE_UPLOAD_API]];
        
        NSString *boundary = [self generateBoundaryString];
        
        NSDictionary *params = @{@"filename"     : str,
                                 };
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        [request setHTTPMethod:@"POST"];
        
        long filesizelong=[[APIManager sharedManager] getFileSize:filePath];
        
        int filesizeint=(int)filesizelong;
        
        // NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_DEPARTMENT_NAME];
        //DepartMent *deptObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];//    if ([[[NSUserDefaults standardUserDefaults]
        
        int departmentId= [[Database shareddatabase] getDepartMentIdForFileName:str];
        
        NSString* macId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MacId"];

        //NSString* macId=[Keychain getStringForKey:@"udid"];
        transferStatus=[[Database shareddatabase] getTransferStatus:str];
        if (transferStatus==0)
            transferStatus=1;
        else if(transferStatus==1)
        {
            transferStatus=5;
        }
        else if(transferStatus==3)
        {
            transferStatus=5;
        }
        else if(transferStatus==2)
        {
            transferStatus=1;
        }
        int mobileDictationIdVal=[[Database shareddatabase] getMobileDictationIdFromFileName:str];
        
        
        
        // NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%ld*%d*%d",macId,filesizeint,deptObj.Id,1,0];
        NSString* authorisation=[NSString stringWithFormat:@"%@*%d*%d*%d*%d",macId,filesizeint,departmentId,transferStatus,mobileDictationIdVal];
        
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        //    NSError* error;
        
        
        NSData* jsonData=[authorisation dataUsingEncoding:NSUTF8StringEncoding];
        
        
        NSData *dataDesc = [jsonData AES256EncryptWithKey:SECRET_KEY];
        
        
        
        NSString* str2=[dataDesc base64EncodedStringWithOptions:0];
        
        [request setValue:str2 forHTTPHeaderField:@"Authorization"];
        
        // create body
        
        NSData *httpBody = [self createBodyWithBoundary:boundary parameters:params paths:@[filePath] fieldName:str];
        
        request.HTTPBody = httpBody;
        
        

        
        
        
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (connectionError)
                {
        
        
        //            [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:str dateAndTime:@"" mobiledictationidval:0];
                    //-1001 for request time out and -1005 network connection lost
                    if (connectionError.code==-1001 || connectionError.code==-1005)
                    {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
                             [UIApplication sharedApplication].idleTimerDisabled = YES;
                            [self uploadFileToServer:str];
                        });
                    }
                    else
                    {
                       // [UIApplication sharedApplication].idleTimerDisabled = NO;
        
                        NSString* date= [[APIManager sharedManager] getDateAndTimeString];
        
                        [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:str dateAndTime:date mobiledictationidval:0];
        
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
        
                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"File uploading failed, %@",connectionError.localizedDescription] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                    }
                    NSLog(@"error = %@", connectionError);
        
                    return;
                }
        
                NSError* error;
                NSString* encryptedString = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
                //NSString* returnCode= [result valueForKey:@"code"];
        
                //    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:responseData
                //                                                                 options:NSUTF8StringEncoding
                //                                                                   error:&error];
        
        //
        //        NSString *encryptedResponse = [NSJSONSerialization JSONObjectWithData:encryptedString
        //                                                                      options:NSUTF8StringEncoding
        //                                                                        error:&error];
        
        
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encryptedString options:0];
                NSData* data1=[decodedData AES256DecryptWithKey:SECRET_KEY];
                NSString* responseString=[[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
                responseString=[responseString stringByReplacingOccurrencesOfString:@"True" withString:@"1"];
                responseString=[responseString stringByReplacingOccurrencesOfString:@"False" withString:@"0"];
        
                NSData *responsedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
                result = [NSJSONSerialization JSONObjectWithData:responsedData
                                                           options:NSJSONReadingAllowFragments
                                                             error:&error];
        
                NSString* returnCode= [result valueForKey:@"code"];
        
                if ([returnCode longLongValue]==200)
                {
                    NSString* idvalString= [result valueForKey:@"mobiledictationidval"];
                    NSString* date= [[APIManager sharedManager] getDateAndTimeString];
                    Database* db=[Database shareddatabase];
                    [db updateAudioFileUploadedStatus:@"Transferred" fileName:str dateAndTime:date mobiledictationidval:[idvalString longLongValue]];
                    [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUploaded" fileName:str];
        
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
                   // NSLog(@"%@",[NSString stringWithFormat:@"%@ uploaded successfully",str]);
        
                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"%@ uploaded successfully",str] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                  
                    
                }
                else
                {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
                     [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:str dateAndTime:@"" mobiledictationidval:0];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
        
                    NSLog(@"%@",str);
        
                    NSLog(@"%@",result);
                  [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:@"File uploading failed" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
                }
                
            }];
        
        
    }
    else
    {
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"No internet connection!" withMessage:@"Please check your inernet connection and try again." withCancelText:nil withOkText:@"OK" withAlertTag:1000];
    }
    
    
}


- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName
{
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add image data
    
    for (NSString *path in paths)
    {
        NSString *filename  = [path lastPathComponent];
        NSData   *data1      = [NSData dataWithContentsOfFile:path];
        
        NSData *data = [data1 AES256EncryptWithKey:SECRET_KEY];

        NSString *mimetype  = [self mimeTypeForPath:path];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}


- (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}


- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"*%@", [[NSUUID UUID] UUIDString]];
    //return [NSString stringWithFormat:@"*"];
    
}

//***********************
//        NSURLSessionConfiguration * backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"task1"];
//        NSURLSession *session = [NSURLSession sharedSession];
//        //
//        //
//        [request setHTTPMethod:@"POST"];
//
//        [AppPreferences sharedAppPreferences].uploadTask = [session uploadTaskWithRequest:request fromData:nil];
//
//        [ [AppPreferences sharedAppPreferences].uploadTask resume];

//        [AppPreferences sharedAppPreferences].uploadTask = [session         uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//        {
//            //Perform operations on your response here
//
//            if (error)
//            {
//
//
//
//                if (error.code==-1001 || error.code==-1005)
//                {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//                        [UIApplication sharedApplication].idleTimerDisabled = YES;
//                        //[self uploadFileToServer:str];
//                        [[AppPreferences sharedAppPreferences].uploadTask resume];
//
//                       //// [[AppPreferences sharedAppPreferences].uploadTask resume];
//                    });
//                }
//                else
//                {
//                    // [UIApplication sharedApplication].idleTimerDisabled = NO;
//                    dispatch_async(dispatch_get_main_queue(), ^
//                                   {
//                                       //NSLog(@"Reachable");
//                                       NSString* date= [[APIManager sharedManager] getDateAndTimeString];
//
//                                       [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:str dateAndTime:date mobiledictationidval:0];
//
//                                       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//
//                                       [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
//
//                                       [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"File uploading failed, %@",error.localizedDescription] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//                                   });
//
//
//                }
//                NSLog(@"error = %@", error);
//
//                return;
//            }
//
//            NSError* error1;
//            NSString* encryptedString = [NSJSONSerialization JSONObjectWithData:data
//                                                                        options:NSJSONReadingAllowFragments
//                                                                          error:&error1];
//
//            dispatch_async(dispatch_get_main_queue(), ^
//                           {
//                               NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encryptedString options:0];
//                               NSData* data1=[decodedData AES256DecryptWithKey:SECRET_KEY];
//                               NSString* responseString=[[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
//                               responseString=[responseString stringByReplacingOccurrencesOfString:@"True" withString:@"1"];
//                               responseString=[responseString stringByReplacingOccurrencesOfString:@"False" withString:@"0"];
//
//                               NSData *responsedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
//
//                               result = [NSJSONSerialization JSONObjectWithData:responsedData
//                                                                        options:NSJSONReadingAllowFragments
//                                                                          error:nil];
//
//                               NSString* returnCode= [result valueForKey:@"code"];
//
//                               if ([returnCode longLongValue]==200)
//                               {
//                                   NSString* idvalString= [result valueForKey:@"mobiledictationidval"];
//                                   NSString* date= [[APIManager sharedManager] getDateAndTimeString];
//                                   Database* db=[Database shareddatabase];
//                                   [db updateAudioFileUploadedStatus:@"Transferred" fileName:str dateAndTime:date mobiledictationidval:[idvalString longLongValue]];
//                                   [[Database shareddatabase] updateAudioFileStatus:@"RecordingFileUploaded" fileName:str];
//
//                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//
//                                   [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
//                                   // NSLog(@"%@",[NSString stringWithFormat:@"%@ uploaded successfully",str]);
//
//                                   [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:[NSString stringWithFormat:@"%@ uploaded successfully",str] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//
//
//                               }
//                               else
//                               {
//                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//
//                                   [[Database shareddatabase] updateAudioFileUploadedStatus:@"TransferFailed" fileName:str dateAndTime:@"" mobiledictationidval:0];
//                                   [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FILE_UPLOAD_API object:response];
//
//                                   NSLog(@"%@",str);
//
//                                   NSLog(@"%@",result);
//                                   [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Alert" withMessage:@"File uploading failed" withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//                               }
//
//                           });
//
//
//
//        }];
//
//        //Don't forget this line ever
//     [[AppPreferences sharedAppPreferences].uploadTask resume];
//
//*********************



@end
