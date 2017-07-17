//
//  STTaskDetailVC.m
//  CCField
//
//  Created by 马伟恒 on 16/6/27.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STTaskDetailVC.h"
#import "NSObject+CC0utString.h"
@interface STTaskDetailVC()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *leftTitleArray;
    NSArray *rightValueArray;
}
@end
@implementation STTaskDetailVC
-(void)viewDidLoad
{
    [super viewDidLoad];
    UITableView *_table = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, 40*7) style:UITableViewStylePlain];
    _table.dataSource   = self;
    _table.delegate     = self;
    _table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    _table.rowHeight = 40;
    [self.view addSubview:_table];
    if ([_table respondsToSelector:@selector(setSeparatorInset:)]) {
        [_table setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_table respondsToSelector:@selector(setLayoutMargins:)]) {
        [_table setLayoutMargins:UIEdgeInsetsZero];
    }
    _table.backgroundColor  = [UIColor clearColor];
    _table.tag  = 300;
    self.lableNav.text=@"里程详情";
    leftTitleArray = @[@"里程名称:",@"里程描述:",@"出发地:",@"目的地:",@"里程(公里):",@"费用(元):",@"备注:",];
}
#pragma mark ==table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuser = @"reuser";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuser];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuser];
        cell.backgroundColor = [UIColor whiteColor];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
    //左边
    UILabel *leftTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 100, 30)];
    leftTitle.text = leftTitleArray[indexPath.row];
    leftTitle.font = [UIFont systemFontOfSize:14];
    [leftTitle sizeToFit];
    [cell.contentView addSubview:leftTitle];
    //右边
    UILabel *valeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(leftTitle.frame), 3, kFullScreenSizeWidth-CGRectGetMaxX(leftTitle.frame)-10, 30)];
    valeLabel.font = leftTitle.font;
    if (indexPath.row==0) {
        valeLabel.text = [_carModel[@"name"]outString];
    }
    if (indexPath.row==1) {
        valeLabel.text = [_carModel[@"description"]outString];
    }
    if (indexPath.row==2) {
        valeLabel.text =   [_carModel[@"startPlace"]outString];
    }
    if (indexPath.row==3) {
        valeLabel.text =   [_carModel[@"endPlace"]outString];
    }
    if (indexPath.row==4) {
        valeLabel.text =   [_carModel[@"distance"]outString];
    }
    if (indexPath.row==5) {
        valeLabel.text =   [_carModel[@"fee"]outString];
    }
    if (indexPath.row==6) {
        valeLabel.text = [_carModel[@"remark"]outString];
    }
  
    
//    valeLabel.numberOfLines = 0;
//    valeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [cell.contentView addSubview:valeLabel];
    
    return cell;
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
