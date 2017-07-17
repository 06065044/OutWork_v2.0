//
//  STTaskAddVC.h
//  CCField
//
//  Created by 马伟恒 on 16/6/27.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "CCRootViewController.h"
#import "STMainVC.h"
typedef void(^refresh)(void);

@interface STTaskAddVC : CCRootViewController
@property(nonatomic,strong,nonnull)NSTimer *recordTimer;
@property(copy,nonatomic,nonnull)refresh _refreshBlock;
 @end
