//
//  STSignView.h
//  CCField
//
//  Created by 马伟恒 on 2016/9/29.
//  Copyright © 2016年 Field. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol clickBtn<NSObject>
-(void)signBtnClickedAtIndex:(UIButton *)button;
@end

@interface STSignView : UIView
@property(weak) id<clickBtn> delegate;
-(instancetype)initWithFrame:(CGRect)frame signTimt:(NSString *)signTime index:(NSInteger)index
                   imageName:(NSString *)imageName buttonTitle:(NSString *)buttonTitle;
-(void)removeDownLine;
@end
