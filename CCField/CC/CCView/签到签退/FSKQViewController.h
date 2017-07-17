//
//  FSKQViewController.h
//  FastSale
//
//  Created by 马伟恒 on 15/8/12.
//  Copyright (c) 2015年 马伟恒. All rights reserved.
//

#import "CCRootViewController.h"
 typedef NS_ENUM(NSInteger, GO_DOWN) {
    GO_DOWN_GO=0,
    GO_DOWN_DOWN=1
};
@interface FSKQViewController : CCRootViewController

@property(assign)NSInteger btnIndex;
@property(strong,nonatomic,nullable)NSDictionary *infoDic;
@property(assign,nonatomic)float lat;
@property(assign,nonatomic)float lng;
@property(strong,nonatomic,nonnull)NSString *Address;
@property(assign,nonatomic)GO_DOWN type;
@property(assign)BOOL normal;
@property(strong,nonatomic,nonnull)NSString *btnString;
@property(nonnull,nonatomic,strong)  NSString *singRecordId;
 @end
