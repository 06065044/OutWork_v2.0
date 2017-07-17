//
//  STChoswTaskByPlanVC.m
//  CCField
//
//  Created by 马伟恒 on 16/8/11.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STChoswTaskByPlanVC.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"

@interface STChoswTaskByPlanVC()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_table;
    NSArray *array;
}
@end
@implementation STChoswTaskByPlanVC
-(void)setBLock:(taskChose)choseA{
    _chose = choseA;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    self.lableNav.text = @"任务选择";
    array = [NSArray array];
    _table =[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-64) style:UITableViewStylePlain];
    _table.delegate =self;
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuser"];
    _table.dataSource = self;
    _table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:_table];
    NSURL *urlStr = [NSURL URLWithString:myTaskPublished];
      ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlStr];
    request.timeOutSeconds = 20;
    request.requestMethod = @"GET";
    [request startSynchronous];
    NSString *responStr = request.responseString;
    if ([responStr rangeOfString:@"true"].location!=NSNotFound) {
        NSData *data = [request responseData];
         self->array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil][@"data"];
        if (![self->array respondsToSelector:@selector(arrayByAddingObject:)]) {
            [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"暂无数据"];
            return;
         }
        [self->_table reloadData];
    }
  
}
#pragma mark ==table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (![array respondsToSelector:@selector(arrayByAddingObject:)]) {
        return 0;
    }
    return array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"reuser" forIndexPath:indexPath];
    cell.textLabel.text = array[indexPath.row][@"title"];
    return  cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *ci = array[indexPath.row];
    NSArray *arr = @[ci[@"id"],ci[@"title"]];
    if (_chose) {
        _chose(arr);
    }
    [self.navigationController popViewControllerAnimated:YES];
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
