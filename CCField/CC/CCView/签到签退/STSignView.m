//
//  STSignView.m
//  CCField
//
//  Created by 马伟恒 on 2016/9/29.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STSignView.h"
#import "UIColor+STHxString.h"
@implementation STSignView
-(instancetype)initWithFrame:(CGRect)frame signTimt:(NSString *)signTime index:(NSInteger)index imageName:(NSString *)imageName buttonTitle:(NSString *)buttonTitle{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *igv = [[UIImageView alloc]initWithFrame:CGRectMake(15, 12, 40, 40)];
        igv.image = [UIImage imageNamed:imageName];
        igv.layer.cornerRadius = 5;
        [self addSubview:igv];
        
        
        NSString *string = index%2==0?@"上班":@"下班";
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(igv.frame)+15, CGRectGetMinY(igv.frame), 100, 20)];
        lab.text = string;
        lab.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:lab];
        
        
        UILabel *signTime0 = [[UILabel alloc]initWithFrame:CGRectOffset(lab.frame, 0, 22)];
        signTime0.text = signTime;
        signTime0.font = [UIFont systemFontOfSize:13];
        signTime0.textColor = [UIColor lightGrayColor];
        [self addSubview:signTime0];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(CGRectGetMaxX(self.frame)-80,17, 60, 30)];
        [btn setTitle:buttonTitle forState:UIControlStateNormal];
        btn.layer.cornerRadius = 6;
        if ([buttonTitle isEqualToString:@"重签"]) {
            [btn setBackgroundColor:[UIColor orangeColor]];
        }
        else
            [btn setBackgroundColor:[UIColor colorWithHexString:@"d8000d"]];
        btn.tag = index;
        [self addSubview:btn];
        
        if ([buttonTitle isEqualToString:@"休息"]) {
            //休息
            
        }
        else
            [btn addTarget:self action:@selector(clickto:) forControlEvents:UIControlEventTouchUpInside];
        UIView *downBack = [[UIView alloc]initWithFrame:CGRectMake(15,63, CGRectGetWidth(self.frame), 1)];
        downBack.backgroundColor = [UIColor lightGrayColor];
        downBack.tag = 321+index;
        [self addSubview:downBack];
    }

    return self;
}
-(void)removeDownLine{
    [[self viewWithTag:373]removeFromSuperview];

}
-(void)clickto:(UIButton *)button{
    
    if ([self.delegate respondsToSelector:@selector(signBtnClickedAtIndex:)]) {
        [self.delegate signBtnClickedAtIndex:button];
    }

}
@end
