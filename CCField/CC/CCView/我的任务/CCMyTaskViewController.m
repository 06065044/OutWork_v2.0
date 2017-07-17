//
//  CCMyTaskViewController.m
//  CCField
//
//  Created by 马伟恒 on 14-10-13.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCMyTaskViewController.h"
#import "CCDetailViewController.h"
#import "UIScrollView+MJRefresh.h"


@interface CCMyTaskViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int NOSize;
    UITableView *table;
    BOOL finish;
    NSMutableDictionary *read_dic;
    UIImageView *red_down_button;
    NSInteger taskStatus;
    NSInteger index;
}
@end

@implementation CCMyTaskViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //UI
    taskStatus = TASK_STATUS_RUN;
    self.lableNav.text=@"我的任务";
    read_dic=[[defaults objectForKey:@"task_readed"] mutableCopy];
    if ([[read_dic allKeys]count]==0) {
        read_dic=[NSMutableDictionary dictionary];
    }
    NOSize=1;
    taskStatus = TASK_STATUS_RUN;
    
    NSArray *buttonTitles = @[@"进行中",@"延时",@"延迟完成",@"已完成"];
    UIView *viewBack = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, 40)];
    viewBack.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:viewBack];
    CGFloat width = kFullScreenSizeWidth/6.5;
    for (int i=0; i<buttonTitles.count; ++i) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0.4*width+1.5*width*i,0, 1.1*width, 40)];
        [btn setTitle:buttonTitles[i] forState:UIControlStateNormal];
        [viewBack addSubview:btn];
        [btn addTarget:self action:@selector(changeStatus:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        btn.tag = 3033+i;
        if (i==0) {
            red_down_button = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(btn.frame), CGRectGetMaxY(btn.frame)-2, CGRectGetWidth(btn.frame), 2)];
            red_down_button.backgroundColor = [UIColor redColor];
            [viewBack addSubview:red_down_button];
        }
    }
    
    responArr=[NSArray array];
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lableNav.frame)+42, kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.lableNav.frame)-42) style:UITableViewStylePlain];
    table.delegate=self;
    table.dataSource=self;
    table.backgroundColor = [UIColor clearColor];
    table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    if ([table respondsToSelector:@selector(setSeparatorInset:)]) {
        [table setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([table respondsToSelector:@selector(setLayoutMargins:)]) {
        [table setLayoutMargins:UIEdgeInsetsZero];
    }

    table.rowHeight=85;
    [table addHeaderWithTarget:self action:@selector(refresh)];
    table.headerRefreshingText = @"正在刷新...";
    [table addFooterWithTarget:self action:@selector(shoWmore:)];
    [self.view addSubview:table];
    [defaults setBool:YES forKey:TASK_REFRESH];
    
}
-(void)refresh{
    NSString *size=[NSString stringWithFormat:@"%d",NOSize*10];
    NSDictionary *dic = @{@"currentPage":@"1",@"taskStatus":@(taskStatus),@"pageSize":size};
    [self beginRequestwithDic:dic];

}
//点击切换状态
-(void)changeStatus:(UIButton *)btn{
    [red_down_button setFrame:CGRectMake(CGRectGetMinX(btn.frame), CGRectGetMaxY(btn.frame)-2, CGRectGetWidth(btn.frame), 2)];
    //请求url
     index = btn.tag -3033;
    //TODO: 进行各个状态的筛选
    NSString *size=[NSString stringWithFormat:@"%d",NOSize*10];
    if (index==0) {
        //进行中
        taskStatus = TASK_STATUS_RUN;//2
    }
    else if(index ==1){
        taskStatus = TASK_STATUS_DONE;//-1
    }
    else if (index ==2){
        taskStatus = TASK_STATUS_DELAYDONE;//4
    }
    else if (index ==3){
        taskStatus = TASk_STATUS_DELAY;//3
    }

    NSDictionary *dic = @{@"currentPage":@"1",@"taskStatus":@(taskStatus),@"pageSize":size};
    [self beginRequestwithDic:dic];
  }
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick event:@"my_task"];
    if ([defaults boolForKey:TASK_REFRESH]) {
        //网络请求
        if (index==0) {
            //进行中
            taskStatus = TASK_STATUS_RUN;//2
        }
        else if(index ==1){
            taskStatus = TASK_STATUS_DONE;//-1
        }
        else if (index ==2){
            taskStatus = TASK_STATUS_DELAYDONE;//4
        }
        else if (index ==3){
            taskStatus = TASk_STATUS_DELAY;//3
        }

 
        NSDictionary *dic=@{@"currentPage": @"1",@"taskStatus":@(taskStatus),@"pageSize":@"10"};
        [self beginRequestwithDic:dic];
    }
}

