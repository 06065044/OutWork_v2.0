//
//  CustTextField.m
//  CCField
//
//  Created by 李付 on 14/11/12.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CustTextField.h"

@implementation CustTextField

- (CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, 5, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, 5, 0);
}

- (void)drawRect:(CGRect)rect{
    UIImage *bg = [[UIImage imageNamed:@"person"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 15, 5)];
    [bg drawInRect:[self bounds]];
}


@end
