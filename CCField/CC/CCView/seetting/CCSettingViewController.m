//
//  CCSettingViewController.m
//  CCField
//
//  Created by 李付 on 14-10-15.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCSettingViewController.h"
#import "CSDataService.h"
#import "LocationShareModel.h"
#import "CCMainViewController.h"
#import "CCNavigationController.h"
#import "STCheckUpdate.h"
#import "STContactUSVC.h"
#import "CCImportViewController.h"
#import "STBaseSettingVC.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"

@interface CCSettingViewController ()

@end

@implementation CCSettingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.lableNav.text=@"系统设置";
    
    //name=@[@"基础设置",@"版本更新",@"联系我们"];
    name=@[@"基础设置",@"联系我们"];//审核删除
    
    
    tableSetting=[[UITableView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(self.imageNav.frame), 320, 270) style:UITableViewStylePlain];
    //tableSetting.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableSetting.rowHeight=40;
    tableSetting.scrollEnabled=NO;
    tableSetting.delegate=self;
    tableSetting.dataSource=self;
    tableSetting.backgroundColor = [UIColor clearColor];

    [self setExtraCellLineHidden:tableSetting];
    [self.view addSubview:tableSetting];
    if ([tableSetting respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableSetting setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableSetting respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableSetting setLayoutMargins:UIEdgeInsetsZero];
    }

}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    tableView.tableHeaderView = ({
        UIView *upView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 150)];
        upView.backgroundColor = self.view.backgroundColor;
        NSDictionary *infoDIc=[[NSBundle mainBundle]infoDictionary];
        NSString *currentVersion=infoDIc[@"CFBundleShortVersionString"];
        UIImageView *logoIgv = [[UIImageView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth/2.0-30, 30, 60, 65)];
        logoIgv.image = [UIImage imageNamed:@"APP icon"];
        [upView addSubview:logoIgv];
        UILabel *appTitle = [[UILabel alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth/2.0-100, CGRectGetMaxY(logoIgv.frame), 200, 30)];
        appTitle.text = [infoDIc[@"CFBundleDisplayName"] stringByAppendingString:currentVersion];
        appTitle.font = [UIFont systemFontOfSize:13];
        appTitle.textAlignment = NSTextAlignmentCenter;
        [upView addSubview:appTitle];
        upView;
    });
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return name.count;
}

- (CCSettingCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CCSettingCell";
    CCSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell =[[CCSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        
        cell.textLable.text=[name objectAtIndex:indexPath.row];
        cell.textLable.font = [UIFont systemFontOfSize:14];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }

    
    
    return cell;
}
        
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==0) {
 
     STBaseSettingVC *import=[[STBaseSettingVC alloc]init];
        import.hidesBottomBarWhenPushed = YES;
        [import setBlock:^(BOOL onOrNot, NSInteger timeChose) {
            NSDictionary *params = @{@"isOn":[NSNumber numberWithBool:onOrNot],@"time":@(timeChose)};
            NSString *final = [[CCUtil basedString:TimeRemind withDic:params]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            ASIHTTPRequest *requset = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:final]];
            [requset setTimeOutSeconds:20];
            [requset setRequestMethod:@"GET"];
            [requset startSynchronous];
            NSString *data = [requset responseString];
            if ([data rangeOfString:@"true"].location!= NSNotFound) {
                //成功
                
            }
            
        }];
     [self.navigationController pushViewController:import animated:YES];
        
    }else if (indexPath.row==1)
    {
        if (name.count==2) {
            STContactUSVC *contact = [[STContactUSVC alloc]init];
            contact.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:contact animated:YES];
            return;
        }
        
        STCheckUpdate *update = [[STCheckUpdate alloc]init];
        update.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:update animated:YES];
    }
    else if(indexPath.row == 2 ){
        STContactUSVC *contact = [[STContactUSVC alloc]init];
        contact.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:contact animated:YES];
    }
}


/*
 *退出系统
 */
- (void)singOut{
    [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"clickOut"];
    LocationShareModel *shareModel = [LocationShareModel sharedModel];
    [shareModel.timer invalidate];
    [shareModel.delay10Seconds invalidate];
    [shareModel.fiveMinutesTimer invalidate];
    CCNavigationController *main = (CCNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    CCMainViewController *main1 = (CCMainViewController*)main.viewControllers[0];
    [main1.locationUpdateTimer invalidate];
    [main1.ImageAnimatinTimer invalidate];
    [CSDataService requestWithURL:LogOutURL params:nil httpMethod:@"GET" block:^(id result) {
        
    }];
    [defaults setBool:NO forKey:@"autoLogin"];
    CCLoginViewController *CClogin=[[CCLoginViewController alloc]init];
    [self.navigationController pushViewController:CClogin animated:YES];
}
@end
