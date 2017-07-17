//
//  UILabel+CCBord.m
//  CCField
//
//  Created by 马伟恒 on 14-10-14.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "UILabel+CCBord.h"

@implementation UILabel (CCBord)
-(void)showBordle{
    self.layer.borderColor=[UIColor blackColor].CGColor;
    self.layer.borderWidth=3.0;
}
@end
