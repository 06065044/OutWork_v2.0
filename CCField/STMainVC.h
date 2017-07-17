//
//  STMainVC.h
//  FindHelperOC
//
//  Created by 马伟恒 on 16/6/17.
//  Copyright © 2016年 马伟恒. All rights reserved.
//

#import "CCRootViewController.h"
#import "LocationTracker.h"
@interface STMainVC : CCRootViewController
@property (nonatomic) NSTimer* locationUpdateTimer;
@property LocationTracker * locationTracker;
@end
