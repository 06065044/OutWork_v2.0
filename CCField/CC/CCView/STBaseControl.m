//
//  STBaseControl.m
//  CCField
//
//  Created by 马伟恒 on 16/7/1.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STBaseControl.h"

@implementation STBaseControl
-(instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)array touchHandler:(touchBlock)block{
    if (self = [super initWithFrame:frame]) {
        array1 = [array mutableCopy];
        _block = block;
        [self createUIView];
    }
    return self;
}
-(void)createUIView{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat buttonWidth = kFullScreenSizeWidth/array1.count;
    for (int i=0; i<array1.count; ++i) {
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleBtn setFrame:CGRectMake(buttonWidth*i, 0, buttonWidth, CGRectGetHeight(self.frame)-1)];
        [titleBtn setTitle:array1[i] forState:UIControlStateNormal];
        [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        titleBtn.tag = 100+i;
        [titleBtn addTarget:self action:@selector(touchBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:titleBtn];
        if (i==0) {
            red_down_igv = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleBtn.frame)-1, buttonWidth, 1)];
            red_down_igv.backgroundColor  = [UIColor redColor];
            [self addSubview:red_down_igv];
        }
    }
}
-(void)touchBtn:(UIButton *)btm{
    NSInteger tag = btm.tag- 100;
    red_down_igv.frame = CGRectMake(CGRectGetMinX(btm.frame), CGRectGetMaxY(btm.frame)-1, CGRectGetWidth(btm.frame), 1);
    _block(tag);
}
@end
