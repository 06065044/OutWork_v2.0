//
//  STTeamCarVC.m
//  CCField
//
//  Created by 马伟恒 on 16/8/6.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STTeamCarVC.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"
#import "STCarCell.h"
#import "STTaskDetailVC.h"
#import "CCWQDetailViewController.h"
@interface STTeamCarVC()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_teamCar;
    NSMutableArray *resultArray;
    NSInteger currentPage;
}
@end
@implementation STTeamCarVC
-(void)viewDidLoad{
    [super viewDidLoad];
    resultArray = [NSMutableArray arrayWithCapacity:3];
    _teamCar = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)) style:UITableViewStylePlain];
    _teamCar.delegate =self;
    _teamCar.dataSource = self;
    _teamCar.rowHeight = 80;
    if ([_teamCar respondsToSelector:@selector(setSeparatorInset:)]) {
        [_teamCar setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_teamCar respondsToSelector:@selector(setLayoutMargins:)]) {
        [_teamCar setLayoutMargins:UIEdgeInsetsZero];
    }
    
    _teamCar.backgroundColor = [UIColor clearColor];
    [_teamCar registerClass:[STCarCell class] forCellReuseIdentifier:@"STCarCell"];
    [self.view addSubview:_teamCar];
    _teamCar.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    currentPage = 1;
    NSDictionary *dic = @{@"currentPage":@(currentPage),@"pageSize":@(1000),@"queryType":@"TEAM"};
    self.lableNav.text = @"团队里程";
    if (self.urlType == Type_Url_WQ) {
        self.lableNav.text = @"团队外勤";
        dic = @{@"currentPage":@(currentPage),@"pageSize":@(100),@"owner":@"1"};
    }
    [self beginUrlWithDic:dic];}
-(void)beginUrlWithDic:(NSDictionary *)dic{
    NSString *stringURL = [[CCUtil basedString:getCarDisList withDic:dic]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (self.urlType == Type_Url_WQ) {
        stringURL = [[CCUtil basedString:workRecordURL withDic:dic]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
    }
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:stringURL]];
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:20];
    [request startSynchronous];
    NSData *dataRes = request.responseData;
    if (!dataRes) {
        return;
    }
    
    NSArray *Arr= [NSJSONSerialization JSONObjectWithData:dataRes options:NSJSONReadingMutableLeaves error:nil][@"result"];
    self->resultArray = [Arr copy];
    if (self->resultArray.count==0) {
            [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"暂无数据"];
        }
    [self->_teamCar reloadData];
  
    
}
#pragma mark == table delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return resultArray.count;
}
-(  UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    STCarCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"STCarCell" forIndexPath:indexPath];
    if ([Cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [Cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([Cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [Cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
    
    [Cell addSub];
    Cell.type =10;
    if (self.urlType == Type_Url_WQ) {
        [Cell confirmDic:resultArray[indexPath.row]];
    }
    else{
        NSDictionary *carModel = resultArray[indexPath.row];
        [Cell setData:carModel];
    }
    return Cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.urlType == Type_Url_WQ) {
        CCWQDetailViewController *Detial = [[CCWQDetailViewController alloc]init];
        Detial.INFODIC = resultArray[indexPath.row];
        [self.navigationController pushViewController:Detial animated:YES];
    }
    else{
        STTaskDetailVC *taskDetail = [[STTaskDetailVC alloc]init];
        taskDetail.carModel = resultArray[indexPath.row];
        [self.navigationController pushViewController:taskDetail animated:YES];
    }
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
