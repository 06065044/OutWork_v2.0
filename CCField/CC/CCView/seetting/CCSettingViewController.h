//
//  CCSettingViewController.h
//  CCField
//
//  Created by 李付 on 14-10-15.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCSettingCell.h"
#import "CCPassViewController.h"
#import "CCRootViewController.h"
#import "CCLoginViewController.h"
#import "CCImportViewController.h"

@interface CCSettingViewController : CCRootViewController<UITableViewDataSource,UITableViewDelegate>{
    
    UITableView *tableSetting;
    NSArray *name;
}
@end
