//
//  CCImportViewController.m
//  CCField
//
//  Created by 李付 on 14/11/12.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCImportViewController.h"
#import "CCUtil.h"
@interface CCImportViewController ()
{
    int indexSelect;
}
@end

@implementation CCImportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lableNav.text=@"基础设置";
    
    viewHidde=[[UIView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth,2000,0,0)];
    viewHidde.hidden=YES;
    
    //初始化数组
    entirsArray=@[@"星期一", @"星期二", @"星期三", @"星期四", @"星期五",@"星期六",@"星期日"];
    //初始化选中数组
    seletionStates=[[NSMutableDictionary alloc]init];
    //配置选中状态
    for (NSString *key in entirsArray) {
        BOOL isSeleted=NO;
        for (NSString *keyed in entriesSelected ) {
            if ([key isEqualToString:keyed]) {
                isSeleted=YES;
            }
        }
        [seletionStates setObject:[NSNumber numberWithBool:isSeleted] forKey:key];
    }
    
    
    
    importTable=[[UITableView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(self.imageNav.frame), 320, kFullScreenSizeHeght-65) style:UITableViewStylePlain];
    //tableSetting.separatorStyle = UITableViewCellSeparatorStyleNone;
    importTable.rowHeight=60;
    importTable.delegate=self;
    importTable.backgroundColor = [UIColor clearColor];

    importTable.dataSource=self;
    [self setExtraCellLineHidden:importTable];
    [self.view addSubview:importTable];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }else if (section==1)
    {
        return 1;
    }else if (section==2)
    {
        return 3;
    }else if (section==3)
    {
        return 1;
    }
    return YES;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *Main=[[UIView alloc]init];
    Main.backgroundColor=RGBA(236, 236, 243, 1);
    
    if (section==0) {
        UILabel *lable1=[[UILabel alloc]initWithFrame:CGRectMake(5,0, 80, 30)];
        lable1.text=@"位置上报";
        lable1.font=[UIFont systemFontOfSize:14];
        lable1.textColor=[UIColor blackColor];
        lable1.backgroundColor=[UIColor clearColor];
        [Main addSubview:lable1];
    }
    if (section==1) {
        UILabel *lable2=[[UILabel alloc]initWithFrame:CGRectMake(5,0, 120, 30)];
        lable2.text=@"工作日设置";
        lable2.font=[UIFont systemFontOfSize:14];
        lable2.textColor=[UIColor blackColor];
        lable2.backgroundColor=[UIColor clearColor];
        [Main addSubview:lable2];
        
    }if (section==2) {
        UILabel *lable3=[[UILabel alloc]initWithFrame:CGRectMake(5,0, 150, 30)];
        lable3.text=@"上报时间";
        lable3.font=[UIFont systemFontOfSize:14];
        lable3.textColor=[UIColor blackColor];
        lable3.backgroundColor=[UIColor clearColor];
        [Main addSubview:lable3];
    }else if (section==3)
    {
        UILabel *lable4=[[UILabel alloc]initWithFrame:CGRectMake(5,0, 150, 30)];
        lable4.text=@"打卡时间提醒";
        lable4.font=[UIFont boldSystemFontOfSize:14];
        lable4.textColor=[UIColor blackColor];
        lable4.backgroundColor=[UIColor clearColor];
        [Main addSubview:lable4];
        UISwitch *switch4 = [[UISwitch alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth-70 , 0, 100, 10)];
        switch4.tag = 338;
        if ([defaults boolForKey:@"autoAlarm"]) {
            switch4.on = YES;
        }
        else
            switch4.on = NO;
        [Main addSubview:switch4];
        [switch4 addTarget:self action:@selector(changeAlarm:) forControlEvents:UIControlEventValueChanged];
        switch4.transform = CGAffineTransformMakeScale(1, .75);
    }
    return Main;
}

