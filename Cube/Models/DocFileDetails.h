//
//  DocFileDetails.h
//  Cube
//
//  Created by mac on 19/12/17.
//  Copyright © 2017 Xanadutec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocFileDetails : NSObject

@property(nonatomic, strong) NSString* docFileName;
@property(nonatomic, strong) NSString* audioFileName;

@property(nonatomic) int uploadStatus;
@property(nonatomic, strong) NSString* uploadDate;
@property(nonatomic, strong) NSString* createdDate;
@property(nonatomic) int deleteStatus;

@end
