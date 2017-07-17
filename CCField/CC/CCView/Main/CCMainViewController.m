//
//  CCMainViewController.m
//  CCField
//
//  Created by 李付 on 14-10-9.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCWQViewController.h"
#import "CCPLANSViewController.h"
#import "CCMainViewController.h"
#import "CCNavigationController.h"
#import "CCMyTaskViewController.h"
#import "CCAccountViewController.h"
#import "CCLocationController.h"
#import "CCSettingViewController.h"
#import "CCNoticeViewController.h"
#import "CCRecordViewController.h"
#import "CCMessageViewController.h"
#import "CCLocationController.h"
//#import <MapKit/MKReverseGeocoder.h>
//#import <MapKit/MKPlacemark.h>
#import "CCUtil.h"
#import "CSDataService.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "CCWGS.h"
#import "CCAppDelegate.h"
//#import "ASIHTTPRequest.h"
#import "LocationTracker.h"
#import "Reachability.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <ImageIO/ImageIO.h>

@interface CCMainViewController ()<MAMapViewDelegate,AMapLocationManagerDelegate,AMapSearchDelegate>
{
    MAMapView *mapView;
    AMapLocationManager *locationService;
     CCAppDelegate *AppDele;
    NSDictionary  *versonDic;
//    BOOL ONCE;
    Reachability *hostReach;
    int currentTimeInterVal;
    AMapSearchAPI *_search;
}
@property(strong,nonatomic) CTCallCenter *callCenter;
@property (weak, nonatomic) IBOutlet UIImageView *Mytask;
@property (weak, nonatomic) IBOutlet UIImageView *account;
@property (weak, nonatomic) IBOutlet UIImageView *plan;
@property (weak, nonatomic) IBOutlet UIImageView *outside;
@property (weak, nonatomic) IBOutlet UIImageView *information;
@property (weak, nonatomic) IBOutlet UIImageView *check;
@property (weak, nonatomic) IBOutlet UIImageView *location;
@property (weak, nonatomic) IBOutlet UIImageView *setting;
@property (weak, nonatomic) IBOutlet UIImageView *Notice;
//@property(strong,nonatomic) BMKLocationService *locationService;
//
@property LocationTracker * locationTracker;
//
@end



@implementation CCMainViewController


-(void)setUpLocationTraker{
    NSTimeInterval time =currentTimeInterVal;
    NSTimeInterval now=[[defaults objectForKey:ISSTIMEINTERVAL]intValue];
    if (time==now&&self.locationTracker) {
        return;
    }
    
    if (!self.locationTracker) {
        self.locationTracker = [[LocationTracker alloc]init];
    }
    [self.locationTracker startLocationTracking];
    //设定向服务器发送位置信息的时间间隔
    //开启计时器
    if ([self.locationUpdateTimer isValid]) {
        [self.locationUpdateTimer invalidate];
    }
    [NSThread sleepForTimeInterval:5];
    now=MAX(now, 60);
    self.locationUpdateTimer =
    [NSTimer scheduledTimerWithTimeInterval:now
                                     target:self
                                   selector:@selector(updateLocation)
                                   userInfo:nil
                                    repeats:YES];
    
     }
-(void)updateLocation {
    
         //向服务器发送位置信息
         [self.locationTracker updateLocationToServer];
    }
