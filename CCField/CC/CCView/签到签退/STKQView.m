//
//  STKQView.m
//  CCField
//
//  Created by 马伟恒 on 16/7/1.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STKQView.h"

@implementation STKQView
-(_Nonnull instancetype)initWithFrame:(CGRect)frame useDic:( NSDictionary * _Nonnull )dic{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        dataDic = [dic mutableCopy];
        [self layoutSubviews];
    }
    return self;
}
-(void)layoutSubviews{
    //header灰色view
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 5)];
    headView.backgroundColor =[UIColor grayColor];
    [self addSubview:headView];
    //打卡次数
    
    UILabel *headTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 200, 30)];
    headTitle.text = dataDic[@"title"];
    headTitle.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:headTitle];
    
    //打卡时间
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(headTitle.frame), CGRectGetMaxY(headTitle.frame), kFullScreenSizeWidth-40, 30)];
    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.textColor = [UIColor lightGrayColor];
    timeLabel.text = [@"时间: " stringByAppendingString:dataDic[@"time"]];
    [self addSubview:timeLabel];
    
    //打卡地点
    UILabel *place = [[UILabel alloc]initWithFrame:CGRectOffset(timeLabel.frame, 0, 30)];
    place.font = timeLabel.font;
    place.textColor = timeLabel.textColor;
    place.text = [@"打卡地址: " stringByAppendingString:dataDic[@"place"]];
   }
@end
