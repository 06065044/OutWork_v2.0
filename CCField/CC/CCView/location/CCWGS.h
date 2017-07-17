//
//  CCWGS.h
//  CCField
//
//  Created by 马伟恒 on 15/2/12.
//  Copyright (c) 2015年 Field. All rights reserved.
//
//火星坐标转换，用于高德地图等火星地图，corelocation是地球坐标
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
 @interface CCWGS : NSObject
+(BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;
//转GCJ-02
+(CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;
@end
