//
//  CCMainViewController.h
//  CCField
//
//  Created by 李付 on 14-10-9.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MAMapKit/MAMapKit.h>
@interface CCMainViewController : UIViewController{
    
    NSArray *_advertArray;
    int _changeImageIndex;
    UIImageView * _ADImageView;
    UIPageControl *_pageContol;
    MAUserLocation *locManager;
 }
/**
 *  后台上传位置
 */
@property(strong,nonatomic)CLLocation *currentLocation;
//
@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;
@property(strong,nonatomic)CLGeocoder *geocoder;

@property (strong, nonatomic) dispatch_block_t expirationHandler;
@property (assign, nonatomic) BOOL jobExpired;
@property (assign, nonatomic) BOOL background;
@property(strong,nonatomic) NSString *place;
@property (nonatomic) NSTimer* locationUpdateTimer;
@property (nonatomic) NSTimer* ImageAnimatinTimer;
@end
