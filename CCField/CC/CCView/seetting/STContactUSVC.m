//
//  STContactUSVC.m
//  CCField
//
//  Created by 马伟恒 on 16/6/20.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STContactUSVC.h"

@implementation STContactUSVC

-(void)viewDidLoad{
    [super viewDidLoad];
    self.lableNav.text = @"联系我们";
    UITableView *_table = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, 80)];
    _table.delegate = self;
    _table.backgroundColor = [UIColor clearColor];

    if ([_table respondsToSelector:@selector(setSeparatorInset:)]) {
        [_table setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_table respondsToSelector:@selector(setLayoutMargins:)]) {
        [_table setLayoutMargins:UIEdgeInsetsZero];
    }
    _table.dataSource =self;
    [self.view addSubview:_table];
    _table.rowHeight =40;
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuser"];
    titleArray = @[@"服务电话: 400-101-9977",@"服务时间:周一至周日 9:00-21:00"];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick event:@"contact_us"];
}
#pragma mark - table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuser" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
    cell.textLabel.text =titleArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"400-101-9977"];
        //            NSLog(@"str======%@",str);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
 }
@end
