//
//  CCMessageViewController.m
//  CCField
//
//  Created by 李付 on 14/10/20.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCMessageViewController.h"
#import "UIScrollView+MJRefresh.h"

@interface CCMessageViewController ()
{
    UIActivityIndicatorView *activity;
    
}
@end

@implementation CCMessageViewController

- (void)viewDidLoad {
//    [super viewDidLoad];
//   
//    self.lableNav.text=@"信息接收";
    jsonArray=[NSArray array];
    NOSize=1;
    tableMessage=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.lableNav.frame)-49) style:UITableViewStylePlain];
    tableMessage.delegate=self;
    tableMessage.dataSource=self;
    tableMessage.backgroundColor = [UIColor clearColor];
     tableMessage.rowHeight=85;
      [self.view addSubview:tableMessage];
    tableMessage.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [tableMessage addFooterWithTarget:self action:@selector(showMore:)];
 
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //网络请求
    NSDictionary *dic=@{@"currentPage": @"1",@"pageSize":@"10"};
    [self beginRequestwithDic:dic];
    
}

-(void)showMore:(UIButton *)sender{
    NOSize++;
    NSString *size=[NSString stringWithFormat:@"%d",NOSize*10];
    NSDictionary *dic=@{@"currentPage": @"1",@"pageSize":size};
    [self beginRequestwithDic:dic];
}

-(void)beginRequestwithDic:(NSDictionary *)dic{
    [CCUtil showMBLoading:nil detailText:@"请稍候..."];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *final=[CCUtil basedString:messageUrl  withDic:dic];
        ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:final]];
        [requset setRequestMethod:@"GET"];
        [requset setTimeOutSeconds:20];
        [requset startSynchronous];
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCUtil hideMBLoading];
            [self->tableMessage footerEndRefreshing];
            NSData *Data=[requset responseData];
            
            if ([Data length]==0) {
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
             [self->tableMessage reloadData];

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
            UILabel *CComent=[[UILabel alloc]initWithFrame:CGRectMake(20,5, kFullScreenSizeWidth-40, 25)];
            CComent.text=[[jsonArray[indexPath.row] objectForKey:@"content"]outString];
            CComent.tag=110;
            CComent.font = [UIFont systemFontOfSize:14];

            CComent.lineBreakMode=NSLineBreakByTruncatingTail;
            
            CComent.textColor=[UIColor blackColor];
            [cell.contentView addSubview:CComent];
            
            UILabel *userCreate=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(CComent.frame),CGRectGetMaxY(CComent.frame)+6,kFullScreenSizeWidth-20, 25)];
            userCreate.text=[NSString stringWithFormat:@"发送人:%@",[jsonArray[indexPath.row] objectForKey:@"sendUser"]];
            userCreate.textColor=[UIColor grayColor];
//            userCreate.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
            userCreate.font = [UIFont systemFontOfSize:12];
            userCreate.tag=111;
            userCreate.lineBreakMode=NSLineBreakByTruncatingTail;
            [cell.contentView addSubview:userCreate];
            
            UILabel *lableTime=[[UILabel alloc]initWithFrame:CGRectOffset(userCreate.frame, 0, 25)];
            lableTime.textColor=[UIColor grayColor];
            lableTime.text=[NSString stringWithFormat:@"时间:%@",[jsonArray[indexPath.row] objectForKey:@"createTime"]];
            lableTime.tag=112;
//            lableTime.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
            lableTime.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:lableTime];
            
            UIView *view=[[UIView alloc]initWithFrame:CGRectMake(5, CGRectGetMinY(userCreate.frame), 10, 10)];
            view.layer.cornerRadius=5.0f;
            view.backgroundColor=[UIColor redColor];
            view.tag=113;
            [cell.contentView addSubview:view];
            if ([jsonArray[indexPath.row][@"isRead"] integerValue]==0) {
                view.backgroundColor=[UIColor redColor];
            }
            else
                view.backgroundColor=[UIColor clearColor];
            
        }
    }
    else  //有值了 就可以重用
    {
        UILabel *lable =(UILabel*)[cell.contentView viewWithTag:110];
        lable.text=[jsonArray[indexPath.row] objectForKey:@"content"];
        lable.lineBreakMode = NSLineBreakByTruncatingTail;
//        [lable sizeToFit];
        UILabel *user =(UILabel*)[cell.contentView viewWithTag:111];
        user.text=[NSString stringWithFormat:@"发送人:%@",[jsonArray[indexPath.row] objectForKey:@"sendUser"]];
        UILabel *time=(UILabel*)[cell.contentView viewWithTag:112];
        time.text=[NSString stringWithFormat:@"时间:%@",[jsonArray[indexPath.row] objectForKey:@"createTime"]];
        
        UIView *view=[cell.contentView viewWithTag:113];
//        view.frame=CGRectMake(kFullScreenSizeWidth-20 , CGRectGetMinY(lable.frame), 10, 10);
        
        if ([jsonArray[indexPath.row][@"isRead"] integerValue]==0) {
            view.backgroundColor=[UIColor redColor];
        }
        else
            view.backgroundColor=[cell backgroundColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    [[cell.contentView viewWithTag:113]setBackgroundColor:[UIColor clearColor]];

    CCNewingsViewController *CCNews=[[CCNewingsViewController alloc]init];
    CCNews.hidesBottomBarWhenPushed = YES;
    CCNews.dataDic=jsonArray[indexPath.row];
    UITableViewCell *Cell=[tableMessage cellForRowAtIndexPath:indexPath];
    [Cell.contentView viewWithTag:113].backgroundColor=[UIColor clearColor];
     [self.navigationController pushViewController:CCNews animated:YES];
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
