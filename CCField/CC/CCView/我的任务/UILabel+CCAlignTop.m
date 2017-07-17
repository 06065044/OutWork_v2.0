//
//  UILabel+CCAlignTop.m
//  CCField
//
//  Created by 马伟恒 on 15/5/26.
//  Copyright (c) 2015年 Field. All rights reserved.
//

#import "UILabel+CCAlignTop.h"

@implementation UILabel (CCAlignTop)
-(void)alignTop{
    CGSize fontSize =[self.text sizeWithFont:self.font];
    double finalHeight = fontSize.height *self.numberOfLines;
    double finalWidth =self.frame.size.width;//expected width of label
    CGSize theStringSize =[self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    int newLinesToPad =(finalHeight - theStringSize.height)/ fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text =[self.text stringByAppendingString:@"\n "];

}
@end
