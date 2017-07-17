//
//  STFourPerDay.m
//  CCField
//
//  Created by 马伟恒 on 16/6/23.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STFourPerDay.h"
#import "CCUtil.h"
#import "FSKQViewController.h"
@interface STFourPerDay()
@property(strong,nonatomic)UIButton *buttonLeftUp;
@property(strong,nonatomic)UIButton *buttonRightUp;
@property(strong,nonatomic)UIButton *buttonLeftDown;
@property(strong,nonatomic)UIButton *buttonRightDown;
@end
@implementation STFourPerDay
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubviews];
    }
    return self;
}
-(void)addSubviews{
    UIFont *font = [UIFont systemFontOfSize:14];
    _timeTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, kFullScreenSizeWidth/3.0,40)];
    _timeTitle.textAlignment = NSTextAlignmentCenter;
    _timeTitle.font = font;
    [self.contentView addSubview:_timeTitle];
    
    _buttonLeftUp = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonLeftUp.frame = CGRectMake(kFullScreenSizeWidth/3.0, 0, kFullScreenSizeWidth/3.0, 40);
    _buttonLeftUp.titleLabel.font = font;
    [self.contentView addSubview:_buttonLeftUp];
    
    _buttonRightUp = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonRightUp.frame = CGRectOffset(_buttonLeftUp.frame, kFullScreenSizeWidth/3.0, 0);
    _buttonRightUp.titleLabel.font = font;
    [self.contentView addSubview:_buttonRightUp];
    
    _buttonLeftDown = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonLeftDown.frame = CGRectOffset(_buttonLeftUp.frame, 0, CGRectGetHeight(_buttonLeftUp.frame));
    _buttonLeftDown.titleLabel.font = font;
    
    [self.contentView addSubview:_buttonLeftDown];
    
    _buttonRightDown = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonRightDown.frame = CGRectOffset(_buttonLeftDown.frame,kFullScreenSizeWidth/3.0, 0);
        _buttonRightDown.titleLabel.font = font;
    [self.contentView addSubview:_buttonRightDown];
    
    [_buttonLeftUp addTarget:self action:@selector(appendReport:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonLeftDown addTarget:self action:@selector(appendReport:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonRightUp addTarget:self action:@selector(appendReport:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonRightDown addTarget:self action:@selector(appendReport:) forControlEvents:UIControlEventTouchUpInside];
    /**
     *  添加竖线
     */
    UIImageView *verLine = [[UIImageView  alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth/3.0, 0, 1, 80)];
    verLine.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    [self.contentView addSubview:verLine];
    
    UIImageView *verLineRight = [[UIImageView alloc]initWithFrame:CGRectOffset(verLine.frame, kFullScreenSizeWidth/3.0, 0)];
    verLineRight.backgroundColor = verLine.backgroundColor;
    [self.contentView addSubview:verLineRight];
    
    UIImageView *rightMidLine = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_timeTitle.frame), CGRectGetMidY(_timeTitle.frame), kFullScreenSizeWidth*2/3.0, 1)];
    rightMidLine.backgroundColor =  verLine.backgroundColor;
    [self.contentView addSubview:rightMidLine];
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
    //分为异常说明和补充签到
    // id为空是补签，不为空是说明
    KQ.btnString = button_cur_title;
    if (_buttonLeftUp == button) {
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
    if (_buttonRightUp == button) {
        if ([dicCopy[1] isKindOfClass:[NSDictionary class]]) {
            KQ.singRecordId = dicCopy[1][@"id"];
            KQ.infoDic = dicCopy[1];
            KQ.btnIndex =2;
        }
        else
            KQ.btnIndex = 2;
    }
    if (_buttonLeftDown == button) {
        if ([dicCopy[2] isKindOfClass:[NSDictionary class]]) {
            KQ.singRecordId = dicCopy[2][@"id"];
            KQ.infoDic = dicCopy[2]; KQ.btnIndex = 3;
        }
        else
            KQ.btnIndex = 3;
    }

    if (_buttonRightDown == button) {
        if ([dicCopy[3] isKindOfClass:[NSDictionary class]]) {
            KQ.singRecordId = dicCopy[3][@"id"];
            KQ.infoDic = dicCopy[3];KQ.btnIndex = 4;
        }
        else
            KQ.btnIndex = 4;
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
        [_buttonLeftUp   setTitle:dic[0] forState:UIControlStateNormal];

    }
    else{
        NSString *title = [CCUtil getStringWithStatus:dic[0]];

        [_buttonLeftUp setTitle:title forState:UIControlStateNormal];
        [_buttonLeftUp setTitleColor:[CCUtil getColorFromStatus:title] forState:UIControlStateNormal];
//        if ([title isEqualToString:@"审核中"]) {
//            [_buttonRightUp setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
//        }
    }
    
    
    if ([dic[1]isKindOfClass:[NSString class]]&&([dic[1] isEqualToString:@"工作"]||[dic[1] isEqualToString:@"休息"])) {
        [_buttonRightUp   setTitle:dic[1] forState:UIControlStateNormal];
 
    }
    else{
        NSString *title = [CCUtil getStringWithStatus:dic[1]];

        [_buttonRightUp setTitle:title forState:UIControlStateNormal];
        [_buttonRightUp setTitleColor:[CCUtil getColorFromStatus:title] forState:UIControlStateNormal];
//        if ([title isEqualToString:@"审核中"]) {
//            [_buttonRightUp setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
//        }
     }
    
    
    if ([dic[2]isKindOfClass:[NSString class]]&&([dic[2] isEqualToString:@"工作"]||[dic[2] isEqualToString:@"休息"])) {
        [_buttonLeftDown   setTitle:dic[2] forState:UIControlStateNormal];
        
    }
    else{
        NSString *title = [CCUtil getStringWithStatus:dic[2]];
        [_buttonLeftDown setTitle:title forState:UIControlStateNormal];
        [_buttonLeftDown setTitleColor:[CCUtil getColorFromStatus:title] forState:UIControlStateNormal];
//        if ([title isEqualToString:@"审核中"]) {
//            [_buttonLeftDown setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
//        }
    }


    if ([dic[3]isKindOfClass:[NSString class]]&&([dic[3] isEqualToString:@"工作"]||[dic[3] isEqualToString:@"休息"])) {
        [_buttonRightDown   setTitle:dic[3] forState:UIControlStateNormal];
        
    }
    else{
        NSString *title = [CCUtil getStringWithStatus:dic[3]];
        [_buttonRightDown setTitle:title forState:UIControlStateNormal];
        [_buttonRightDown setTitleColor:[CCUtil getColorFromStatus:title] forState:UIControlStateNormal];
//        if ([title isEqualToString:@"审核中"]) {
//              [_buttonRightDown setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
//        }
        
    }


    
    
}
-(void)resetButtonTitle{
    [_buttonLeftUp setTitle:@"-" forState:UIControlStateNormal];
    [_buttonLeftUp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
   
    [_buttonRightUp setTitle:@"-" forState:UIControlStateNormal];
    [_buttonRightUp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [_buttonLeftDown setTitle:@"-" forState:UIControlStateNormal];
    [_buttonLeftDown setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [_buttonRightDown setTitle:@"-" forState:UIControlStateNormal];
    [_buttonRightDown setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}
-(void)clearButtonTitle{

}
@end
