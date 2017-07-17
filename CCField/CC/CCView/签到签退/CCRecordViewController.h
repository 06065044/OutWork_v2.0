//
//  CCRecordViewController.h
//  CCField
//
//  Created by 马伟恒 on 14-10-16.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCRootViewController.h"
 #import "ASIHTTPRequest.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "CCUtil.h"
typedef NS_ENUM(NSInteger,SignCount){
    SignCountTwo = 2,
    SignCountFour=4
};

@interface CCRecordViewController : CCRootViewController


@property(strong,nonatomic)AMapGeocode *geocoder;
@end
