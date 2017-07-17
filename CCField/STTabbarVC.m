//
//  STTabbarVC.m
//  FindHelperOC
//
//  Created by 马伟恒 on 16/6/17.
//  Copyright © 2016年 马伟恒. All rights reserved.
//

#import "STTabbarVC.h"
#import "MessageVC.h"
#import "STMainVC.h"
#import "STSettingVC.h"
@implementation STTabbarVC
-(void)viewDidLoad{
    NSArray *titles = @[@"消息",@"工作",@"我的"];
    NSArray *normalImages = @[@"pic8",@"pic10",@"pic12"];
    NSArray *selectedImages = @[@"pic9",@"pic11",@"pic13"];
    MessageVC *message = [[MessageVC alloc]init];
    STMainVC *main = [[STMainVC alloc]init];
    STSettingVC *setVC = [[STSettingVC alloc]init];
    
    NSArray *VCArrays = @[message,main,setVC];
    NSMutableArray *vcArr = [NSMutableArray array];
    for (int i=0; i<VCArrays.count; ++i) {
        UIViewController *vvc = VCArrays[i];
        vvc.tabBarItem.title = titles[i];
        vvc.tabBarItem.selectedImage =[[UIImage imageNamed:normalImages[i]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vvc.tabBarItem.image = [[UIImage imageNamed:selectedImages[i]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [vvc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateSelected];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vvc];
        nav.navigationBarHidden = YES;
        [vcArr addObject:nav];
    }
    self.viewControllers = vcArr;

}
@end
