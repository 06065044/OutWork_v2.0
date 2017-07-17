//
//  CCWQViewController.m
//  CCField
//
//  Created by 马伟恒 on 14-10-15.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCWQViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"
#import "CCWQDetailViewController.h"
#import "CCADDWQViewController.h"
#import "MJRefreshHeaderView.h"
#import "UIScrollView+MJRefresh.h"
#import "STTeamCarVC.h"

@interface CCWQViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIActivityIndicatorView *activity;
}
@end

@implementation CCWQViewController{
UITableView *table;
    int pages;
int currentPages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.lableNav.text=@"外勤工作";
    
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame))];
    table.delegate=self;
    table.dataSource=self;
    table.rowHeight=75;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [table addHeaderWithTarget:self action:@selector(beginRequset1)];
    table.backgroundColor = [UIColor clearColor];
//#warning 自动刷新(一进入程序就下拉刷新)
  //  [table headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
//    [table addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
//    self.tableView.headerPullToRefreshText = @"下拉可以刷新了";
//    self.tableView.headerReleaseToRefreshText = @"松开马上刷新了";
    table.headerRefreshingText = @"正在刷新...";
//    
//    self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
//    self.tableView.footerReleaseToRefreshText = @"松开马上加载更多数据了";
//    self.tableView.footerRefreshingText = @"MJ哥正在帮你加载中,不客气";

    [self.view addSubview:table];
  
    [self beginRequset1];
     UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(kFullScreenSizeWidth-48, 22, 40, 40);
    [button setTitle:@"更多" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ADDWQPLAN:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageNav addSubview:button];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick event:@"my_outside"];
}
-(void)shoWmore:(UIButton *)sender{
//    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];//指定进度轮的大小
//    
//    [activity setCenter:CGPointMake(kFullScreenSizeWidth/2-90, kFullScreenSizeHeght-20)];//指定进度轮中心点
//    
//    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];//设置进度轮显示类型
//    [activity startAnimating];
//    
//    [self.view addSubview:activity];
//    [self.view bringSubviewToFront:activity];
    
   
    currentPages++;
    [self beginRequset];
    
}
-(void)beginRequset1{
    currentPages=1;
    [self beginRequset];
}

-(void)ADDWQPLAN:(id)sender{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //action我的
    UIAlertAction *carMine = [UIAlertAction actionWithTitle:@"添加外勤" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CCADDWQViewController *addwq=[[CCADDWQViewController alloc]init];
        [addwq setBlock:^{
            [self beginRequset1];
        }];
        [self.navigationController pushViewController:addwq animated:YES];
        
    }];
    UIAlertAction *actionTeam = [UIAlertAction actionWithTitle:@"团队外勤" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        STTeamCarVC *car = [[STTeamCarVC alloc]init];
        car.urlType = Type_Url_WQ;
        [self.navigationController pushViewController:car animated:YES];
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:carMine];
    [alertVC addAction:actionTeam];
    [alertVC addAction:cancel];
    
    [self presentViewController:alertVC animated:YES completion:^{
   
     
    }];
}
-(void)beginRequset{
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCUtil showMBLoading:@"正在加载..." detailText:@"请稍候..."];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
             NSString *StrNo=[NSString stringWithFormat:@"%d",self->currentPages];
            NSDictionary *dic=@{@"currentPage":@"1",@"pages":StrNo,@"owner":@"0"};
            
            NSString *final=[CCUtil basedString:workRecordURL withDic:dic];
             ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            [requset setRequestMethod:@"GET"];
            [requset setTimeOutSeconds:20];
            [requset setUseCookiePersistence : YES ];
            [requset setShouldAttemptPersistentConnection:NO];
            [requset startSynchronous];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *Data=[requset responseData];
                if (self->activity) {
                    [self->activity stopAnimating];
                    [self->activity removeFromSuperview];
                }
                [CCUtil hideMBLoading];
                [self->table headerEndRefreshing];
                [self->table footerEndRefreshing];
                if ([Data length]==0) {
                    self->table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
                    
                    [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
                    return;
                }
                 self->responArr=[[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil]objectForKey:@"result"];
                if (self->responArr.count%10!=0&&self->currentPages>1) {
                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"无更多数据"];
                    
                }
                if (self->responArr.count==0&&self->currentPages==1) {
                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"暂无数据"];
                 }
                [self->table performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                
                

            });
        });
        
    });
    
    
   }
#pragma mark--table datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID=@"cellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    for (UIView *viewSub in cell.contentView.subviews) {
        [viewSub removeFromSuperview];
    }
    /**修改外勤工作样式，改为三行显示*/
    UIView *upGray = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 5)];
    upGray.backgroundColor =self.view.backgroundColor;
    [cell.contentView addSubview:upGray];
    // big title
    UILabel *Big=[[UILabel alloc]initWithFrame:CGRectMake(20,5,kFullScreenSizeWidth-20, 30)];
//    Big.text=[[responArr[indexPath.row] objectForKey:@"workTitle"] isKindOfClass:[NSNull class]]?@"":[responArr[indexPath.row] objectForKey:@"workTitle"] ;
      Big.text=[[responArr[indexPath.row] objectForKey:@"workTitle"]outString] ;
    Big.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:Big];
    
    //rightlocation
    UILabel *labelRig=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(Big.frame), CGRectGetMaxY(Big.frame)+2, kFullScreenSizeWidth-170, 20)];
    NSString *str1=[NSString stringWithFormat:@"%@",[[responArr[indexPath.row] objectForKey:@"workLocation"] isKindOfClass:[NSNull class]]?@"":[responArr[indexPath.row] objectForKey:@"workLocation"]];
    labelRig.text = [@"工作地点:" stringByAppendingString:str1];

//    labelRig.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
    labelRig.font = [UIFont systemFontOfSize:12];
    labelRig.textColor=[UIColor grayColor];
    [cell.contentView addSubview:labelRig];

    // small
    UILabel *labLeft=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(labelRig.frame), CGRectGetMaxY(labelRig.frame), 200, 20)];
    NSString *str2=[NSString stringWithFormat:@"%@",[[responArr[indexPath.row] objectForKey:@"createTime"] isKindOfClass:[NSNull class]]?@"":[responArr[indexPath.row] objectForKey:@"createTime"]];
    labLeft.text = [@"工作时间:" stringByAppendingString:str2];
    labLeft.textColor=[UIColor grayColor];
//  labLeft.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
    labLeft.font = [UIFont systemFontOfSize:12];
    [cell.contentView addSubview:labLeft];
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return responArr.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CCWQDetailViewController *detial=[[CCWQDetailViewController alloc]init];
    detial.INFODIC=[responArr objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detial animated:YES];

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
