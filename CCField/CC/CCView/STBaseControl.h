//
//  STBaseControl.h
//  CCField
//
//  Created by 马伟恒 on 16/7/1.
//  Copyright © 2016年 Field. All rights reserved.
//
#import <UIKit/UIKit.h>
typedef void(^touchBlock)(NSInteger);
@interface STBaseControl : UIView
{
    NSArray *array1;
    touchBlock _block;
    UIImageView *red_down_igv;
}
-(instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)array touchHandler:(touchBlock)block;
@end
