//
//  CCMessageViewController.h
//  CCField
//
//  Created by 李付 on 14/10/20.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCNewingsViewController.h"
#import "CCRootViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"

@interface CCMessageViewController : CCRootViewController<UITableViewDelegate,UITableViewDataSource,ASIHTTPRequestDelegate>{
    UITableView *tableMessage;
    NSArray *jsonArray;
    int   NOSize; 
}

@end
