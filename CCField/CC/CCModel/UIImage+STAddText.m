//
//  UIImage+STAddText.m
//  CCField
//
//  Created by 马伟恒 on 16/9/5.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "UIImage+STAddText.h"

@implementation UIImage (STAddText)
-(UIImage *)watermarkImage:(NSString *)text{
    //1.获取上下文
    
    UIGraphicsBeginImageContext(self.size);

    //2.绘制图片
    
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];

    //3.绘制水印文字
    
    CGRect rect = CGRectMake(0, self.size.height-50, self.size.width, 20);

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    
    style.alignment = NSTextAlignmentCenter;
    
    //文字的属性
    
    NSDictionary *dic = @{
                          
                          NSFontAttributeName:[UIFont systemFontOfSize:18],
                          
                          NSParagraphStyleAttributeName:style,
                          
                          NSForegroundColorAttributeName:[UIColor orangeColor]
                          
                          };
    //将文字绘制上去
    
    [text drawInRect:rect withAttributes:dic];
    //4.获取绘制到得图片
    
    UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    //5.结束图片的绘制
    
    UIGraphicsEndImageContext();
    
    
    
    return watermarkImage;
}
@end
