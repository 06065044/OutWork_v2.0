//
//  UIColor+STHxString.h
//  CCField
//
//  Created by 马伟恒 on 2016/9/29.
//  Copyright © 2016年 Field. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (STHxString)
+ (UIColor *)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end
