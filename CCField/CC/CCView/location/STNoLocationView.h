//
//  STNoLocationView.h
//  CCField
//
//  Created by 马伟恒 on 2017/2/27.
//  Copyright © 2017年 Field. All rights reserved.
//
typedef void(^showMore)(void);
#import <UIKit/UIKit.h>

@interface STNoLocationView : UIView
@property (strong) showMore showmore;
@property(weak,nonatomic)UIViewController *vc;
-(instancetype)initWithFrame:(CGRect)frame peopleArray:(NSArray *)array;
@end
@interface STNoLocationView()
{
    NSArray *no_location_array;
}
@end
