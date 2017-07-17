//
//  STNoLocationView.m
//  CCField
//
//  Created by 马伟恒 on 2017/2/27.
//  Copyright © 2017年 Field. All rights reserved.
//

#import "STNoLocationView.h"
#import "STHeadView.h"
#import "UIColor+STHxString.h"
@implementation STNoLocationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame peopleArray:(NSArray *)array{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        no_location_array = [array copy];
        [self showInfo];
    }
    
    return self;
}
-(void)showInfo{
    UILabel *lab_text = [[UILabel alloc]initWithFrame:
    CGRectMake(0, 0, CGRectGetWidth(self.frame), 25)];
    NSString *btn_title = [NSString stringWithFormat:@"共%lu个员工未搜到",(unsigned long)no_location_array.count];
    lab_text.text = btn_title;
    lab_text.font = [UIFont systemFontOfSize:12];
    lab_text.textColor = [UIColor colorWithHexString:@"f02121"];
    lab_text.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lab_text];
    
    UIButton *click_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    click_btn.frame = CGRectMake(CGRectGetWidth(self.frame)-24, 8, 10, 10);
    [click_btn setBackgroundImage:[UIImage imageNamed:@"turnright"] forState:UIControlStateNormal];
    [click_btn addTarget:self action:@selector(showMorePeople) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:click_btn];
    
    UIView *down_view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lab_text.frame), CGRectGetWidth(self.frame), 1)];
    down_view.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:down_view];
    NSInteger view_height =60;
    CGFloat view_width = CGRectGetWidth(self.frame)/4.0;
    for (int i=0; i<no_location_array.count; i++) {
        CGRect frame = CGRectMake(0+view_width*(i%4),CGRectGetMaxY(down_view.frame)+5+(view_height*(i/4)), view_width, view_height);
        if (i==7) {
            UILabel *more_label = [[UILabel alloc]initWithFrame:frame];
            more_label.text = @".....";
            more_label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:more_label];
            break;
        }
        STHeadView *headView = [[STHeadView alloc]initWithFrame:frame name:no_location_array[i]];
        [self addSubview:headView];
    }
    UIButton *cacelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cacelBtn.frame = CGRectMake(CGRectGetWidth(self.frame)/2.0-60, CGRectGetHeight(self.frame)-40, 120, 30);
    [cacelBtn setTitle:@"我知道了" forState:UIControlStateNormal];
    [self addSubview:cacelBtn];
    [cacelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cacelBtn addTarget:self action:@selector(cancelSelf) forControlEvents:UIControlEventTouchUpInside];
    cacelBtn.layer.borderColor = [UIColor blackColor].CGColor;
    cacelBtn.layer.borderWidth = 1.0;
    cacelBtn.layer.cornerRadius=5.0f;
}
-(void)cancelSelf{
    [[_vc.view viewWithTag:337]removeFromSuperview];
    [self removeFromSuperview];
}
-(void)showMorePeople{
    if (_showmore) {
        _showmore();
    }


}
@end
