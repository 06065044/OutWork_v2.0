//
//  CCReportViewController.h
//  CCField
//
//  Created by 李付 on 14-10-9.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCRootViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"

@interface CCReportViewController : CCRootViewController<ASIHTTPRequestDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITableView *reportView;
    NSArray *jsonArray;
    NSDictionary  *jsonDic;
    int   NOSize; 
}

@end
