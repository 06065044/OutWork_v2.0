//
//  CCLocationController.h
//  CCField
//
//  Created by issuser on 16/4/18.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "CCRootViewController.h"

typedef void(^sureLocation)(NSArray*,NSString*);

typedef NS_ENUM(NSInteger,MAP_TYPE){
    MAP_TYPE_BAIDU,
    MAP_TYPE_GAODE,
    MAP_TYPE_TENCENT
};

@interface CCLocationController : CCRootViewController
{
    //经纬度
    NSString *_jingLongitude;
    NSString *_weiLatitude;
    //精度
    float _horizontalAccuracy;
    
    sureLocation _sure;
}
-(void)setBlock:(sureLocation)blockA;
@end
