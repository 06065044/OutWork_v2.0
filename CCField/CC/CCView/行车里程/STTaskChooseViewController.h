//
//  STTaskChooseViewController.h
//  CCField
//
//  Created by 马伟恒 on 16/8/2.
//  Copyright © 2016年 Field. All rights reserved.
//
typedef void(^choseDone)(NSArray*);
#import "CCRootViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface STTaskChooseViewController : CCRootViewController
{
    choseDone _block;
}
@property(assign)CLLocationCoordinate2D coor;

-(void)setBlock:(choseDone)blockA;
@end
