//
//  STTwoPerDay.m
//  CCField
//
//  Created by 马伟恒 on 16/6/23.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STTwoPerDay.h"
#import "CCUtil.h"
#import "FSKQViewController.h"
@interface STTwoPerDay()

@property(strong,nonatomic)UIButton *button;
@property(strong,nonatomic)UIButton *buttonRight;
@end
@implementation STTwoPerDay
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubviews];
    }
    return self;
}

-(void)addSubviews{
    UIFont *font = [UIFont systemFontOfSize:14];
    _timeTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth/3.0,40)];
    _timeTitle.textAlignment = NSTextAlignmentCenter;
    _timeTitle.font = font;
    [self.contentView addSubview:_timeTitle];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(CGRectGetMaxX(_timeTitle.frame), CGRectGetMinY(_timeTitle.frame), kFullScreenSizeWidth/3.0, 40);
    [_button setTitle:@"-" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(appendReport:) forControlEvents:UIControlEventTouchUpInside];
    _button.titleLabel.font = font;
    [self.contentView addSubview:_button];
    
    _buttonRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonRight setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _buttonRight.frame = CGRectOffset(_button.frame, kFullScreenSizeWidth/3.0, 0);
    [_buttonRight setTitle:@"-" forState:UIControlStateNormal];
    [_buttonRight addTarget:self action:@selector(appendReport:) forControlEvents:UIControlEventTouchUpInside];
    _buttonRight.titleLabel.font = font;
    [self.contentView addSubview:_buttonRight];
    
    /**
     *  添加竖线
     */
    UIImageView *verLine = [[UIImageView  alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_timeTitle.frame), CGRectGetMinY(_timeTitle.frame), 1, CGRectGetHeight(_timeTitle.frame))];
     verLine.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    [self.contentView addSubview:verLine];
    
    UIImageView *verLineRight = [[UIImageView alloc]initWithFrame:CGRectOffset(verLine.frame, kFullScreenSizeWidth/3.0, 0)];
    verLineRight.backgroundColor = verLine.backgroundColor;
    [self.contentView addSubview:verLineRight];
}
-(void)appendReport:(UIButton *)button{
    //如果是今天，不能进行补签和异常说明
    
    NSArray *array_export = @[@"缺勤",@"早退",@"迟到",@"审核中",@"通过",@"拒绝",@"正常"];
    NSString *button_cur_title = [button titleForState:UIControlStateNormal];
    if (![array_export containsObject:button_cur_title]) {
        return;
    }
//    if (self.dayNow == self.indexRow&& ![button_cur_title isEqualToString:@"正常"]) {
//        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"抱歉，您可以提交截止到昨天的考勤异常说明"];
//        return;
//    }
    
    
    FSKQViewController *KQ = [[FSKQViewController alloc]init];
    if ([button_cur_title isEqualToString:@"正常"]) {
        KQ.normal = YES;
    }
    KQ.btnString = button_cur_title;
    //分为异常说明和补充签到
    // id为空是补签，不为空是说明

    if (_button == button) {
        //第一个
        if ([dicCopy[0] isKindOfClass:[NSDictionary class]]) {
            KQ.singRecordId = dicCopy[0][@"id"];
            KQ.infoDic = dicCopy[0];
             KQ.btnIndex =1;
        }
        else{
            KQ.btnIndex =1;
            
        }
    }
    if (_buttonRight == button) {
        if ([dicCopy[1] isKindOfClass:[NSDictionary class]]) {
            KQ.singRecordId = dicCopy[1][@"id"];
            KQ.infoDic = dicCopy[1];
            KQ.btnIndex = 2;
        }
        else
            KQ.btnIndex = 2;
    }
    
    if ([[KQ.infoDic[@"signTime"]outString]length]==0) {
        //空
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"无打卡信息"];
       // return;
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:self.timeTitle.text forKey:@"timeTitle"];
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UITabBarController *tab =(UITabBarController *)nav.topViewController;
    UINavigationController *nav1 = (UINavigationController *)tab.selectedViewController;
    [nav1 pushViewController:KQ animated:YES];
    
    //进行异常说明
    
}
/**
 *  根据dic的值确定cell上的控件内容
 *
 *  @param dic 需要填充的内容
 */
-(void)confirmWIthDIc:(NSArray *)dic{
    
    
    dicCopy = [dic mutableCopy];
    
    if ([dic[0]isKindOfClass:[NSString class]]&&([dic[0] isEqualToString:@"工作"]||[dic[0] isEqualToString:@"休息"])) {
        [_button setTitle:dic[0] forState:UIControlStateNormal];
        [_buttonRight setTitle:dic[0] forState:UIControlStateNormal];
        return;
    }
    UIColor *clor = [UIColor blackColor];
    NSString *stra = [CCUtil getStringWithStatus:dic[0]];
    [_button setTitle:stra forState:UIControlStateNormal];
    if ([@[@"迟到",@"早退",@"缺勤"]containsObject:stra]) {
        clor = [UIColor redColor];
    }
    [_button setTitleColor:clor forState:UIControlStateNormal];
    
    
    clor = [UIColor blackColor];
    
    NSString *strb  =[CCUtil getStringWithStatus:dic[1]];
    
    [_buttonRight setTitle:strb forState:UIControlStateNormal];
    if ([@[@"迟到",@"早退",@"缺勤"]containsObject:strb]) {
        clor = [UIColor redColor];
    }
    [_buttonRight setTitleColor:clor forState:UIControlStateNormal];
    
}
-(void)resetButtonTitle{
    [_button setTitle:@"-" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_buttonRight setTitle:@"-" forState:UIControlStateNormal];
    [_buttonRight setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}
-(void)clearButtonTitle{
    [_button setTitle:@" " forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_buttonRight setTitle:@" " forState:UIControlStateNormal];
    [_buttonRight setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
}

@end
