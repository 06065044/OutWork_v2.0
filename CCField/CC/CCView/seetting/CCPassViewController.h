//
//  CCPassViewController.h
//  CCField
//
//  Created by 李付 on 14-10-16.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCUtil.h"
#import "CCRootViewController.h"
#import "ASIHTTPRequest.h"
 #import "NSString+MD5Addition.h"

@interface CCPassViewController : CCRootViewController<ASIHTTPRequestDelegate>{
    NSDictionary *dicJson;
    NSString *user;
}

@property (weak, nonatomic) IBOutlet UIImageView *lineUp;
@property (weak, nonatomic) IBOutlet UITextField *oldPass;
@property (weak, nonatomic) IBOutlet UIImageView *lineCenter;
@property (weak, nonatomic) IBOutlet UITextField *passNew;
@property (weak, nonatomic) IBOutlet UIImageView *lineDown;
@property (weak, nonatomic) IBOutlet UITextField *repeatPass;
@property (weak, nonatomic) IBOutlet UIImageView *repeatLine;

@end
