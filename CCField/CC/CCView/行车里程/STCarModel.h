//
//  STCarModel.h
//  CCField
//
//  Created by 马伟恒 on 16/6/27.
//  Copyright © 2016年 Field. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STCarModel : NSObject
 
/**
*  里程任务名称
*/
@property(strong,nonnull,nonatomic)NSString *name;
/**
 *  里程任务描述
 */
@property(strong,nonnull,nonatomic)NSString *description1;
/*
 *  任务里程出发地
 */
@property(strong,nonnull,nonatomic)NSString *startPlace;
/**
 *  任务出行目的
 */
@property(strong,nonnull,nonatomic)NSString *endPlace;

/**
 *  任务里程公里数
 */
@property(strong,nonnull,nonatomic)NSString *distance;
/**
 *  任务出行日期
 */
@property(strong,nonnull,nonatomic)NSString *createDate;

/**
 *  任务提交人
 */
@property(strong,nonatomic,nonnull)NSString *approveUser;
/**
 *  里程费用
 */
@property(strong,nonatomic,nonnull)NSString *fee;
/**
 *  里程任务备注
 */
@property(strong,nonnull,nonatomic)NSString *remark;
@end
