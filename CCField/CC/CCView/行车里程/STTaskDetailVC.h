//
//  STTaskDetailVC.h
//  CCField
//
//  Created by 马伟恒 on 16/6/27.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "CCRootViewController.h"
typedef void(^refresh)(void);
@interface STTaskDetailVC : CCRootViewController

@property(strong,nonnull,nonatomic)NSDictionary *carModel;
@property(copy,nonatomic)refresh _refreshBlock;
@end
