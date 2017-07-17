//
//  STPeopleView.h
//  CCField
//
//  Created by 马伟恒 on 2017/2/8.
//  Copyright © 2017年 Field. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBookFoot.h"
@interface STPeopleView : UIView
@property (nonatomic, weak) UIViewController *superVC;
@property(assign)BOOL whetherAll;
-(instancetype)initWithFrame:(CGRect)frame andDataSource:(NSDictionary *)data withVC:(UIViewController *)superV;;
@end
