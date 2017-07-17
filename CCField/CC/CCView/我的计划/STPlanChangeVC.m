//
//  STPlanChangeVC.m
//  CCField
//
//  Created by 马伟恒 on 16/6/24.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STPlanChangeVC.h"
#import "CCUtil.h"
#import "CCCheckReplyViewController.h"
#import "ASIHTTPRequest.h"

@interface STPlanChangeVC()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
{
    NSArray *titleArr;
    NSArray *contentArr;
    UITableView *table;
    UIDatePicker *datePickerView;
    BOOL weihu;
    NSString *startTime;
    UIView *view;
    NSIndexPath *indexpath;
}
@end
static NSString *cellIDENTI=@"cellid";

@implementation STPlanChangeVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.lableNav.text=@"修改计划";
    titleArr=[NSArray arrayWithObjects:@"任务名称:",@"计划名称:",@"计划内容:",@"计划开始时间:",@"计划结束时间:",nil];
    contentArr=[NSArray arrayWithObjects:@"taskName",@"title",@"planContent",@"planStartTime",@"planEndTime",nil];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(kFullScreenSizeWidth-50, 22, 40, 40)];
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(weihu) forControlEvents:UIControlEventTouchUpInside];
    [self.imageNav addSubview:button];
    button.tag=234;
    
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)) style:UITableViewStylePlain];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIDENTI];
    table.delegate=self;
    table.dataSource=self;
    table.backgroundColor = [UIColor clearColor];

    table.tableFooterView= [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:table];
}
#pragma mark ==table
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==2||indexPath.row==5 ) {
        return 80;
    }
    return 40;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count+1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    startTime=[self.INFODIC objectForKey:contentArr[3]];
    UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:cellIDENTI forIndexPath:indexPath];
    
    UILabel *labTitle=[[UILabel alloc]initWithFrame:CGRectMake(20, 15, 100, 30)];
    if (indexPath.row<titleArr.count) {
        labTitle.text=titleArr[indexPath.row];

    }
    if (indexPath.row==titleArr.count) {
        labTitle.text = @"计划变更原因";
    }
    labTitle.font=[UIFont systemFontOfSize:14];
    [labTitle sizeToFit];
    [cell.contentView addSubview:labTitle];
    
    
    UITextField *content=[[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(labTitle.frame) , CGRectGetMinY(labTitle.frame)-6, kFullScreenSizeWidth-120, 30)];
    content.delegate = self;
    content.font=[UIFont systemFontOfSize:14];
    content.tag=indexPath.row+3000;
    content.placeholder = @"必填";
    if (indexPath.row <=4) {
        content.userInteractionEnabled = false;
    }
    [cell.contentView addSubview:content];
    if (indexPath.row!=2&&indexPath.row<[titleArr count]) {
        //一般情况
        content.text = [self.INFODIC[contentArr[indexPath.row]]outString];
    }
    else
    {
        [content removeFromSuperview];
        UITextView *tv = [[UITextView alloc]initWithFrame:CGRectMake(CGRectGetMinX(labTitle.frame) , CGRectGetMaxY(labTitle.frame), kFullScreenSizeWidth-20, 40)];
        tv.tag = indexPath.row+3000;
        tv.delegate = self;
        if (indexPath.row==titleArr.count) {
            tv.text = @"必填";
            tv.textColor = [UIColor lightGrayColor];
        }
        if (indexPath.row <=2) {
            tv.userInteractionEnabled = false;
        }
        [cell.contentView addSubview:tv];
        if (indexPath.row<5) {
            tv.text = [self.INFODIC[contentArr[indexPath.row]]outString];

        }
    }
     return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 3 || indexPath.row == 4){
        [self.view endEditing:YES];
        indexpath = indexPath;
        if (datePickerView){
            [datePickerView removeFromSuperview];
            datePickerView = nil;
        }
        if (view) {
            [view removeFromSuperview];
        }
        if ([self.view viewWithTag:2090]) {
            [[self.view viewWithTag:2090 ]removeFromSuperview];
        }
        
        view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 120)];
        view.frame = CGRectMake(0, kFullScreenSizeHeght,kFullScreenSizeWidth,200);
        view.backgroundColor=self.view.backgroundColor;
        [self.view addSubview:view];
        
        UIButton *quxiaoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        quxiaoBtn.backgroundColor=[UIColor redColor];
        quxiaoBtn.frame=CGRectMake(20, 5,80, 40);
        quxiaoBtn.clipsToBounds = YES;
        quxiaoBtn.layer.cornerRadius=3.0f;
        
        [quxiaoBtn addTarget:self action:@selector(quxiao) forControlEvents:UIControlEventTouchUpInside];
        [quxiaoBtn setTitle:@"确定" forState:UIControlStateNormal];
        [view addSubview:quxiaoBtn];
        UIButton *cancel=[UIButton buttonWithType:UIButtonTypeCustom];
        cancel.frame=CGRectOffset(quxiaoBtn.frame, kFullScreenSizeWidth-120, 0);
        cancel.clipsToBounds = YES;
        cancel.layer.cornerRadius=3.0f;
        [cancel addTarget:self action:@selector(cancnelapick) forControlEvents:UIControlEventTouchUpInside];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        cancel.backgroundColor=[UIColor redColor];
        [view addSubview:cancel];
        
        datePickerView =[[UIDatePicker alloc] initWithFrame:CGRectZero];
        datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        datePickerView.datePickerMode = UIDatePickerModeDate;
        datePickerView.frame=CGRectMake(0,50,kFullScreenSizeWidth,150);
        [view addSubview:datePickerView];
        [UIView animateWithDuration:0.3 animations:^{
            
            self->view.frame=CGRectMake(0,kFullScreenSizeHeght-200,kFullScreenSizeWidth,200);
            
        } completion:^(BOOL finished) {
            
        }];
        
        
        if (table.indexPathForSelectedRow.row == 2 | table.indexPathForSelectedRow.row == 4 | table.indexPathForSelectedRow.row == 3 ) {
            
            int offset = (5-indexPath.row+2)*75-(kFullScreenSizeHeght - 216.0);//求出键盘顶部与textfield底部大小的距离
            table.contentSize = CGSizeMake(0.0f, 100.0f);
            if (offset<0) {
                table.contentOffset = CGPointMake(0, -offset);
            }
        }
        
    }

}

