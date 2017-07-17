//
//  STBaseSettingVC.h
//  CCField
//
//  Created by 马伟恒 on 16/6/21.
//  Copyright © 2016年 Field. All rights reserved.
//
typedef void(^endChose)(BOOL,NSInteger);
#import "CCRootViewController.h"

@interface STBaseSettingVC : CCRootViewController
{
    endChose _chose;
}
-(void)setBlock:(endChose)block;
@end
