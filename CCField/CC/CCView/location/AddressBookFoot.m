//
//  AddressBookFoot.m
//  Sales
//
//  Created by wangxu on 15/12/9.
//  Copyright © 2015年 Lifu. All rights reserved.
//

#import "AddressBookFoot.h"
#import "AFNetworking.h"
#import "Util.h"
#import "STShowLocaViewController.h"

@interface AddressBookFoot ()<UIAlertViewDelegate>
@property (nonatomic, retain) UIButton *selectedButton;

 @end

@implementation AddressBookFoot

/**
 *  获取网络数据
 *
 *  @param urlStr  请求地址
 *  @param infoDic 请求参数
 */

#pragma mark - alter delegate


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor                                         = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1];
         //        已选择人数
       _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_selectedButton setFrame:CGRectMake(kFullScreenSizeWidth-60, 5, 50, 40)];
        [_selectedButton setBackgroundColor:[UIColor colorWithRed:210/255.0 green:10/255.0 blue:29/255.0 alpha:1]];
        [_selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_selectedButton addTarget:self action:@selector(checkLocation) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_selectedButton];
        
        
        
        _headScroll =  [[UIScrollView alloc]initWithFrame:CGRectMake(5, 5, kFullScreenSizeWidth-80, 40)];
        [self addSubview:_headScroll];
     }
    
    return self;
}

- (void)setSelectedArray:(NSArray *)selectedArray
{
    _selectedArray = selectedArray;
    NSString *button_title = [NSString stringWithFormat:@"确定(%ld)", (unsigned long)selectedArray.count];
    [_selectedButton setTitle:button_title forState:UIControlStateNormal];
    [_headScroll setContentSize:CGSizeMake(40*selectedArray.count, 40)];
    for (UIImageView *igv in _headScroll.subviews) {
        [igv removeFromSuperview];
    }
    for (int i=0;i<selectedArray.count;i++) {
        UIImageView *igv = [[UIImageView alloc]initWithFrame:CGRectMake(5+40*i, 5, 30, 30)];
        [_headScroll addSubview:igv];
        igv.image =[UIImage imageNamed:@"pic2"];
        igv.layer.cornerRadius = 15;
        igv.layer.masksToBounds = YES;
    }
}

#pragma mark - 查看选择的人员坐标
-(void)checkLocation{
    //按照确认的人数获取经纬度坐标
    STShowLocaViewController *showLo = [[STShowLocaViewController alloc]init];
    [self.superVC.navigationController pushViewController:showLo animated:YES];
 }
 

@end
