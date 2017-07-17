//
//  CCPLANSViewController.m
//  CCField
//
//  Created by 马伟恒 on 14/10/27.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCPLANSViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"
#import "CCPLANDetialViewController.h"
#import "CCAddPlanViewController.h"
#import "UIScrollView+MJRefresh.h"
#import "MJRefreshHeaderView.h"
#import <objc/runtime.h>
#import "NSObject+CC0utString.h"
@interface CCPLANSViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *resultArr;
    UITableView *table;
    int NOSize;
    NSString *pages;
    NSMutableDictionary *read_dic;
    BOOL refresh;
    UIImageView *red_down_igv;
    NSMutableArray * hiddenOrNOArray;
}
@end

@implementation CCPLANSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //TODO: 和section等长的判断是否折叠的数组
    hiddenOrNOArray = [NSMutableArray array];
    //上面的button切换
    UIView *viewDown = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, 40)];
    viewDown.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:viewDown];
    NSArray *arr = @[@"进行中",@"已完成"];
    CGFloat Button_Width = kFullScreenSizeWidth/2.0;
    for (int i=0; i<arr.count; ++i) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(Button_Width*i, 0, Button_Width, 40)];
        [button setTitle:arr[i] forState:UIControlStateNormal];
        [button setTitleColor:self.imageNav.backgroundColor forState:UIControlStateNormal];
         if (i==1) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         }
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.tag = 434+i;
        [viewDown addSubview:button];
        [button addTarget:self action:@selector(changeStatus:) forControlEvents:UIControlEventTouchUpInside];
        if (i==0) {
            red_down_igv = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(button.frame), CGRectGetMaxY(button.frame), Button_Width, 2)];
            red_down_igv.backgroundColor = [UIColor redColor];
            [viewDown addSubview:red_down_igv];
        }
        
    }
    self.lableNav.text=@"计划安排";
    //
    read_dic=[[defaults objectForKey:@"plan_readed"] mutableCopy];
    if ([[read_dic allKeys]count]==0) {
        read_dic=[NSMutableDictionary dictionary];
    }
    resultArr=[NSMutableArray array];
    NOSize=1;
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame)+50, kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)-42)];
    table.delegate=self;
    table.dataSource=self;
    table.backgroundColor = [UIColor clearColor];
    table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    table.rowHeight=50;
    table.sectionFooterHeight = 1;
    if ([table respondsToSelector:@selector(setSeparatorInset:)]) {
        [table setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([table respondsToSelector:@selector(setLayoutMargins:)]) {
        [table setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //    table.tableFooterView=({
    //        UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 50)];
    //        view.backgroundColor=RGBA(240, 242, 244, 1);
    //        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    //        button.frame=CGRectMake(10, 10, kFullScreenSizeWidth-20, 40);
    //        [button setTitle:@"点击加载更多...." forState:UIControlStateNormal];
    //        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //
    //        [button addTarget:self action:@selector(shoWmore:) forControlEvents:UIControlEventTouchUpInside];
    //        [view addSubview:button];
    //
    //        view;
    //    });
    [self.view addSubview:table];
    
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
//    [table addHeaderWithTarget:self action:@selector(beginRequset1)];
//    //#warning 自动刷新(一进入程序就下拉刷新)
//    //    [table headerBeginRefreshing];
//    
//    
//    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
//    //    [table addFooterWithTarget:self action:@selector(footerRereshing)];
//    
//    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
//    //    self.tableView.headerPullToRefreshText = @"下拉可以刷新了";
//    //    self.tableView.headerReleaseToRefreshText = @"松开马上刷新了";
//    table.headerRefreshingText = @"正在刷新...";
    //
    //    self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
    //    self.tableView.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    //    self.tableView.footerRefreshingText = @"MJ哥正在帮你加载中,不客气";
    //    [self beginRequset];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(kFullScreenSizeWidth-48, 22, 40, 40);
    [button setTitle:@"添加" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ADDPLAN:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageNav addSubview:button];
    [defaults setBool:YES forKey:PLAN_REFRESH];
}
/**
 *  切换状态按钮
 */
-(void)changeStatus:(UIButton *)button{
    UIButton *btnOther = nil;
    if (button.tag == 434) {
         btnOther = [button.superview viewWithTag:435];
     }
    else
        btnOther = [button.superview viewWithTag:434];
    
    [button setTitleColor:self.imageNav.backgroundColor forState:UIControlStateNormal];
    [btnOther setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    red_down_igv.frame = CGRectMake(CGRectGetMinX(button.frame), CGRectGetMaxY(button.frame)-2, CGRectGetWidth(button.frame), 2);
    NSInteger index = button.tag - 434;
    NSString *StrNo=[NSString stringWithFormat:@"%d",10*self->NOSize];
    NSDictionary *dic=@{@"currentPage": @"1",@"pageSize":StrNo,@"status":@(index)};
    [self beginRequset:dic];
    
}
#pragma mark -加载更多
-(void)shoWmore:(id)sender{
    NOSize++;
    NSString *StrNo=[NSString stringWithFormat:@"%d",10*self->NOSize];
    NSDictionary *dic=@{@"currentPage": @"1",@"pageSize":StrNo};
    [self beginRequset:dic];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick event:@"my_plan"];
    if ([defaults boolForKey:PLAN_REFRESH]) {
        NSString *StrNo=[NSString stringWithFormat:@"%d",10*self->NOSize];
        NSDictionary *dic=@{@"currentPage": @"1",@"pageSize":StrNo,@"status":@(0)};
        red_down_igv.frame = CGRectMake(0, CGRectGetMinY(red_down_igv.frame), CGRectGetWidth(red_down_igv.frame), CGRectGetHeight(red_down_igv.frame));
        [self beginRequset:dic];
    }
}

//-(void)viewDidAppear:(BOOL)animated{
//    [table headerEndRefreshing];
//}
-(void)beginRequset1{
    NOSize=1;
    NSString *StrNo=[NSString stringWithFormat:@"%d",10*self->NOSize];
    
    NSDictionary *dic=@{@"currentPage": @"1",@"pageSize":StrNo,@"status":@(0)};
    [self beginRequset:dic];
    
}
-(void)beginRequset:(NSDictionary *)dic{
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCUtil showMBLoading:@"正在请求..." detailText:@"请稍候..."];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSString *final=[CCUtil basedString:queryPlanUrl withDic:dic];
            ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            [requset setRequestMethod:@"GET"];
            [requset setTimeOutSeconds:20];
            [requset startSynchronous];
            dispatch_async(dispatch_get_main_queue(), ^{
                [CCUtil hideMBLoading];
                [self->table headerEndRefreshing];
                [self->table footerEndRefreshing];
                NSData *Data=[requset responseData];
                
                if ([Data length]==0) {
                    self->table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
                    [CCUtil showMBProgressHUDLabel:@"无返回数据" detailLabelText:nil];
                    return;
                }
                NSArray *rese=[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
                [self->resultArr removeAllObjects];
                [self->resultArr addObjectsFromArray:rese];
                [self->resultArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self->hiddenOrNOArray addObject:@"0"];
                }];
                if (self->resultArr.count%10!=0&&self->NOSize>1) {
                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"无更多数据"];
                }
                if (self->resultArr.count==0&&self->NOSize==1) {
                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"暂无数据"];
                }
                [self->table reloadData];
            });
            
        });
    });
}
-(void)ADDPLAN:(id)sender{
    //
    CCAddPlanViewController *add=[[CCAddPlanViewController alloc]init];
    [self.navigationController pushViewController:add animated:YES];
    return;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *addAction =[UIAlertAction actionWithTitle:@"添加计划" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *planReply1 = [UIAlertAction actionWithTitle:@"计划批示" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:addAction];
    [alertVC addAction:planReply1];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}
#pragma mark--table delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return resultArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID=@"cellID";
    UITableViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!Cell) {
        Cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        Cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"details"]];
    }
    if ([Cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [Cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([Cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [Cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
    
    for (UIView *viewA in Cell.contentView.subviews) {
        [viewA removeFromSuperview];
    }
    /** 调整布局，改为三行显示*/
    NSDictionary *dic = resultArr[indexPath.section][@"plans"][indexPath.row];
    UILabel *labTitle=[[UILabel alloc]initWithFrame:CGRectMake(25, 0, kFullScreenSizeWidth-20, 25)];
    labTitle.text=[@"计划名称:" stringByAppendingString:[[dic objectForKey:@"title"] outString]];
    //    [labTitle sizeToFit];
    labTitle.font = [UIFont systemFontOfSize:14];
    [Cell.contentView addSubview:labTitle];
    
    UILabel *startTime=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(labTitle.frame), CGRectGetMaxY(labTitle.frame), kFullScreenSizeWidth-120, 20)];
    startTime.text=[@"计划结束时间:" stringByAppendingString:[[dic objectForKey:@"planEndTime"]outString]];
    startTime.textColor=[UIColor grayColor];
    //    startTime.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
    startTime.font = [UIFont systemFontOfSize:12];
    [Cell.contentView addSubview:startTime];
    //
    //    if (![defaults boolForKey:resultArr[indexPath.row][@"id"]]) {
    //        UIView *view=[[UIView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth-20, CGRectGetMinY(labTitle.frame)+5, 10, 10)];
    //        view.tag=113;
    //        view.layer.cornerRadius=5.0f;
    //        view.backgroundColor=[UIColor redColor];
    //        [Cell.contentView addSubview:view];
    //
    //    }
    
    return Cell;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([hiddenOrNOArray[section] isEqualToString:@"1"]) {
        return 0;
    }
    return [resultArr[section][@"plans"] count];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 50)];
    sectionView.backgroundColor = [UIColor whiteColor];
    [sectionView setTag:section];
    
    UIImageView *headImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 13, 24, 24)];
    headImage.image = [UIImage imageNamed:@"task"];
    [sectionView addSubview:headImage];
    
    UILabel *taskName = [[UILabel alloc]initWithFrame:CGRectMake(30, 15, kFullScreenSizeWidth-50, 25)];
    taskName.text = [NSString stringWithFormat:@"任务名称:%@",[resultArr[section][@"taskName"]outString]];
    taskName.font = [UIFont boldSystemFontOfSize:15];
    [sectionView addSubview:taskName];
    
    
    UITapGestureRecognizer *hidden = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenOrNo:)];
    [sectionView addGestureRecognizer:hidden];
    
    UIView *down_view = [[UIView alloc]initWithFrame:CGRectMake(0, 49, kFullScreenSizeWidth, 1)];
    down_view.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    [sectionView addSubview:down_view];
    
    
    UIView *upView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 1)];
    upView.backgroundColor = down_view.backgroundColor;
    [sectionView addSubview:upView];
    
    
    //箭头
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth-30, 15, 17, 17)];
    if ([hiddenOrNOArray[section] isEqualToString:@"0"]) {
        arrow.image = [UIImage imageNamed:@"arrow_down"];
    }
    else
        arrow.image = [UIImage imageNamed:@"arrow_up"];
    [sectionView addSubview:arrow];
    
    return sectionView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CCPLANDetialViewController *detial=[[CCPLANDetialViewController alloc]init];
    detial.INFODIC=resultArr[indexPath.section][@"plans"][indexPath.row];
    //    [defaults setBool:YES forKey:resultArr[indexPath.row][@"id"]];
    UITableViewCell *Cell=[tableView cellForRowAtIndexPath:indexPath];
    [[Cell.contentView viewWithTag:113]removeFromSuperview];
    
    [defaults setBool:NO forKey:PLAN_REFRESH];
    [self.navigationController pushViewController:detial animated:YES];
    
}
#pragma mark -- hidden Method
-(void)hiddenOrNo:(UIGestureRecognizer *)regonize{
    UIView *viewTap = regonize.view;
    NSInteger index = viewTap.tag;
    if ([hiddenOrNOArray[index] isEqualToString:@"0"]) {
        hiddenOrNOArray[index] = @"1";
    }
    else{
        hiddenOrNOArray[index] = @"0";
    }
    [table reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
    
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
