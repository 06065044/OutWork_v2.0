//
//  CCMyTaskViewController.h
//  CCField
//
//  Created by 马伟恒 on 14-10-13.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCRootViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"

typedef NS_ENUM(NSInteger,TASK_STATUS){
    TASK_STATUS_RUN = 2,
    TASk_STATUS_DELAY=3,
    TASK_STATUS_DELAYDONE = 4,
    TASK_STATUS_DONE = -1
};
@interface CCMyTaskViewController : CCRootViewController
{
    NSArray *responArr;
}
@end
