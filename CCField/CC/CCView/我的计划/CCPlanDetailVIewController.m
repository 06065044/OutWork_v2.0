//
//  CCPlanDetailVIewController.m
//  CCField
//
//  Created by 马伟恒 on 14-10-14.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCPlanDetailVIewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"
NSArray *titleArr;
NSArray *contentArr;
UITableView *table;
UIDatePicker *datePickerView;
static NSString *cellIDENTI=@"cellid";
BOOL weihu;
static NSString *updateUrlPlan=@"http://123.139.56.221:6001/outside/dispatcher/workplan/updateWorkPlan";


@implementation CCPlanDetailVIewController

-(void)viewDidLoad{
    [super viewDidLoad];
    weihu=NO;
    titleArr=[NSArray arrayWithObjects:@"计划标题",@"计划内容",@"上报时间",@"开始时间",@"结束时间",@"批示情况", nil];
    contentArr=[NSArray arrayWithObjects:@"title",@"planContent",@"planCreateTime",@"planStartTime",@"planEndTime",@"planAppCount",nil];

    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(kFullScreenSizeWidth-50, 22, 40, 40)];
    [button setTitle:@"维护" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(weihu) forControlEvents:UIControlEventTouchUpInside];
    [self.imageNav addSubview:button];
    button.tag=234;
    
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)) style:UITableViewStylePlain];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIDENTI];
    table.delegate=self;
    table.dataSource=self;
    table.rowHeight=60;
    table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    table.userInteractionEnabled=NO;
    [self.view addSubview:table];

}
-(void)weihu{
    if (!weihu) {
        titleArr=[NSArray arrayWithObjects:@"计划标题",@"计划内容",@"创建时间",@"开始时间",@"结束时间", nil];
        contentArr=[NSArray arrayWithObjects:@"title",@"planContent",@"planCreateTime",@"planStartTime",@"planEndTime",nil];
        table.userInteractionEnabled=YES;
        [table reloadData];
        weihu=YES;
        [(UIButton *)[self.imageNav viewWithTag:234] setTitle:@"保存" forState:UIControlStateNormal];
    }
    else{
        
        
        
        titleArr=[NSArray arrayWithObjects:@"计划标题",@"计划内容",@"上报时间",@"开始时间",@"结束时间",@"批示情况", nil];
        contentArr=[NSArray arrayWithObjects:@"title",@"planContent",@"planCreateTime",@"planStartTime",@"planEndTime",@"planAppCount",nil];
        
        NSMutableArray *Arr=[NSMutableArray array];
        for (int i=0; i<5; i++) {
            UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            UITextField *tf=(UITextField *)[cell.contentView viewWithTag:3000+i];
            [Arr addObject:tf.text];
        }

        
        
        NSDictionary *dic=@{@"id":[self.INFODIC objectForKey:@"id"],@"title":Arr[0],@"planCreateTime":Arr[2],@"planStartTime":Arr[3],@"planEndTime":Arr[4],@"planContent":Arr[1]};
        
        ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:updateUrlPlan]];
   
        NSString *final=[CCUtil basedString:updateUrlPlan withDic:dic];
        requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [requset setRequestMethod:@"GET"];
        [requset startSynchronous];
        NSString *Str=[requset responseString];
        if ([Str rangeOfString:@"success"].location!=NSNotFound) {
            //modi success
        }
        
        
        
        [table reloadData];
        table.userInteractionEnabled=NO;
        weihu=NO;
        [(UIButton *)[self.imageNav viewWithTag:234] setTitle:@"维护" forState:UIControlStateNormal];

    }
 
}
#pragma mark===table data
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:cellIDENTI forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UILabel *labTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, kFullScreenSizeWidth, 30)];
    labTitle.text=titleArr[indexPath.row];
    labTitle.font=[UIFont boldSystemFontOfSize:16];
    [cell.contentView addSubview:labTitle];
    
    UITextField *content=[[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMinX(labTitle.frame), CGRectGetMaxY(labTitle.frame), kFullScreenSizeWidth-20, 30)];
    content.font=[UIFont systemFontOfSize:13];
    content.tag=indexPath.row+3000;
    if (indexPath.row==1) {
        if ([[self.INFODIC objectForKey:contentArr[indexPath.row]]isKindOfClass:[NSNull class]]) {
            content.text=@"";
        }else
        content.text=[self.INFODIC objectForKey:contentArr[indexPath.row]];

        labTitle.frame=CGRectOffset(labTitle.frame, 0, -5);
        content.frame=CGRectOffset(content.frame, 0, -10);
        content.frame=CGRectInset(content.frame, 0, -10);
    }
    else if(indexPath.row==2){
        content.text=[self.INFODIC objectForKey:contentArr[indexPath.row]];
        content.userInteractionEnabled=NO;

        if ([titleArr[2]isEqualToString:@"创建时间"]) {
            content.textColor=[UIColor grayColor];
        }
    }
    else if (indexPath.row==5){

        if ([[self.INFODIC objectForKey:contentArr[indexPath.row]]isKindOfClass:[NSNull class]]) {
            content.text=@"0";
        }
        else
        content.text=[NSString stringWithFormat:@"%@",[self.INFODIC objectForKey:contentArr[indexPath.row]]];
    
        }
    else{
        content.text=[self.INFODIC objectForKey:contentArr[indexPath.row]];
        if (indexPath.row>0) {
            content.userInteractionEnabled=NO;
        }
      }
    
    
    [cell.contentView addSubview:content];
    
    if (indexPath.row==5) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(kFullScreenSizeWidth-120, 10, 100, 40);
        button.backgroundColor=[UIColor redColor];
        [button setTitle:@"点击查看" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cell.contentView addSubview:button];
        [button addTarget:self action:@selector(checkreply) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count;
}
-(void)checkreply{


}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%d",indexPath.row);
    if (indexPath.row==3||indexPath.row==4) {
        datePickerView =[[UIDatePicker alloc] initWithFrame:CGRectZero];
        datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
        datePickerView.frame=CGRectMake(10, kFullScreenSizeHeght/2+80, 300, 200);
        [self.view addSubview:datePickerView];
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(CGRectGetMinX(datePickerView.frame)+90, CGRectGetMaxY(datePickerView.frame)-5, 120, 30)];
        button.tag=2090;
        button.backgroundColor=[UIColor redColor];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(suretime) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}
-(void)suretime{
        UITableViewCell *cell=[self tableView:table cellForRowAtIndexPath:table.indexPathForSelectedRow ];
        UITextField *text=(UITextField *)[cell.contentView viewWithTag:3000+table.indexPathForSelectedRow.row];
        NSDate *select = [datePickerView date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *dateAndTime =  [dateFormatter stringFromDate:select];
        text.text=dateAndTime;
        [[self.view viewWithTag:2090]removeFromSuperview];
        [datePickerView removeFromSuperview];
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
@end
