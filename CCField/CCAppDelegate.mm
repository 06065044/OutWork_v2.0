//
//  CCAppDelegate.m
//  CCField
//
//  Created by 李付 on 14-10-8.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCAppDelegate.h"
#import "CCStartViewController.h"
//#import "CCMainViewController.h"
//#import "CCNavigationController.h"
#import "CCLoginViewController.h"
#import "JPUSHService.h"
#import "SAMKeychain.h"
#import "CCMyTaskViewController.h"
#import "CCNoticeViewController.h"
#import "CCPLANSViewController.h"
#import "MessageVC.h"
#import "NSString+MD5Addition.h"
#import "CCUtil.h"
#import "LocationTracker.h"
#import "Reachability.h"
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import "STTabbarVC.h"
#import "IQKeyboardManager.h"
#import "CCRecordViewController.h"
#import <UMMobClick/MobClick.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
const void *key="keyValue";

static NSString *appKey = @"43071963b4f0a26172221d3d";//develop：24d0c67b09605e1b1baa41cf//product：43071963b4f0a26172221d3d
static NSString *channel = @"https://fir.im/wbah";

@interface CCAppDelegate()<CLLocationManagerDelegate>{
    CLLocationManager *_locationmanager;
    BMKMapManager *_mapManager;
    Reachability *hostReach;
    int currentTimeInterVal;
}
@property LocationTracker * locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;
@end
@implementation CCAppDelegate
void UncaughtExceptionHandler(NSException *exception) {
    /**
     *  获取异常崩溃信息
     */
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *content = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[callStack componentsJoinedByString:@"\n"]];
    
    /**
     *  把异常崩溃信息发送至开发者邮件
     */
    NSMutableString *mailUrl = [NSMutableString string];
    [mailUrl appendString:@"mailto:356071172@qq.com"];
    [mailUrl appendString:@"?subject=程序异常崩溃，请配合发送异常报告，谢谢合作！"];
    [mailUrl appendFormat:@"&body=%@", content];
    // 打开地址
    NSString *mailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];
}
- (void)umengTrack {
    //    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    [MobClick setLogEnabled:YES];
    UMConfigInstance.appKey = UMeng_Key;
    UMConfigInstance.secret = @"App Store";
    //    UMConfigInstance.eSType = E_UM_GAME;
    [MobClick startWithConfigure:UMConfigInstance];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self umengTrack];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self.window makeKeyAndVisible];
 
    
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    //百度地图初始化key值
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:BaiDu_KEY  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    [IQKeyboardManager sharedManager].enable = true;
    //极光推送
    

    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
        
        [UIApplication sharedApplication].idleTimerDisabled = TRUE;
        
        _locationmanager = [[CLLocationManager alloc] init];
        [_locationmanager requestAlwaysAuthorization];        //NSLocationAlwaysUsageDescription
