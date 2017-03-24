//
//  SharedSession.m
//  Cube
//
//  Created by mac on 14/03/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import "SharedSession.h"



@implementation SharedSession

static NSURLSession * sharedSession =nil;

+(NSURLSession*) getSharedSession:(id)sender
{
    if (sharedSession== nil)
    {
       
        sharedSession = [[SharedSession alloc] init];
        
        NSURLSessionConfiguration * backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"Xanadutec"];
        //NSTimeInterval interval =  [backgroundConfig timeoutIntervalForResource];
        
       // [backgroundConfig setTimeoutIntervalForRequest:5];
        sharedSession = [NSURLSession sessionWithConfiguration:backgroundConfig delegate:sender delegateQueue:[NSOperationQueue mainQueue]];
        
        return sharedSession;
    }
    else
    {
        return  sharedSession;
    }

}



@end
