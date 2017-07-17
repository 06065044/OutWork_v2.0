//
//  CCNoticeViewController.m
//  CCField
//
//  Created by 李付 on 14-10-16.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCNoticeViewController.h"
#import "UIScrollView+MJRefresh.h"

@interface CCNoticeViewController ()
{
    UIActivityIndicatorView *activity;
}
@end

@implementation CCNoticeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.lableNav.text=@"系统公告";
     NOSize=1;
    jsonArray=[NSArray array];
    tableNotice=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.lableNav.frame)) style:UITableViewStylePlain];
    tableNotice.delegate=self;
    tableNotice.dataSource=self;
//    tableNotice.backgroundColor = [UIColor clearColor];

    tableNotice.rowHeight=80;
    tableNotice.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:tableNotice];
    [tableNotice addFooterWithTarget:self action:@selector(shwMore:)];
      //网络请求
    NSDictionary *dic=@{@"currentPage": @"1",@"pageSize":@"10"};
    [self beginRequestwithDic:dic];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick event:@"system_notice"];
}
 
/*
 *加载更多
 */
-(void)shwMore:(id)sender{
    NOSize++;
    NSString *size=[NSString stringWithFormat:@"%d",NOSize*10];
    NSDictionary *dic=@{@"currentPage":@"1",@"pageSize":size};
    [self beginRequestwithDic:dic];
}
-(void)beginRequestwithDic:(NSDictionary *)dic{
         [CCUtil showMBLoading:@"正在加载..." detailText:@"请稍候..."];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *final=[CCUtil basedString:noticeUrl withDic:dic];
            ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:final]];
            [requset setRequestMethod:@"GET"];
            [requset setTimeOutSeconds:20];
            [requset startSynchronous];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *Data=[requset responseData];
                [CCUtil hideMBLoading];
                [self->tableNotice footerEndRefreshing];
                [self->tableNotice headerEndRefreshing];
                if (Data.length==0) {
                    self->tableNotice.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
                    [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
                    return;
                }
                self->jsonArray=[[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil]objectForKey:@"result"];
                if (self->jsonArray.count%10!=0&&self->NOSize>1) {
                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"无更多数据"];
                }
                if (self->jsonArray.count==0&&self->NOSize==1) {
                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"暂无数据"];
                 }
                [self->tableNotice reloadData];

            });
        });
        
  
   
    }

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return jsonArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {  //没有重用
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if ([jsonArray count]!=0) {
            UILabel *tiitle=[[UILabel alloc]initWithFrame:CGRectMake(20,5, kFullScreenSizeWidth-40, 25)];
            tiitle.text=[[jsonArray[indexPath.row] objectForKey:@"title"]outString];
            tiitle.tag=110;
            tiitle.lineBreakMode=NSLineBreakByTruncatingTail;
            tiitle.font = [UIFont systemFontOfSize:14];
            tiitle.textColor=[UIColor blackColor];
            [cell.contentView addSubview:tiitle];
            
            UILabel *userCreate=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(tiitle.frame),CGRectGetMaxY(tiitle.frame)+4,kFullScreenSizeWidth-100, 25)];
            userCreate.text=[NSString stringWithFormat:@"发布人:%@",[jsonArray[indexPath.row] objectForKey:@"createUser"]];
            userCreate.textColor=[UIColor grayColor];
//            userCreate.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
            userCreate.font = [UIFont systemFontOfSize:12];
            userCreate.tag=111;
            [cell.contentView addSubview:userCreate];
            
            UILabel *lableTime=[[UILabel alloc]initWithFrame:CGRectOffset(userCreate.frame, 0, 25)];
            lableTime.textColor=[UIColor grayColor];
            lableTime.text=[NSString stringWithFormat:@"发布时间:%@",[jsonArray[indexPath.row] objectForKey:@"createTime"]];
            lableTime.tag=112;
//            lableTime.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
            lableTime.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:lableTime];
            
                UIView *view=[[UIView alloc]initWithFrame:CGRectMake(5 , CGRectGetMinY(userCreate.frame), 10, 10)];
                view.layer.cornerRadius=5.0f;
                view.backgroundColor=[UIColor redColor];
                view.tag=113;
                [cell.contentView addSubview:view];
            if ([jsonArray[indexPath.row][@"isRead"] integerValue]==0) {
                view.backgroundColor=[UIColor redColor];
            
            }
            else{
                view.backgroundColor=[UIColor clearColor];

            }

            
        }
    }
    else  //有值了 就可以重用
    {
        UILabel *lable =(UILabel*)[cell.contentView viewWithTag:110];
        lable.text=[jsonArray[indexPath.row] objectForKey:@"title"];
        lable.lineBreakMode = NSLineBreakByTruncatingTail;
//        [lable sizeToFit];
        UILabel *user =(UILabel*)[cell.contentView viewWithTag:111];
        user.text=[NSString stringWithFormat:@"发布人:%@",[jsonArray[indexPath.row] objectForKey:@"createUser"]];
        UILabel *time=(UILabel*)[cell.contentView viewWithTag:112];
        time.text=[NSString stringWithFormat:@"发布时间:%@",[jsonArray[indexPath.row] objectForKey:@"createTime"]];

        UIView *view=[cell.contentView viewWithTag:113];
        view.frame= CGRectMake(MIN(CGRectGetMaxX(lable.frame), 310) , CGRectGetMinY(lable.frame), 10, 10);

        if ([jsonArray[indexPath.row][@"isRead"] integerValue]==0) {
            view.backgroundColor=[UIColor redColor];
        }
        else
            view.backgroundColor=[UIColor clearColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    [[cell.contentView viewWithTag:113]setBackgroundColor:[UIColor clearColor]];
     CCPubilshViewController *CCPublish=[[CCPubilshViewController alloc]init];
    CCPublish.hidesBottomBarWhenPushed = YES;
    CCPublish.dataDic=jsonArray[indexPath.row];
    UITableViewCell *Cell=[tableView cellForRowAtIndexPath:indexPath];
    [Cell.contentView viewWithTag:113].backgroundColor=[UIColor clearColor];
     [self.navigationController pushViewController:CCPublish animated:YES];
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
@end