//        [_locationmanager requestWhenInUseAuthorization];     //NSLocationWhenInUseDescription
        _locationmanager.delegate = self;
        
    } else {
        
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    //JAppKey : 是你在极光推送申请下来的appKey Jchannel : 可以直接设置默认值即可 Publish channel
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel apsForProduction:YES]; //如果是生产环境应该设置为YES
    [defaults removeObjectForKey:@"updatedate"];
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"hasSet"])

        [defaults setBool:YES forKey:@"auto"];

    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"isFirstLoad"]) { //初次登录
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isFirstLoad"];
        [self showIntro];
    }else
    {
        
        if (![[NSUserDefaults standardUserDefaults]boolForKey:@"clickOut"]) {
            CCLoginViewController *CCMain=[[CCLoginViewController alloc]init];
            self.currentVC=CCMain;
            self.window.rootViewController=CCMain;
        }
        else{
            BOOL goon=[self LOGIN];
            if (!goon) {
                CCLoginViewController *CCMain=[[CCLoginViewController alloc]init];
                self.currentVC=CCMain;
                self.window.rootViewController=CCMain;
                
            }
            else{
                
                //push
                NSDictionary *remoteInfo=[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
                
                NSString *msgType=remoteInfo[@"msgType"];
                [self gotoMainView];
                UINavigationController *nav=(UINavigationController *)self.window.rootViewController;
                if ([msgType isEqualToString:@"1"]) {
                    CCMyTaskViewController *my=[[CCMyTaskViewController alloc]init];
                    [nav pushViewController:my animated:YES];
                }
                if ([msgType isEqualToString:@"2"]||[msgType isEqualToString:@"6"]) {
                    STTabbarVC *tab = (STTabbarVC*)[nav topViewController];
                    tab.selectedIndex = 0;
                }
               
                if ([msgType isEqualToString:@"3"]) {
                    CCNoticeViewController *noti=[[CCNoticeViewController alloc]init];
                    [nav pushViewController:noti animated:YES];
                }
                if ([msgType isEqualToString:@"4"]) {
                    CCPLANSViewController *plan=[[CCPLANSViewController alloc]init];
                    [nav pushViewController:plan animated:YES];
          
                }
                if ([msgType isEqualToString:@"5"]) {
                    CCRecordViewController *plan=[[CCRecordViewController alloc]init];
                    [nav pushViewController:plan animated:YES];
                }
              }
        }
    }
    
    
    return YES;
}
-(void)showIntro{
    //    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, kFullScreenSizeHeght)];
    //    NSMutableArray *images = [NSMutableArray new];
    //
    //    [images addObject:[UIImage imageNamed:@"i5qidong1"]];
    //    [images addObject:[UIImage imageNamed:@"i5qidong2"]];
    //    [images addObject:[UIImage imageNamed:@"i5qidong3"]];
    //    for (int i=0; i<images.count; ++i) {
    //        UIImageView *igv = [[UIImageView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth*i, 0, kFullScreenSizeWidth, kFullScreenSizeHeght)];
    //        igv.image = images[i];
    //        [scroll addSubview:igv];
    //        if (i==2) {
    //            igv.userInteractionEnabled = true;
    //            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
    //            tap.numberOfTapsRequired = 1;
    //            tap.numberOfTouchesRequired =1;
    //            [igv addGestureRecognizer:tap];
    //        }
    //    }
    //    scroll.tag =101;
    
    [[UIApplication sharedApplication]keyWindow].rootViewController = [[CCStartViewController alloc]init];
    //     [[[UIApplication sharedApplication]keyWindow] addSubview:scroll];
}
-(void)hide{
    [[[[UIApplication sharedApplication]keyWindow] viewWithTag:101]removeFromSuperview];
    CCLoginViewController *CCMain=[[CCLoginViewController alloc]init];
    
    self.currentVC=CCMain;
    self.window.rootViewController=CCMain;
    [self.window makeKeyAndVisible];
}
#pragma mark == denglu
-(void)gotoMainView{
    STTabbarVC *tab = [[STTabbarVC alloc]init];
    tab.selectedIndex=1;
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:tab];
    self.currentVC = nav;
    nav.navigationBarHidden = YES;
    self.window.rootViewController = nav;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
        [CCUtil showMBLoading:nil detailText:[@"" stringByAppendingString:[error localizedDescription]]];
}
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    
    NSString *token=[NSString stringWithFormat:@"%@",deviceToken];
    NSMutableString *tokenAfterSub = [NSMutableString stringWithString:[token substringWithRange:NSMakeRange(1, [token length]-2)]];
    NSString *string2 = @" ";
    NSArray *tempArr = [tokenAfterSub componentsSeparatedByString:string2];
    NSMutableString *tempString = [NSMutableString stringWithCapacity:0];
    
    for(int i = 0;i<tempArr.count;i++)
    {
        [tempString appendString:[tempArr objectAtIndex:i]];
    }
    [defaults setObject:tempString forKey:@"tokenStr"];
    NSLog(@"-=-=-=%@",tempString);
    
    [JPUSHService registerDeviceToken:deviceToken];
}





/**
 IOS6必须实现的方法
 */
//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//    
//    
//    if (application.applicationState!=UIApplicationStateActive) {
//        return;
//    }
//    UINavigationController *nav =   (UINavigationController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
//    UIViewController *  la = nav.presentedViewController;
//    if (la) {
//        [nav dismissViewControllerAnimated:YES completion:nil];
//    }
//
//    NSString *message = userInfo[@"aps"][@"alert"][@"body"];
//    
//    NSString *showMsg = [message respondsToSelector:@selector(substringWithRange:)]?message:@"查看详细内容";
// 
//    UIAlertView *
//    alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"][@"title"] message:showMsg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    objc_setAssociatedObject(alert, key, userInfo, OBJC_ASSOCIATION_RETAIN);
//     [alert show];
//    
//    [JPUSHService handleRemoteNotification:userInfo];
//    
//}