-(void)reachabilityIsChanged:(NSNotification *)noti{
    Reachability *rech=[noti object];
    CCAppDelegate *app = (CCAppDelegate *)[UIApplication sharedApplication].delegate;
//    AppDele=(CCAppDelegate *)[UIApplication sharedApplication].delegate;
    NetworkStatus status=[rech currentReachabilityStatus];
    BOOL isNetworkReachable = YES;
    if (status==NotReachable) {
       isNetworkReachable = NO;
         [CCUtil showMBProgressHUDLabel:@"当前无网络"];
        
    }
    if (status==ReachableViaWiFi) {
        [CCUtil showMBProgressHUDLabel:@"当前网络为WIFI"];
        [app LOGIN];
    }
    if (status==ReachableViaWWAN) {
        //3g
        [CCUtil showMBProgressHUDLabel:@"您现在是通过非WiFi上网"];
        [app LOGIN];
    }
    
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    
    //通话检测
    _callCenter = [[CTCallCenter alloc]init];
    _callCenter.callEventHandler=^(CTCall *call){
        if ([call.callState isEqualToString:CTCallStateDisconnected]) {
            CCAppDelegate *app = (CCAppDelegate *)[UIApplication sharedApplication].delegate;
            [app LOGIN];
        }
    
    };
    //开启网络监测
//    
////
//    //
//    //      [defaults setObject:tempString forKey:@"tokenStr"];
////    ONCE=NO;
////    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
////    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
//    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self performSelector:@selector(checkUpDate) withObject:nil afterDelay:10];
    });


    [self CreateAdvertImage];

  self.ImageAnimatinTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(changeImageAni) userInfo:nil repeats:YES];
    
    /*
     *地图上报
     */
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap)];
    tapGesture.numberOfTapsRequired=1;
    [self.location addGestureRecognizer:tapGesture];
    
    //    /**
    //     *  我的任务
    //     */
    //    UITapGestureRecognizer *taskGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(MYTASK)];
    //    taskGesture.numberOfTapsRequired=1;
    //    [self.tasker addGestureRecognizer:tapGesture];
    /*
     *我得账户
     */
    UITapGestureRecognizer  *tapAccount=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(accountTap)];
    tapAccount.numberOfTapsRequired=1;
    [self.account addGestureRecognizer:tapAccount];
    
    /**
     *  我的计划
     */
    UITapGestureRecognizer *planGes=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(planAll)];
    planGes.numberOfTapsRequired=1;
    [self.plan addGestureRecognizer:planGes];
    
    /*
     *系统设置
     */
    UITapGestureRecognizer *settingGes=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(settingTap)];
    settingGes.numberOfTapsRequired=1;
    [self.setting addGestureRecognizer:settingGes];
    
    /*
     *通知公告
     */
    UITapGestureRecognizer *notice=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapNotice)];
    notice.numberOfTapsRequired=1;
    [self.Notice addGestureRecognizer:notice];
    /*
     *外勤工作
     */
    UITapGestureRecognizer *wqgz= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(wqgz)];
    wqgz.numberOfTapsRequired=1;
    [self.outside addGestureRecognizer:wqgz];
    
    /*
     *签到签退
     */
    UITapGestureRecognizer *qdqt= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(qdqt)];
    qdqt.numberOfTapsRequired=1;
    [self.check addGestureRecognizer:qdqt];
    
    //信息接收
    UITapGestureRecognizer *CCMessage=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(messageTap)];
    CCMessage.numberOfTapsRequired=1;
    [self.information addGestureRecognizer:CCMessage];
    
    //我的任务
    UITapGestureRecognizer *CCTask=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(taskTap)];
    CCTask.numberOfTapsRequired=1;
    [self.Mytask addGestureRecognizer:CCTask];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setUpLocationTraker) name:@"refreshTimer" object:nil];

    
    [self setUpLocationTraker];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityIsChanged:) name:kReachabilityChangedNotification object:nil];
    hostReach=[Reachability reachabilityWithHostName:@"https://www.baidu.com"];
    hostReach = [Reachability reachabilityForInternetConnection];
    [hostReach startNotifier];
}


#pragma mark -- update
-(void)checkUpDate{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIHTTPRequest *   requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:CheckVersionUrl]];
        [requset setRequestMethod:@"GET"];
        [requset startSynchronous];
        NSLog(@"%@",requset.responseString);
        if (requset.responseData.length==0) {
            return ;
        }
       
        dispatch_async(dispatch_get_main_queue(), ^{
            self->versonDic=[NSJSONSerialization JSONObjectWithData:requset.responseData options:NSJSONReadingMutableLeaves error:nil];
            [defaults setObject:self->versonDic forKey:@"updateDic"];
            NSDictionary *infoDIc=[[NSBundle mainBundle]infoDictionary];
            NSString *currentVersion=[infoDIc[@"CFBundleShortVersionString"] stringByReplacingOccurrencesOfString:@"." withString:@""];
            
            if ([[[self->versonDic valueForKey:@"updateVersion"]stringByReplacingOccurrencesOfString:@"." withString:@""]floatValue]<=[currentVersion floatValue])
            {
                
            }else
            {
                [defaults setBool:YES forKey:@"update"];
                NSString *strdec=self->versonDic[@"updateDesc"];
                strdec =[strdec stringByReplacingOccurrencesOfString:@";" withString:@"\n"];
                
                
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"版本更新" message:strdec delegate:self cancelButtonTitle:@"以后再说" otherButtonTitles:@"确定", nil];
                alert.tag=2020;
                [alert show];
            }
            
            
        });
        
    });
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==2020) {
        if (buttonIndex!=alertView.cancelButtonIndex) {
            //前往下载
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:versonDic[@"updateURL"]]];
        }
    }
    
}
#pragma mark==tap

