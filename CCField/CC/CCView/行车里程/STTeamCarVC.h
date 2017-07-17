//
//  STTeamCarVC.h
//  CCField
//
//  Created by 马伟恒 on 16/8/6.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "CCRootViewController.h"
typedef NS_ENUM(NSInteger,TypeUrl){
    Type_Url_Car,
    Type_Url_WQ
};
@interface STTeamCarVC : CCRootViewController
@property(assign)TypeUrl urlType;
@property(assign)NSInteger type;
@end
