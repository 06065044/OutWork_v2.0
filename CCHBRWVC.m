//
//  CCHBRWVC.m
//  CCField
//
//  Created by 马伟恒 on 14-10-14.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCHBRWVC.h"
#import "UIPopoverListView.h"
#import "ASIFormDataRequest.h"
#import "CCUtil.h"
@interface CCHBRWVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIPopoverListViewDataSource,UIPopoverListViewDelegate,ASIHTTPRequestDelegate>
{
    NSArray *titleArray;
}
@end

@implementation CCHBRWVC

UITableView *table;
static NSString *cellIDENTI=@"cellid";




- (void)viewDidLoad {
    [super viewDidLoad];
//    if ([self.HBDIC objectForKey:@"finishTime"]) {
//        <#statements#>
//    }
    NSLog(@"%@",[self.HBDIC objectForKey:@"finishTime"]);
    NSString *text=@"规定完成时间";
    if ([[self.HBDIC objectForKey:@"status"]isEqualToString:@"3"]) {
        text=@"实际完成时间";
    }
    if ([text isEqualToString:@"规定完成时间"]) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(kFullScreenSizeWidth-50, 22, 40, 40)];
        [button setTitle:@"保存" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(saveTask) forControlEvents:UIControlEventTouchUpInside];
        [self.imageNav addSubview:button];

    }
    
    titleArray=[NSArray arrayWithObjects:@"完成任务状态", text,@"完成任务情况",@"完成任务照片",nil];
    // Do any additional setup after loading the view from its nib.
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)) style:UITableViewStylePlain];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIDENTI];
    table.rowHeight=60;
    table.delegate=self;
    table.dataSource=self;
    table.rowHeight=80;
    table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:table];
}
-(void)saveTask{
    NSLog(@"save");
    NSMutableArray *Arr=[NSMutableArray array];
    for (int i=0; i<2; i++) {
        UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UILabel *lab=(UILabel *)[cell.contentView viewWithTag:3000+i];
        [Arr addObject:lab.text];
    }
    UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UITextField *lab=(UITextField *)[cell.contentView viewWithTag:3002];
    [Arr addObject:lab.text];
    NSString *str=@"3";
    if ([Arr[0]isEqualToString:@"未完成"]) {
        str=@"2";
    }
    NSString *saveUrl=@"http://123.139.56.221:6001/outside/dispatcher/issTask/updateTaskReply";
    NSDictionary *dic=@{@"id":[self.HBDIC objectForKey:@"id"],@"replyContent":Arr[2],@"status":str,@"finishTime":Arr[1]};
    ASIFormDataRequest *requset=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:saveUrl]];
    for (int i=0; i<dic.allKeys.count; i++) {
        [requset setPostValue:[dic objectForKey:dic.allKeys[i]] forKey:dic.allKeys[i]];
    }
    //requset addData:<#(id)#> withFileName:<#(NSString *)#> andContentType:<#(NSString *)#> forKey:<#(NSString *)#>
    [requset startSynchronous];
    NSString *Str=[requset responseString];
    
    
}
#pragma mark--datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:cellIDENTI forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(5, 5, 110, 30)];
    lab.text=titleArray[indexPath.row];
    [cell.contentView addSubview:lab];
    if (indexPath.row==0) {
        UILabel *la1b=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(lab.frame), CGRectGetMaxY(lab.frame), kFullScreenSizeWidth, 30)];
        la1b.text=@"未完成";
        la1b.tag=3000+indexPath.row;
        [cell.contentView addSubview:la1b];
    }
    else if (indexPath.row==1) {
        UILabel *la1b=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(lab.frame), CGRectGetMaxY(lab.frame), kFullScreenSizeWidth, 30)];
        la1b.text=[self.HBDIC objectForKey:@"finishTime"];
        la1b.tag=3000+indexPath.row;
        [cell.contentView addSubview:la1b];
    }
    else if (indexPath.row==2){
        UITextField *textView=[[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMinX(lab.frame), CGRectGetMaxY(lab.frame), kFullScreenSizeWidth, 30)];
        textView.borderStyle=UITextBorderStyleNone;
        textView.tag=3000+indexPath.row;
        textView.returnKeyType=UIReturnKeyDone;
        textView.delegate=self;
        textView.text=[self.HBDIC objectForKey:@"replyContent"];
        [cell.contentView addSubview:textView];

    }
    else{
    
    
    }
    
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
#pragma mark --table delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        [self showList];
    }
}
-(void)showList{
    CGFloat xWidth = self.view.bounds.size.width - 20.0f;
    CGFloat yHeight = 150;
    CGFloat yOffset = (self.view.bounds.size.height - yHeight)/2.0f;
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = FALSE;
    [poplistview setTitle:@"状态选择"];
    [poplistview show];

}
#pragma mark ---textfiled
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark--poplistdatasource
-(UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView cellForIndexPath:(NSIndexPath *)indexPath{
static NSString *identifier=@"cell";
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (indexPath.row==0) {
        cell.textLabel.text=@"未完成";
    }
    if (indexPath.row==1) {
        cell.textLabel.text=@"已完成";
    }
    return cell;
}
-(NSInteger)popoverListView:(UIPopoverListView *)popoverListView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
#pragma mark--delegate
-(CGFloat)popoverListView:(UIPopoverListView *)popoverListView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}
-(void)popoverListView:(UIPopoverListView *)popoverListView didSelectIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s",__func__);
    UITableViewCell *cell=[self tableView:table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (indexPath.row==0) {
        [((UILabel *)[cell.contentView viewWithTag:1024]) setText:@"未完成"];
    }
    else
        [((UILabel *)[cell.contentView viewWithTag:1024]) setText:@"已完成"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
