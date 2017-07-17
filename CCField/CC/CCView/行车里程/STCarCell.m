//
//  STCarCell.m
//  CCField
//
//  Created by 马伟恒 on 16/6/27.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STCarCell.h"

@implementation STCarCell
-(void)addSub{
    
        self.contentView.backgroundColor = [UIColor whiteColor];
        //加载view
        UIView * upGrayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 5)];
        upGrayView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        [self.contentView addSubview:upGrayView];
        //任务名称
        UILabel * taskName = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 200, 25)];
        taskName.font = [UIFont systemFontOfSize:16];
        taskName.tag = 200;
        [self.contentView addSubview:taskName];
        //里程
        UILabel *taskDis = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(taskName.frame), CGRectGetMaxY(taskName.frame), CGRectGetWidth(taskName.frame), 25)];
        taskDis.font = [UIFont systemFontOfSize:13];
        taskDis.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:taskDis];
        taskDis.tag = 201;
        
        //日期
        UILabel *taskDate = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(taskDis.frame), CGRectGetMaxY(taskDis.frame), CGRectGetWidth(taskDis.frame), CGRectGetHeight(taskDis.frame))];
        taskDate.font = taskDis.font;
        taskDate.textColor = taskDis.textColor;
        [self.contentView addSubview:taskDate];
        taskDate.tag = 202;
 
}
-(void)setData:(NSDictionary *)carModel{
    //任务名称
    UILabel *taskName = (UILabel *)[self.contentView viewWithTag:200];
    taskName.text =[@"里程名称:" stringByAppendingString:carModel[@"name"]];
    //任务里程
    UILabel *taskKm = (UILabel *)[self.contentView viewWithTag:201];
    taskKm.text =[@"费用(元):" stringByAppendingString:carModel[@"distance"]];
    if (self.type>1) {
        taskKm.text =[@"提交人:" stringByAppendingString:carModel[@"approveUser"]];

    }
    //任务日期
    UILabel *taskDate = (UILabel *)[self.contentView viewWithTag:202];
    taskDate.text = [@"提交日期" stringByAppendingString:carModel[@"createDate"]];
}
-(void)confirmDic:(NSDictionary *)dic{

    UILabel *taskName = (UILabel *)[self.contentView viewWithTag:200];
    taskName.text = dic[@"workTitle"];
    //任务里程
    UILabel *taskKm = (UILabel *)[self.contentView viewWithTag:201];
    taskKm.text = [@"工作地点:" stringByAppendingString:dic[@"location"]];
    //任务日期
    UILabel *taskDate = (UILabel *)[self.contentView viewWithTag:202];
    taskDate.text =[@"提交人:" stringByAppendingString:dic[@"name"]];

}
@end
