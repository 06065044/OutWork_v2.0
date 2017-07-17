
//
//  STHeadView.m
//  CCField
//
//  Created by 马伟恒 on 2017/2/27.
//  Copyright © 2017年 Field. All rights reserved.
//

#import "STHeadView.h"
#import "CCUtil.h"
static const NSInteger IMAGE_WIDTH = 30;
@implementation STHeadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame name:(NSString *)name{
    if (self = [super initWithFrame:frame]) {
        UIImageView *igv_head = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2.0-IMAGE_WIDTH/2.0, 5, IMAGE_WIDTH, IMAGE_WIDTH)];
        igv_head.image = [CCUtil getLogoFrom:name];
        igv_head.layer.cornerRadius = 15;
        igv_head.layer.masksToBounds = YES;
        [self addSubview:igv_head];
        UILabel *name_label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(igv_head.frame), CGRectGetWidth(self.frame), 20)];
        name_label.text = name;
        name_label.textAlignment = NSTextAlignmentCenter;
        name_label.font = [UIFont systemFontOfSize:12];
        [self addSubview:name_label];
        
    }
    return  self;
}
 
@end
