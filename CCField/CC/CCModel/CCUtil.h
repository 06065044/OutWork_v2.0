//
//  CCUtil.h
//  CCField
//
//  Created by 马伟恒 on 14-10-13.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface CCUtil : NSObject
+(void)showMBLoading:(NSString *)mainTitle detailText:(NSString *)detailTitle;
//网络加载框消失
+(void)hideMBLoading;
+ (BOOL)isContainsEmoji:(NSString *)string;
+(NSString *)basedString:(NSString *)baseSting withDic:(NSDictionary *)dic;
+(NSString *)changeWithInt:(NSString *)strCode;
+(UIColor *)colorByStringCode:(NSString *)strCode;
 +(NSDate *) convertDateFromString:(NSString*)uiDate;
+(NSString *)changeDateWithInterval:(NSTimeInterval)spaceTime;
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
 +(NSString*)timeCurrte;
+(NSString *)currentStamp;
 +(void)showMBProgressHUDLabel:(NSString *)labelText;

/**
 *  显示2秒后消失
 *
 *  @param labelText        消失的表示
 *  @param detailsLabelText 详细内容
 */
+(void)showMBProgressHUDLabel:(NSString *)labelText detailLabelText:(NSString *)detailsLabelText;
/**
 *  判断是否满足设置中设定的上传条件
 *
 *  @return bool
 */
+(BOOL)whetherCanUPload;
/**
 *  判断设备型号
 *
 *  @param controller 可以传空
 *
 *  @return 返回各个型号的字符串
 */
+ (NSString *)getCurrentDeviceModel:(UIViewController *)controller;
/**
 *  根据状态编号转化为需要的字符串
 *
 *  @param status 状态编号
 *
 *  @return 返回的字符串
 */
+(NSString *)getStringWithStatus:(NSString *)status;
/**
 *  根据状态编号转化为需要的颜色
 *
 *  @param status 状态编号
 *
 *  @return 返回的颜色
 */
+(UIColor  *)getColorFromStatus:(NSString *)status;
/**
 *  view 的抖动
 *
 *  @param view 目标view
 */
+(void)shakeAnimationForView:(UIView *)view;
/**
 *   
 *所用的坐标是否超过了国内的界限
 *
 */
 +(BOOL)whetherUsefulCoordinate:(CLLocationCoordinate2D)point;

/**
 绘制部门的头像
 @param stirng 部门的名字
 @return 返回图片，蓝色底部，中间是部门的第一个字
 */
+(UIImage *)getLogoFrom:(NSString *)stirng;
@end