-(void)quxiao{
    if (indexSelect==0) {
        if (viewHidde) {
            [viewHidde removeFromSuperview];
        }
        if (datePickerView) {
            [datePickerView removeFromSuperview];
        }
        return;
    }
    if (viewHidde) {
        [viewHidde removeFromSuperview];
    }
    if (datePickerView) {
        [datePickerView removeFromSuperview];
    }
    
    CCImportCell*cell=(CCImportCell*)[importTable cellForRowAtIndexPath:importTable.indexPathForSelectedRow ];
    importTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    //  UITextField *text=(UITextField *)[cell.contentView viewWithTag:3000+table.indexPathForSelectedRow.row];
    //lableText=(UILabel*)[cell.contentView viewWithTag:3000+importTable.indexPathForSelectedRow.row];
    NSDate *select = [datePickerView date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //更改样式HH:mm:ss 改为HH:mm
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    cell.detaLable.text=dateAndTime;
    //detaLable.text=dateAndTime;
    
    if (indexSelect==1) {
        
        NSString *start=dateAndTime;
        start=[start stringByReplacingOccurrencesOfString:@"-" withString:@""];
        start=[start stringByReplacingOccurrencesOfString:@" " withString:@""];
        start=[start stringByReplacingOccurrencesOfString:@":" withString:@""];
        
        
        NSString *end=[[[NSUserDefaults standardUserDefaults]objectForKey:END_TIME] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        end=[end stringByReplacingOccurrencesOfString:@" " withString:@""];
        end=[end stringByReplacingOccurrencesOfString:@":" withString:@""];
        if ([start longLongValue]>[end longLongValue]) {
            [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"开始时间不能大于开始时间"];
            cell.detaLable.text=[[NSUserDefaults standardUserDefaults]objectForKey:START_TINE];
            return;
        }
        [[NSUserDefaults standardUserDefaults]setObject:dateAndTime forKey:START_TINE];
    }
    if (indexSelect==2) {
        NSString *start=[[NSUserDefaults standardUserDefaults]objectForKey:START_TINE];
        start=[start stringByReplacingOccurrencesOfString:@"-" withString:@""];
        start=[start stringByReplacingOccurrencesOfString:@" " withString:@""];
        start=[start stringByReplacingOccurrencesOfString:@":" withString:@""];
        
        NSString *end=[dateAndTime stringByReplacingOccurrencesOfString:@"-" withString:@""];
        end=[end stringByReplacingOccurrencesOfString:@" " withString:@""];
        end=[end stringByReplacingOccurrencesOfString:@":" withString:@""];
        if ([start longLongValue]>[end longLongValue]) {
            [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"结束时间不能小于开始时间"];
            cell.detaLable.text=[[NSUserDefaults standardUserDefaults]objectForKey:END_TIME];
            return;
        }
        [[NSUserDefaults standardUserDefaults]setObject:dateAndTime forKey:END_TIME];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(void)changeChoice:(UISwitch *)switchOn{
    if (switchOn.isOn) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"auto"];
    }
    else
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"auto"];

}
-(void)changeAlarm:(UISwitch *)siwtch4{
    if (siwtch4.isOn) {
        //
        [defaults setBool:YES forKey:@"autoALarm"];
    }
    else{
        [defaults setBool:NO forKey:@"autoAlarm"];
    
    }

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==2) {
        indexSelect=indexPath.row;
        if (indexPath.row==0) {
            [self cancnelapick];
            //点击选择时间
            if ([self.view viewWithTag:109]) {
                [[self.view viewWithTag:109]removeFromSuperview];
            }
            NSArray *Arr=@[@"1分钟",@"5分钟",@"10分钟",@"15分钟",@"20分钟",@"30分钟",@"40分钟",@"50分钟"];
            UIView *backGround=[[UIView alloc]initWithFrame:self.view.bounds];
            backGround.backgroundColor=[UIColor grayColor];
            backGround.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
            backGround.tag=109;
            UITapGestureRecognizer *cancel=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cencelBACK)];
            cancel.numberOfTapsRequired=1;
            cancel.numberOfTouchesRequired=1;
            [backGround addGestureRecognizer:cancel];
            
            
            [self.view addSubview:backGround];
            [self.view bringSubviewToFront:backGround];
            
            UIView *selectView=[[UIView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth/2-50, kFullScreenSizeHeght/2-50, 100, Arr.count*35)];
            selectView.backgroundColor=[UIColor whiteColor];
            [backGround addSubview:selectView];
            for (int i=0; i<Arr.count; i++) {
                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(10, 35*i, 80, 30)];
                lab.text=Arr[i];
                lab.font = [UIFont systemFontOfSize:12];
                lab.userInteractionEnabled=YES;
                UITapGestureRecognizer *removeGes=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reloadSelf:)];
                removeGes.numberOfTapsRequired=1;
                removeGes.numberOfTouchesRequired=1;
                [lab addGestureRecognizer:removeGes];
                [selectView addSubview:lab];
                
                UIImageView *downLine=[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(lab.frame), CGRectGetMaxY(lab.frame), CGRectGetWidth(lab.frame), 1)];
                downLine.backgroundColor=[UIColor blackColor];
                [selectView addSubview:downLine];
                
            }
            
            
        }
        
        
        if (indexPath.row==1||indexPath.row==2) {
             
            if (viewHidde) {
                [viewHidde removeFromSuperview];
            }
            for (UIView *view in self.view.subviews) {
                if ([view isKindOfClass:[CYCustomMultiSelectPickerView class]]) {
                    [view removeFromSuperview];
                }
            }
            
            
            viewHidde=[[UIView alloc]init];
            viewHidde.frame = CGRectMake(0, kFullScreenSizeHeght,kFullScreenSizeWidth,200);
            viewHidde.backgroundColor=[UIColor grayColor];
            [self.view addSubview:viewHidde];
            
            UIButton *quxiaoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            quxiaoBtn.backgroundColor=[UIColor redColor];
            quxiaoBtn.frame=CGRectMake(20, 5,80, 40);
            quxiaoBtn.clipsToBounds = YES;
            quxiaoBtn.layer.cornerRadius=3.0f;

            [quxiaoBtn addTarget:self action:@selector(quxiao) forControlEvents:UIControlEventTouchUpInside];
            quxiaoBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            [quxiaoBtn setTitle:@"确定" forState:UIControlStateNormal];
            [viewHidde addSubview:quxiaoBtn];
            
            UIButton *cancel=[UIButton buttonWithType:UIButtonTypeCustom];
            cancel.frame=CGRectOffset(quxiaoBtn.frame, 190, 0);
            cancel.clipsToBounds = YES;
            cancel.layer.cornerRadius=3.0f;
            [cancel addTarget:self action:@selector(cancnelapick) forControlEvents:UIControlEventTouchUpInside];
            cancel.titleLabel.font = [UIFont systemFontOfSize:12];
            [cancel setTitle:@"取消" forState:UIControlStateNormal];
            cancel.backgroundColor=[UIColor redColor];
            [viewHidde addSubview:cancel];
            
            
            datePickerView =[[UIDatePicker alloc] initWithFrame:CGRectZero];
            datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            datePickerView.datePickerMode = UIDatePickerModeTime;
            datePickerView.frame=CGRectMake(0,30,kFullScreenSizeWidth,150);
            [viewHidde addSubview:datePickerView];
            [UIView animateWithDuration:0.3 animations:^{
                
                self->viewHidde.frame=CGRectMake(0,kFullScreenSizeHeght-200,kFullScreenSizeWidth,200);
                
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    else if (indexPath.section==1)
    {
        
        if (indexPath.row==0) {
            
            for (UIView *view in self.view.subviews) {
                if ([view isKindOfClass:[CYCustomMultiSelectPickerView class]]) {
                    [view removeFromSuperview];
                }
            }
            
            multiPickerView = [[CYCustomMultiSelectPickerView alloc] initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 260-20, 320, 260+44)];
            //multiPickerView = [[CYCustomMultiSelectPickerView alloc] initWithFrame:CGRectMake(0,400, 320, 260+44)];
            multiPickerView.entriesArray = entirsArray;
            multiPickerView.entriesSelectedArray = entriesSelected;
            multiPickerView.multiPickerDelegate = self;
            [self.view addSubview:multiPickerView];
            [multiPickerView pickerShow];
        }
    }else if (indexPath.section==3)
    {
        CCImportCell *CELL=(CCImportCell *)[tableView cellForRowAtIndexPath:indexPath];
        CCImportCell *cell1=nil;
        if (indexPath.row==0) {
            cell1=(CCImportCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]];
        }
        else{
            cell1=(CCImportCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
        }
        CELL.accessoryType=UITableViewCellAccessoryCheckmark;
        cell1.accessoryType=UITableViewCellAccessoryNone;
    }
}
-(void)cancnelapick{
    if (viewHidde) {
        [viewHidde removeFromSuperview];
    }
    if (datePickerView) {
        [datePickerView removeFromSuperview];
    }
}
-(void)doSth:(UIGestureRecognizer *)rego{
    
    UILabel *lab=(UILabel *)rego.view;
    CCImportCell *cell=(CCImportCell *)[importTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
    cell.detaLable.text=[NSString stringWithFormat:@"每隔%@将自动上报你的位置",lab.text];
    //
    [[self.view viewWithTag:109]removeFromSuperview];
    [defaults setObject:@([[lab.text stringByReplacingOccurrencesOfString:@"分钟" withString:@""]intValue]*60) forKey:ISSTIMEINTERVAL];
    [CCUtil showMBLoading:nil detailText:@"正在刷新计时器"];
    [self performSelector:@selector(removeHud) withObject:nil afterDelay:5];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(updateNoti) withObject:nil afterDelay:10];
    });
}
-(void)cencelBACK{
    if ([self.view viewWithTag:109]) {
        [[self.view viewWithTag:109]removeFromSuperview];
    }
}
-(void)removeHud{
    [CCUtil hideMBLoading];
}
-(void)updateNoti{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTimer" object:nil];
}
-(void)reloadSelf:(UIGestureRecognizer *)rego{
    
    //    [[self class]cancelPreviousPerformRequestsWithTarget:self selector:@selector(doSth:) object:rego];
    //    [self performSelector:@selector(doSth:) withObject:rego afterDelay:0.2f];
    [self doSth:rego];
}
#pragma mark - Delegate
-(void)returnChoosedPickerString:(NSMutableArray *)selectedEntriesArr
{
    NSLog(@"selectedArray=%@",selectedEntriesArr);
    if (selectedEntriesArr.count==0) {
        return;
    }
    NSArray *Arr=[NSArray arrayWithObjects:@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日", nil];
    NSMutableString *str=[NSMutableString string];
    for (NSString *final in Arr) {
        if ([selectedEntriesArr containsObject:final]) {
            [str appendString:[final substringFromIndex:2]];
            continue;
        }
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithString:str] forKey:UPLOAD_DAYS];
    
    CCImportCell*cell=(CCImportCell*)[importTable cellForRowAtIndexPath:importTable.indexPathForSelectedRow ];
    importTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    cell.detaLable.text=[NSString stringWithString:str];
    cell.detaLable.font = [UIFont systemFontOfSize:12];
    // showLbl.text = dataStr;
    // 再次初始化选中的数据
    entriesSelected = [NSArray arrayWithArray:selectedEntriesArr];
}