/**
 IOS7以及上必须实现的方法
 */
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [JPUSHService handleRemoteNotification:userInfo];
    
    if ([userInfo[@"aps"][@"alert"] isKindOfClass:[NSString class]]) {
         [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"您收到了推送"];
        return;
    }
    
    if (application.applicationState!=UIApplicationStateActive) {
        return;
    }
    UINavigationController *nav =   (UINavigationController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
    UIViewController *  la = nav.presentedViewController;
        if (la) {
        [nav dismissViewControllerAnimated:YES completion:nil];
    }
    
    NSString *message = userInfo[@"aps"][@"alert"][@"body"];
    
    NSString *showMsg = [message respondsToSelector:@selector(substringWithRange:)]?message:@"查看详细内容";
    
    UIAlertView *
    alert=[[UIAlertView alloc]initWithTitle:userInfo[@"aps"][@"alert"][@"title"] message:showMsg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    objc_setAssociatedObject(alert, key, userInfo, OBJC_ASSOCIATION_RETAIN);
    [alert show];
    
    [JPUSHService handleRemoteNotification:userInfo];
    

    completionHandler(UIBackgroundFetchResultNewData);
}
/**
 *  进入程序的时候把badgenumber设置为0
 *
 *  @param application
 */
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [JPUSHService setBadge:0];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //    if ([[[UIApplication sharedApplication]keyWindow].rootViewController isKindOfClass:[CCLoginViewController class]]) {
    //        return;
    //    }
    //    [self LOGIN];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark == 点击确定跳转
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex!=alertView.cancelButtonIndex) {
        NSDictionary *remoteInfo=objc_getAssociatedObject(alertView, key);
        NSString *msgType=remoteInfo[@"msgType"];
        UINavigationController *nav =(UINavigationController *) self.currentVC;
        if ([msgType isEqualToString:@"1"]) {
            CCMyTaskViewController *my=[[CCMyTaskViewController alloc]init];
            [nav pushViewController:my animated:YES];
        }
        if ([msgType isEqualToString:@"2"]||[msgType isEqualToString:@"6"]) {
            STTabbarVC *tab = (STTabbarVC*)[nav viewControllers][0];
             tab.selectedIndex = 0;
        }
        
        if ([msgType isEqualToString:@"3"]) {
            CCNoticeViewController *noti=[[CCNoticeViewController alloc]init];
            [nav pushViewController:noti animated:YES];
        }
        if ([msgType isEqualToString:@"4"]) {
            CCPLANSViewController *plan=[[CCPLANSViewController alloc]init];
            [nav pushViewController:plan animated:YES];
        }
        if ([msgType isEqualToString:@"5"]) {
            CCRecordViewController *plan=[[CCRecordViewController alloc]init];
            [nav pushViewController:plan animated:YES];
        }

    }
    
}
#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif
-(BOOL)LOGIN{
    BOOL login=YES;
    NSString *UUidstr=[SAMKeychain passwordForService:@"com.ccfield.isoftstone" account:@"user"];
    if (UUidstr.length==0) {
        //新建一个
        CFUUIDRef uuidRef=CFUUIDCreate(kCFAllocatorDefault);
        UUidstr=(NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
        [SAMKeychain setPassword:UUidstr forService:@"com.ccfield.isoftstone" account:@"user"];
    }
    NSString *pas=[defaults objectForKey:PASS_WORD];
    //测试版
      // NSDictionary *dic=@{@"memberCode":[defaults objectForKey:USER_NAME],@"passWord":[pas stringFromMD5mima],@"mobileFlag":UUidstr};
    //正式版 [defaults objectForKey:USER_NAME]
     NSDictionary *dic=@{@"userName":[defaults objectForKey:USER_NAME],@"userPass":[pas stringFromMD5mima],@"mobileFlag":UUidstr};
    NSString *final=[CCUtil basedString:loginUrl withDic:dic];
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [ requset setUseCookiePersistence : YES ];
    [requset setTimeOutSeconds:20];
    [requset setShouldAttemptPersistentConnection:NO];
    [requset setRequestMethod:@"GET"];
    [requset startSynchronous];
    NSData *Data=[requset responseData];
 
     if ([Data length]<50||[requset.responseString rangeOfString:@"false"].location!=NSNotFound) {
        login=NO;
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
        if (Data.length<50) {
            [self performSelector:@selector(showFail) withObject:nil afterDelay:3];
        }
        else{
            NSDictionary *  jsonDic=[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
            [CCUtil showMBProgressHUDLabel:jsonDic[@"message"] detailLabelText:nil];
            
        }
    }
    return login;
}

-(void)showFail{
    [CCUtil showMBProgressHUDLabel:@"登录失败" detailLabelText:@"请重新登录"];
    
}
@end