-(void)shoWmore:(id)sender{
    NOSize++;
    NSString *size=[NSString stringWithFormat:@"%d",NOSize*10];
    NSDictionary *dic=@{@"currentPage":@"1",@"taskStatus":@(taskStatus),@"pageSize":size};
    [self beginRequestwithDic:dic];
    
}
-(void)beginRequestwithDic:(NSDictionary *)dic{
    __block NSDictionary *dic1=dic;
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCUtil showMBLoading:@"正在请求..." detailText:@"请稍候..."];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (![dic1 isKindOfClass:[NSDictionary class]]) {
                dic1=@{@"currentPage": @"1",@"pageSize":@"10",@"taskStatus":@(self->taskStatus)};
                self->finish=YES;
            }
            NSString *final=[CCUtil basedString:myTaskList withDic:dic];
            ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:final]];
            [requset setRequestMethod:@"GET"];
            [requset setTimeOutSeconds:20];
            [requset startSynchronous];
            NSData *Data=[requset responseData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->table headerEndRefreshing];
                [self->table footerEndRefreshing];
                 [CCUtil hideMBLoading];
                if (self->finish) {
                    [self->table headerEndRefreshing];
                }
                if ([Data length]==0) {
                    [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
                    return;
                }
                self->responArr=[[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil]objectForKey:@"result"];
                
                if (self->responArr.count%10!=0&&self->NOSize>1) {
                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"无更多数据"];
                    
                }
                if (self->responArr.count==0&&self->NOSize==1) {
                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"暂无数据"];
                 }
                 [self->table reloadData];
            });
        });
    });
    
    
    
    //reload
    
}
#pragma mark--table datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }

    for (UIView *viewSub in cell.contentView.subviews) {
        [viewSub removeFromSuperview];
    }
    
    /** 调整位置状况，改为三行显示*/
    // big title
    UILabel *Big=[[UILabel alloc]initWithFrame:CGRectMake(20,5,kFullScreenSizeWidth-30, 25)];
    Big.text=[[responArr[indexPath.row] objectForKey:@"title"] outString];
    //    Big.lineBreakMode = UILineBreakModeTailTruncation;
    Big.lineBreakMode = NSLineBreakByTruncatingTail;
    //    [Big sizeToFit];
    Big.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:Big];
    //right
    UILabel *labelRig=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(Big.frame), CGRectGetMaxY(Big.frame), kFullScreenSizeWidth-10, 25)];
    labelRig.text=[NSString stringWithFormat:@"规定完成时间:%@",[responArr[indexPath.row] objectForKey:@"setTime"]];
    labelRig.textColor = [UIColor grayColor];
    labelRig.font=[UIFont systemFontOfSize:12];
    [cell.contentView addSubview:labelRig];
    
    // small
//    NSString *HaveOrNo=[responArr[indexPath.row] objectForKey:@"status"];
//    HaveOrNo=[CCUtil changeWithInt:HaveOrNo];
//    UIColor *textColor=[CCUtil colorByStringCode:HaveOrNo];
    UILabel *labLeft=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(labelRig.frame), CGRectGetMaxY(labelRig.frame), kFullScreenSizeWidth , 25)];
    labLeft.text=[NSString stringWithFormat:@"任务发布人:%@",responArr[indexPath.row][@"pubUser"]];
    labLeft.font=[UIFont systemFontOfSize:12];
    [cell.contentView addSubview:labLeft];
    labLeft.textColor = labelRig.textColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
 
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(5, CGRectGetMinY(labelRig.frame), 10, 10)];
    view.tag=113;
    view.layer.cornerRadius=5.0f;
    [cell.contentView addSubview:view];
    if ([responArr[indexPath.row][@"isRead"] intValue]==0) {
        view.backgroundColor=[UIColor redColor];
        
    }else{
        view.backgroundColor = [UIColor clearColor];
    }
    UIView *lastV  =[[UIView alloc]initWithFrame:CGRectMake(0, 82, kFullScreenSizeWidth, 3)];
    lastV.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    [cell.contentView addSubview:lastV];
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return responArr.count;
}
#pragma mark--delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    [[cell.contentView viewWithTag:113]setBackgroundColor:[UIColor clearColor]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CCDetailViewController *detail=[[CCDetailViewController alloc]init];
    detail.INFODIC=responArr[indexPath.row];
     UITableViewCell *Cell=[tableView cellForRowAtIndexPath:indexPath];
    [[Cell.contentView viewWithTag:113]removeFromSuperview];
    [defaults setBool:NO forKey:TASK_REFRESH];
    [self.navigationController pushViewController:detail animated:YES];
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
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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
