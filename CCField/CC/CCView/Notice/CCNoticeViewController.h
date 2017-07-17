//
//  CCNoticeViewController.h
//  CCField
//
//  Created by 李付 on 14-10-16.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCPubilshViewController.h"
#import "CCRootViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"

@interface CCNoticeViewController : CCRootViewController<UITableViewDelegate,UITableViewDataSource,ASIHTTPRequestDelegate>{
    
    UITableView *tableNotice;
    NSArray *jsonArray;
    int   NOSize;
}

@end
