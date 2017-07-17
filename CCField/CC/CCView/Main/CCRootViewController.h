//
//  CCRootViewController.h
//  CCField
//
//  Created by 李付 on 14-10-9.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UMMobClick/MobClick.h>
@interface CCRootViewController : UIViewController<UITextFieldDelegate >
{
    
    UIImageView *_imageNav;//底层nav
    UILabel  *_lableNav;//标题
    UIButton  *_buttonNav;//左边的返回按钮
}

@property(nonatomic,strong)UIImageView *imageNav;
@property(nonatomic,strong)UILabel *lableNav;
@property(nonatomic,strong)UIButton *buttonNav;

@end
