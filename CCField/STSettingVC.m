//
//  STSettingVC.m
//  FindHelperOC
//
//  Created by 马伟恒 on 16/6/17.
//  Copyright © 2016年 马伟恒. All rights reserved.
//

#import "STSettingVC.h"
#import "CCAccountViewController.h"
#import "CCSettingViewController.h"
#import "CCLoginViewController.h"
#import "STIntrouduceVC.h"
#import "CSDataService.h"
#import "LocationShareModel.h"
#import "STMainVC.h"
#import "CCNavigationController.h"
#import "STTabbarVC.h"
@implementation STSettingVC
  NSString *reuser = @"reuser";
    NSArray *titles;
-(void)viewDidLoad{
    [super viewDidLoad];
    titles=@[@"账户信息",@"系统设置",@"功能简介"];
    self.lableNav.text = @"我的";
    UITableView *_table = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame)+5, kFullScreenSizeWidth,titles.count*40 )];
    _table.delegate =self;
    _table.dataSource=self;
    _table.rowHeight = 40;
    _table.backgroundColor = [UIColor clearColor];

    _table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:_table];
    if ([_table respondsToSelector:@selector(setSeparatorInset:)]) {
        [_table setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_table respondsToSelector:@selector(setLayoutMargins:)]) {
        [_table setLayoutMargins:UIEdgeInsetsZero];
    }
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:reuser];
  
    [self.buttonNav removeFromSuperview];
    
    UIButton *signOut = [UIButton buttonWithType:UIButtonTypeCustom];
    signOut.frame = CGRectMake(20, kFullScreenSizeHeght-120, kFullScreenSizeWidth-40, 40);
    [signOut setBackgroundColor:self.imageNav.backgroundColor];
    signOut.layer.cornerRadius = 5.0;
    [signOut setTitle:@"退出登录" forState:UIControlStateNormal];
    [signOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signOut addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signOut];
}
-(void)signOut{
    //TODO:点击退出，包括ui的退出和后台的计时器也要一起停止
   
    [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"clickOut"];
    LocationShareModel *shareModel = [LocationShareModel sharedModel];
    [shareModel.timer invalidate];
    [shareModel.delay10Seconds invalidate];
    [shareModel.fiveMinutesTimer invalidate];
    CCNavigationController *main = (CCNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
      STTabbarVC  *tab1 = (STTabbarVC*)main.viewControllers[0];
    STMainVC *main1 =(STMainVC *)([(UINavigationController *) tab1.viewControllers[1] viewControllers][0]);
    [main1.locationUpdateTimer invalidate];
     [CSDataService requestWithURL:LogOutURL params:nil httpMethod:@"GET" block:^(id result) {
        
    }];
    [defaults setBool:NO forKey:@"autoLogin"];
    [UIApplication sharedApplication].keyWindow.rootViewController = [[CCLoginViewController alloc]init];
}
#pragma mark =table datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titles.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuser forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
     
     cell.textLabel.text = titles[indexPath.row];
    return cell;
}
#pragma mark == table delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            // 账户信息
            CCAccountViewController * acount = [[CCAccountViewController alloc]init];
            acount.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:acount animated:YES];
        }
            break;
        case 1:
            //系统设置
        {
            CCSettingViewController *set = [[CCSettingViewController alloc]init];
            set.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:set animated:YES];
        
        }
            break;
        case 2:
        {
            STIntrouduceVC *intro = [[STIntrouduceVC alloc]init];
            intro.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:intro animated:YES];
        }
            break;
        default:
            break;
    }

}

@end
