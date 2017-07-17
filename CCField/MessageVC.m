//
//  MessageVC.m
//  FindHelperOC
//
//  Created by 马伟恒 on 16/6/17.
//  Copyright © 2016年 马伟恒. All rights reserved.
//

#import "MessageVC.h"
#import "CCMessageViewController.h"
 #import "STBaseControl.h"
@implementation MessageVC
UIView *_contentView;
UIViewController *_currentVC;
CCMessageViewController *message;
 -(void)viewDidLoad{
    [super viewDidLoad];
    [self.buttonNav removeFromSuperview];
    self.view.backgroundColor = [UIColor clearColor];
//    STBaseControl *seg = [[STBaseControl alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, 30) dataSource:@[@"我的消息",@"系统公告"] touchHandler:^(NSInteger index) {
//        [self changeView:index];
//    }];
//   
    
//     [self.view addSubview:seg];
    self.lableNav.text = @"我的消息";
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame),kFullScreenSizeWidth, kFullScreenSizeHeght-64)];
    [self.view addSubview:_contentView];
     message = [[CCMessageViewController alloc]init];
    [self addChildViewController:message];
 
    
    [self fitFrameForChildViewController:message];
    [message didMoveToParentViewController:self];
    [_contentView addSubview:message.view];
    _currentVC = message;
    self.lableNav.text  = @"我的消息";
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick event:@"radio_message"];
}
- (void)fitFrameForChildViewController:(UIViewController *)chileViewController{
    CGRect frame = _contentView.frame;
    frame.origin.y=0;
    chileViewController.view.frame = frame;
}
//转换子视图控制器
- (void)transitionFromOldViewController:(UIViewController *)oldViewController toNewViewController:(UIViewController *)newViewController{
    [self transitionFromViewController:oldViewController toViewController:newViewController duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newViewController didMoveToParentViewController:self];
      
            _currentVC = newViewController;
        }else{
            _currentVC = oldViewController;
        }
    }];
}
- (void)removeAllChildViewControllers{
    for (UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
}
-(void)changeView:(NSInteger)seg{
 
//    if ( seg==0) {
//        //我的消息
//        if (_currentVC == message) {
//            return;
//        }
//           self.lableNav.text  = @"我的消息";
//        [self fitFrameForChildViewController:message];
//        [self transitionFromOldViewController:_currentVC toNewViewController:message];
//        
//    }
//    if (seg  == 1) {
//        //系统公告
//        if (_currentVC == notice) {
//            return;
//        }
//           self.lableNav.text  = @"系统公告";
//        [self fitFrameForChildViewController:notice];
//        [self transitionFromOldViewController:_currentVC toNewViewController:notice];
//    }
}
- (void)didReceiveMemoryWarning {
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
    if (!self.view.window&&self.isViewLoaded) {
        for (UIView *subView in self.view.subviews) {
            [subView removeFromSuperview];
        }
        self.view = nil;
        
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
 }
@end