-(void)taskTap{
    CCMyTaskViewController *task=[[CCMyTaskViewController alloc]init];
    [self.navigationController pushViewController:task animated:YES];
}


/**
 *  签到签退
 */
-(void)qdqt{
    CCRecordViewController *Recode=[[CCRecordViewController alloc]init];
    [self.navigationController pushViewController:Recode animated:YES];
    
}
/**
 *  外勤工作
 */
-(void)wqgz{
    CCWQViewController *wqgz=[[CCWQViewController alloc]init];
    [self.navigationController pushViewController:wqgz animated:YES];
}
/*
 *通知公告
 */
-(void)TapNotice{
    CCNoticeViewController *CCNotice=[[CCNoticeViewController alloc]init];
    [self.navigationController pushViewController:CCNotice animated:YES];
}

/**
 *我得账户
 */
-(void)accountTap{
    CCAccountViewController *CCaccount=[[CCAccountViewController alloc]init];
    [self.navigationController pushViewController:CCaccount animated:YES];
}

-(void)messageTap{
    CCMessageViewController *CCMess=[[CCMessageViewController alloc]init];
    [self.navigationController pushViewController:CCMess animated:YES];
}

/*
 *系统设置
 */
-(void)settingTap{
    CCSettingViewController *CCsetting=[[CCSettingViewController alloc]init];
    [self.navigationController pushViewController:CCsetting animated:YES];
}

-(void)handleTap{
    CCLocationController *CCLocation=[[CCLocationController alloc]init];
    [self.navigationController pushViewController:CCLocation animated:YES];
}

/**
 *  计划查看
 */
-(void)planAll{
    CCPLANSViewController *plan=[[CCPLANSViewController alloc]init];
    [self.navigationController pushViewController:plan animated:YES];
}
/**
 *  任务查看
 */
-(void)MYTASK{
    CCMyTaskViewController *task=[[CCMyTaskViewController alloc]init];
    [self.navigationController pushViewController:task animated:YES];
}
/*
 *创建广告
 */
-(void)CreateAdvertImage{
    
    _ADImageView=[[UIImageView alloc]initWithFrame:CGRectMake(5,22, 310, 113)];
    _ADImageView.image=[UIImage imageNamed:@"1.png"];
    _changeImageIndex=0;
    _advertArray=@[@"0.png",@"1.png",@"2.png"];
    _ADImageView.userInteractionEnabled=YES;
    
    _pageContol=[[UIPageControl alloc]initWithFrame:CGRectMake(200, 90,100, 30)];
    _pageContol.currentPage = 0;
    _pageContol.hidesForSinglePage = NO;
    [_ADImageView addSubview:_pageContol];
    
    [self.view addSubview:_ADImageView];
}

-(void) changeImageAni
{
    if (_changeImageIndex == 1)
        _changeImageIndex = -1;
    
    _changeImageIndex++;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.75;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    //NSString *types[4] = {kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade};
    
    //NSString *subtypes[4] = {kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom};
    NSString *subtypes = {kCATransitionFromLeft};
    transition.subtype=subtypes;
    
    // int rnd = random() % 4;
    
    // transition.type = types[rnd];
    
    //    if(rnd < 3)
    //    {
    //        transition.subtype = subtypes[random() % 4];
    //    }
    transition.delegate = self;
    [_ADImageView.layer addAnimation:transition forKey:nil];
    _ADImageView.image = [UIImage imageNamed:[_advertArray objectAtIndex:_changeImageIndex]];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.locationUpdateTimer invalidate];
}




@end
