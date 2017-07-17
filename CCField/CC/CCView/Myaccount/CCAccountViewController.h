//
//  CCAccountViewController.h
//  CCField
//
//  Created by 李付 on 14-10-14.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCRootViewController.h"
#import "ASIFormDataRequest.h"
#import "CSDataService.h"

@interface CCAccountViewController : CCRootViewController<ASIHTTPRequestDelegate>{
    NSDictionary *jsonDic;
}

@property (weak, nonatomic) IBOutlet UIImageView *number;
@property (weak, nonatomic) IBOutlet UIImageView *job;
@property (weak, nonatomic) IBOutlet UIImageView *line;
@property (weak, nonatomic) IBOutlet UIImageView *lineCentre;
@property (weak, nonatomic) IBOutlet UIImageView *lineUp;

@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *role;

@end
