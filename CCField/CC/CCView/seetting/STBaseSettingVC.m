//
//  STBaseSettingVC.m
//  CCField
//
//  Created by 马伟恒 on 16/6/21.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STBaseSettingVC.h"
#import "ASIHTTPRequest.h"
@interface STBaseSettingVC()<UIAlertViewDelegate>
{
    UISwitch *switchA;
    NSInteger MinuteCur;
    UISwitch *switchTimeRemind;
    UILabel *lab21;
    BOOL onOrNot;
}
@end
@implementation STBaseSettingVC
-(void)viewDidLoad{
    [super viewDidLoad];
    self.
    self.lableNav.text = @"基础设置";
    MinuteCur = 5;
    UIView *viewA = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, 60)];
    viewA.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewA];
    {
        UILabel *fontLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 200, 30)];
        fontLabel.text = @"实时定位设置";
        fontLabel.font = [UIFont systemFontOfSize:16];
        [viewA addSubview:fontLabel];
        
        switchA = [[UISwitch alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth-65, CGRectGetMinY(fontLabel.frame), 0, 0)];
        
        switchA.on = YES;
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"hasSet"]) {
            switchA.on = [[NSUserDefaults standardUserDefaults]boolForKey:@"auto"];
        }
        
        
        
        switchA.transform  = CGAffineTransformMakeScale(0.85, 0.85);
        switchA.tintColor = [UIColor whiteColor];
        [switchA addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
        [viewA addSubview:switchA];
    }
    UIView *whiteView2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(viewA.frame), kFullScreenSizeWidth, CGRectGetHeight(viewA.frame))];
    whiteView2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteView2];
    {
        UILabel *lab2 = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, kFullScreenSizeWidth-40, 50)];
        lab2.numberOfLines = 0;
        lab2.lineBreakMode = NSLineBreakByCharWrapping;
        [whiteView2 addSubview:lab2];
        lab2.font = [UIFont systemFontOfSize:14];
        lab2.text = @"当关闭此按钮后管理员将无法查看您的实时定位、员工轨迹、位置记录上报数据";
    }
    //view3
    UIView *view3 = [[UIView alloc]initWithFrame:CGRectOffset(viewA.frame, 0, 120)];
    view3.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view3];
    {
        UILabel *fontLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 200, 30)];
        fontLabel.text = @"打卡提醒设置";
        fontLabel.font = [UIFont systemFontOfSize:16];
        [view3 addSubview:fontLabel];
        
        switchTimeRemind = [[UISwitch alloc]initWithFrame:CGRectMake(CGRectGetMinX(switchA.frame), CGRectGetMinY(fontLabel.frame), 200, 30)];
        switchTimeRemind.on = YES;
        onOrNot = YES;
        switchTimeRemind.tintColor = [UIColor whiteColor];
        switchTimeRemind.transform  = CGAffineTransformMakeScale(0.85, 0.85);
        [switchTimeRemind addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
        [view3 addSubview:switchTimeRemind];
    }
    
    UIView *view4 = [[UIView alloc]initWithFrame:CGRectOffset(whiteView2.frame, 0, 120)];
    view4.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view4];
    lab21 = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, kFullScreenSizeWidth-40, 50)];
    lab21.numberOfLines = 0;
    lab21.userInteractionEnabled = true;
    lab21.lineBreakMode = NSLineBreakByCharWrapping;
    [view4 addSubview:lab21];
    UIImageView *igv = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(switchA.frame)+5, CGRectGetMinY(lab21.frame)+5, 20, 20)];
    igv.image = [UIImage imageNamed:@"arrow_down"];
    [view4 addSubview:igv];
    
    
    lab21.text = @"打卡提醒时间\n\n提前5分钟";
    lab21.font = [UIFont systemFontOfSize:14];
    //添加选择时间的手势
    UITapGestureRecognizer *selectTime  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(choseTime)];
    selectTime.numberOfTapsRequired     = 1;
    selectTime.numberOfTouchesRequired  = 1;
    [lab21 addGestureRecognizer:selectTime];
    //存在规则
    __weak  ASIHTTPRequest *requestRule = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:KQ_Rule_Url]];
    [requestRule setTimeOutSeconds:10];
    [requestRule setRequestMethod:@"GET"];
    [requestRule startAsynchronous];
    [requestRule setCompletionBlock:^{
        
        NSData *rule_date = [requestRule responseData];
        if (!rule_date) {
            return ;
        }
        NSDictionary *   rule_dic = [NSJSONSerialization JSONObjectWithData:rule_date options:NSJSONReadingMutableLeaves error:nil][@"data"];
        
        BOOL autoReport = [[rule_dic objectForKey:@"autoReport"]boolValue];
        if (autoReport) {
            //不可以操作
            //            [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"auto"];
            self->switchA.userInteractionEnabled = NO;
            [self->switchA setOnTintColor:[UIColor lightGrayColor]];
        }
    }];
    {
        __weak  ASIHTTPRequest *requestRule = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:getRemindTime]];
        [requestRule setTimeOutSeconds:10];
        [requestRule setRequestMethod:@"GET"];
        [requestRule startAsynchronous];
        [requestRule setCompletionBlock:^{
            
            NSData *rule_date = [requestRule responseData];
            if (!rule_date) {
                return ;
            }
            NSDictionary *   rule_dic = [NSJSONSerialization JSONObjectWithData:rule_date options:NSJSONReadingMutableLeaves error:nil][@"data"];
            
            NSInteger autoReport = [[rule_dic objectForKey:@"status"]integerValue];
            if (autoReport==0) {
                //不可以操作
                //            [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"auto"];
                
                [self->switchTimeRemind setOn:false];
                self->onOrNot = false;
            }
            self->lab21.text = [NSString stringWithFormat:@"打卡提醒时间\n提前%@分钟",rule_dic[@"remidTime"]];
            
        }];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick event:@"base_setting"];
}
-(void)valueChange:(UISwitch *)switches{
    if (switchA == switches) {
        [[NSUserDefaults standardUserDefaults]setBool:switchA.isOn forKey:@"auto"];
        [[NSUserDefaults standardUserDefaults]setBool:true forKey:@"hasSet"];
    }
    if (switchTimeRemind == switches) {
        onOrNot = switchTimeRemind.isOn;
    }
    
}
#pragma mark == 时间选择
-(void)choseTime{
    UIAlertView *timeAlert = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"5分钟",@"10分钟",@"15分钟",nil];
    [timeAlert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex!=alertView.cancelButtonIndex) {
        MinuteCur = 5;
        switch (buttonIndex) {
            case 1:
                MinuteCur = 5;
                break;
            case 2:
                MinuteCur =10;
                break;
            case 3:
                MinuteCur = 15;
                break;
            default:
                break;
        }
        //更新时间选择
        lab21.text =[NSString stringWithFormat:@"打卡提醒时间\n提前%d分钟",MinuteCur];
        
        
    }
    
}
-(void)returnBack{
    
    if (_chose) {
        _chose(onOrNot,MinuteCur);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setBlock:(endChose)block{
    _chose = [block copy];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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
}@end
