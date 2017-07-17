//
//  STChoswTaskByPlanVC.h
//  CCField
//
//  Created by 马伟恒 on 16/8/11.
//  Copyright © 2016年 Field. All rights reserved.
//

typedef void(^taskChose)(NSArray *);
#import <UIKit/UIKit.h>
#import "CCRootViewController.h"
@interface STChoswTaskByPlanVC : CCRootViewController
{
    taskChose _chose;
}
-(void)setBLock:(taskChose)choseA;
@end
