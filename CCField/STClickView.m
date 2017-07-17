//
//  STClickView.m
//  FindHelperOC
//
//  Created by 马伟恒 on 16/6/17.
//  Copyright © 2016年 马伟恒. All rights reserved.
//

#import "STClickView.h"

@implementation STClickView
-(instancetype)initWithFrame:(CGRect)frame picName:(NSString *)imageName labelText:(NSString *)labelText{
    if (self = [super initWithFrame:frame]) {
        UIImageView* imageLogo = [[UIImageView alloc]initWithFrame:(CGRectMake(25,18, CGRectGetWidth(self.bounds)-50, CGRectGetHeight(self.bounds)-50))];
        imageLogo.image = [UIImage imageNamed:imageName];
        [self addSubview:imageLogo];
        
//        if ([labelText isEqualToString:@"系统公告"]) {
//            //
//            imageLogo.transform  = CGAffineTransformMakeScale(1.1, 1.3);
//            return self;
//        }
        
        UILabel * lab = [[UILabel alloc]initWithFrame:(CGRectMake(CGRectGetMinX(imageLogo.frame)-20,CGRectGetMaxY(imageLogo.frame)+5,CGRectGetWidth(imageLogo.frame)+40,20))];
        lab.text = labelText;
        lab.font = [UIFont systemFontOfSize:13];
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lab];
     }
    return self;
}
@end
