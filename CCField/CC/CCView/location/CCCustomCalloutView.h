//
//  CCCustomCalloutView.h
//  CCField
//
//  Created by issuser on 16/4/20.
//  Copyright © 2016年 Field. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CCCustomCalloutViewBlock) ();

@interface CCCustomCalloutView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic , copy) CCCustomCalloutViewBlock block;
-(void)refreshFrame;
@end
