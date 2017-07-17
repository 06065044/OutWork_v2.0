//
//  AddressBookFoot.h
//  Sales
//
//  Created by wangxu on 15/12/9.
//  Copyright © 2015年 Lifu. All rights reserved.
//

#import <UIKit/UIKit.h>
 
@interface AddressBookFoot : UIView
//选中联系人数组
@property (nonatomic, retain) NSArray *selectedArray;
@property(strong,nonatomic)UIScrollView *headScroll;
@property (nonatomic, weak) UIViewController *superVC;
//@property (nonatomic, retain) CompanyContactModel *mCompanyContactModel;
@end
