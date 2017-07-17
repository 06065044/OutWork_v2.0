//
//  CCImportViewController.h
//  CCField
//
//  Created by 李付 on 14/11/12.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CYCustomMultiSelectPickerView.h"
#import "CCRootViewController.h"
#import "ALPickerView.h"
#import "CCImportCell.h"

@interface CCImportViewController : CCRootViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,CYCustomMultiSelectPickerViewDelegate>{
    
    UITableView *importTable;
    NSArray *dataArray;
    NSArray *timeArray;
    UIButton *btn;
    UIDatePicker *datePickerView;
    UIView *viewMain;
    UIView *viewHidde;
    UILabel *lableText;
    
    NSArray *entirsArray;
    NSArray *entriesSelected;
    NSMutableDictionary *seletionStates;
    CYCustomMultiSelectPickerView *multiPickerView;
    
}

@end
