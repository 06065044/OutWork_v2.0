//
//  CCAppDelegate.h
//  CCField
//
//  Created by 李付 on 14-10-8.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
@interface CCAppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,strong) UIViewController *currentVC;
-(BOOL)LOGIN;
-(void)gotoMainView;

@end