#pragma mark --textview
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"必填"]) {
        [textView setText:@""];
    }
    textView.textColor = [UIColor blackColor];
}

#pragma mark == btnClick
- (void)cancnelapick{
    if (view) {
        [view removeFromSuperview];
    }
    if (datePickerView) {
        [datePickerView removeFromSuperview];
    }
    table.contentOffset = CGPointMake(0.0f, 0.0f);
}
-(void)quxiao{
    UITableViewCell *cell=[table cellForRowAtIndexPath:indexpath];
    UITextField *text=(UITextField *)[cell.contentView viewWithTag:3000+indexpath.row];
    NSDate *select = [datePickerView date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    text.text=dateAndTime;
    //    [[self.view viewWithTag:2090]removeFromSuperview];
    if (table.indexPathForSelectedRow.row==3) {
        startTime=dateAndTime;
    }
    if (table.indexPathForSelectedRow.row==4) {
        NSString *end=[[[dateAndTime stringByReplacingOccurrencesOfString:@"-" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSString *start=[[[startTime stringByReplacingOccurrencesOfString:@"-" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@":" withString:@""];
        if ([end longLongValue]<[start longLongValue]) {
            [CCUtil showMBProgressHUDLabel:@"结束时间不能小于开始时间" detailLabelText:nil];
            text.text=@"";
        }
    }
    if (view) {
        [view removeFromSuperview];
    }
    if (datePickerView) {
        [datePickerView removeFromSuperview];
    }
    
    //    table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    table.contentOffset = CGPointMake(0.0f, 0.0f);
    [table deselectRowAtIndexPath:table.indexPathForSelectedRow animated:YES];
    
    //    table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
}
//更新计划
-(void)weihu{
    [self.view endEditing:YES];
    
       titleArr=[NSArray arrayWithObjects:@"任务名称:",@"计划名称:",@"计划内容:",@"计划开始时间:",@"计划结束时间:",@"批示情况",nil];
    contentArr=[NSArray arrayWithObjects:@"taskName",@"title",@"planContent",@"planStartTime",@"planEndTime",@"changedDescription",nil];
    
    NSMutableArray *Arr=[NSMutableArray array];
    for (int i=0; i<=5; i++) {
        UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
             id tf =(UITextView *)[cell.contentView viewWithTag:3000+i];
        if ([tf respondsToSelector:@selector(text)]) {
            [Arr addObject:[tf text]];
        }
     }
if ([Arr[5] length]==0||[Arr[5] isEqualToString:@"必填"]) {
    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请填写变更原因"];
    return;
    }
    
    NSDictionary *dic=@{@"id":[self.INFODIC objectForKey:@"id"],@"title":Arr[1],@"planContent":Arr[2],@"planStartTime":Arr[3],@"planEndTime":Arr[4],@"changedDescription":Arr[5]};
    
    
    NSString *final=[CCUtil basedString:updatePlanUrl withDic:dic];
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [requset setRequestMethod:@"GET"];
    [requset setTimeOutSeconds:20];
    [requset startSynchronous];
    NSString *Str=[requset responseString];
    if ([Str rangeOfString:@"true"].location !=NSNotFound) {
        //modi success
        [CCUtil showMBProgressHUDLabel:@"修改成功" detailLabelText:nil];
        [defaults setBool:YES forKey:PLAN_REFRESH];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
  
    
    // }
    
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
}
@end
