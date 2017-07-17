//
//  CCCheckReplyViewController.m
//  CCField
//
//  Created by 马伟恒 on 14/10/22.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCCheckReplyViewController.h"
 #import "STTableViewCell.h"
#import "NSObject+CC0utString.h"
static NSString *cellID=@"cellID";

@interface CCCheckReplyViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *table;
    NSArray *titleArray;
    NSArray *keyArray;
}
@end

@implementation CCCheckReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lableNav.text = @"批示详情";
    // Do any additional setup after loading the view.
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetHeight(self.imageNav.frame))];
     [table registerNib:[UINib nibWithNibName:@"STTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    table.delegate=self;
    table.dataSource=self;
    table.backgroundColor = [UIColor clearColor];
    table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
     [self.view addSubview:table];
    titleArray = @[@"上报时间:",@"开始时间:",@"结束时间:",@"计划变更原因:",@"批示时间:",@"批示姓名:",@"批示内容:"];
    keyArray = @[@"planUpdateTime",@"planStartTime",@"planEndTime",@"changedDescription",@"appTime",@"name",@"appContent",];
    
}
#pragma mark-table delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *text=[[self.infoArr[indexPath.row]objectForKey:@"appContent"] outString];
    CGRect recta=[text boundingRectWithSize:CGSizeMake(kFullScreenSizeWidth-20, 1000) options:
                  NSStringDrawingUsesLineFragmentOrigin |
                  NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
    return MAX(CGRectGetHeight(recta), 25)+155;
    
}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (self.infoArr.count%10==0) {
//        return 0;
//    }
//    
//    return 50;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    if (self.infoArr.count%10==0) {
//        return nil;
//    }
//    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 44)];
//    view.backgroundColor=RGBA(240, 242, 244, 1);
//    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame=CGRectMake(5, 5, kFullScreenSizeWidth, 40);
//    [button setTitle:@"点击加载更多。。" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    if (self.infoArr.count%10!=0) {
//        button.userInteractionEnabled=NO;
//    }
//     [view addSubview:button];
//    return view;
//}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    STTableViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    for (int i=0; i<7; ++i) {
        UILabel *lab = [Cell.contentView viewWithTag:100+i];
        NSString *value = [self.infoArr[indexPath.row][keyArray[i]]outString];
        lab.text = [titleArray[i] stringByAppendingString:value];
    }
    return Cell;
//    NSString *text=[[self.infoArr[indexPath.row]objectForKey:@"appContent"] outString];
//    CGRect recta=[text boundingRectWithSize:CGSizeMake(kFullScreenSizeWidth-20, 1000) options:
//                  NSStringDrawingUsesLineFragmentOrigin |
//                  NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor blackColor]} context:nil];
//
//    UILabel *labTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, kFullScreenSizeWidth-20, MAX(CGRectGetHeight(recta), 25) )];
//    labTitle.text=text;
//    labTitle.font=[UIFont systemFontOfSize:12];
//    labTitle.numberOfLines=0;
//    [labTitle setPreferredMaxLayoutWidth:kFullScreenSizeWidth-20];
//    [Cell.contentView addSubview:labTitle];
//    
//    UILabel *labReply=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(labTitle.frame), CGRectGetMaxY(labTitle.frame)+5, kFullScreenSizeWidth-30, 20)];
//    labReply.text=[NSString stringWithFormat:@"姓名:%@",[[self.infoArr[indexPath.row] objectForKey:@"name"] outString]];
//    labReply.lineBreakMode=NSLineBreakByTruncatingTail;
//    labReply.textColor=[UIColor grayColor];
//    labReply.font =[UIFont systemFontOfSize:12];
//    [Cell.contentView addSubview:labReply];
//    
//    
//    UILabel *startTime=[[UILabel alloc]initWithFrame:CGRectOffset(labReply.frame, 0, 20)];
//    startTime.textColor=[UIColor grayColor];
//    startTime.font = [UIFont systemFontOfSize:12];
//    startTime.text=[[self.infoArr[indexPath.row]objectForKey:@"appTime"]outString];
//    [Cell.contentView addSubview:startTime];
//    return Cell;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.infoArr.count;
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