- (CCImportCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CCSettingCell";
    CCImportCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    

    if (!cell) {
        cell =[[CCImportCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.showPic.hidden=YES;
    }
    
    if (indexPath.section==0) {
        
        if (indexPath.row==0) {
            cell.titleLable.text=@"自动上报位置";
            cell.titleLable.font = [UIFont boldSystemFontOfSize:14];
            cell.detaLable.text=@"将每段时间自动上报位置";
            cell.detaLable.font = [UIFont systemFontOfSize:12];
            cell.titleLable.textColor = [UIColor blackColor];

            // [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"auto"];
            UISwitch *Switch = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 40, 20)];
            cell.accessoryView = Switch;
            Switch.tag = 337;
             [Switch addTarget:self action:@selector(changeChoice:) forControlEvents:UIControlEventValueChanged];
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"auto"]) {
                Switch.on = YES;
            }
            else
                Switch.on = NO;
            
        }
    }else if (indexPath.section==2)
    {
        cell.showPic.hidden=NO;
        if (indexPath.row==0) {
            cell.titleLable.text=@"时间间隔";
            cell.titleLable.font = [UIFont boldSystemFontOfSize:14];
            NSTimeInterval time=[[defaults objectForKey:ISSTIMEINTERVAL]doubleValue];
            cell.detaLable.text=[NSString stringWithFormat:@"每隔%d分钟将自动上报你的位置",(int)time/60];
            cell.detaLable.font = [UIFont systemFontOfSize:12];
            cell.titleLable.textColor = [UIColor blackColor];
            

        }
        if (indexPath.row==1) {
            cell.titleLable.text=@"开始时间";
            cell.titleLable.font = [UIFont boldSystemFontOfSize:14];
            cell.titleLable.textColor = [UIColor blackColor];

            NSLog(@"%@---------",[defaults objectForKey:START_TINE]);
            if ([[defaults objectForKey:START_TINE] length]>0) {
                cell.detaLable.text=[defaults objectForKey:START_TINE];
                cell.detaLable.font = [UIFont systemFontOfSize:12];
            }
            
        }
        if (indexPath.row==2) {
            cell.titleLable.text=@"结束时间";
            cell.titleLable.font = [UIFont boldSystemFontOfSize:14];
            cell.titleLable.textColor = [UIColor blackColor];

            
            if ([[defaults objectForKey:END_TIME] length]>0) {
                cell.detaLable.text=[defaults objectForKey:END_TIME];
                cell.detaLable.font = [UIFont systemFontOfSize:12];
            }
        }
    }
    else if (indexPath.section==1)
    {
        if (indexPath.row==0) {
            cell.titleLable.text=@"";
            cell.titleLable.font = [UIFont boldSystemFontOfSize:14];
            cell.titleLable.textColor = [UIColor blackColor];

            if ([[defaults objectForKey:UPLOAD_DAYS] length]>0) {
                cell.detaLable.text=[defaults objectForKey:UPLOAD_DAYS];
                cell.detaLable.font = [UIFont systemFontOfSize:12];
            }
            
            
        }
    }
    else if (indexPath.section==3)
    {
        if (indexPath.row==0) {
            cell.titleLable.text=@"打卡提醒时间";
            cell.detaLable.text=@"提前5分钟";
            
        }
    }
    
    
    return cell;
}



- (void)didReceiveMemoryWarning {
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
    if (!self.view.window&&self.isViewLoaded) {
        for (UIView *subView in self.view.subviews) {
            [subView removeFromSuperview];
        }
        self.view = nil;
        
    }
}@end
