//
//  STMainVC.m
//  FindHelperOC
//
//  Created by 马伟恒 on 16/6/17.
//  Copyright © 2016年 马伟恒. All rights reserved.
//

#import "STMainVC.h"
#import "STClickView.h"
#import "CCMyTaskViewController.h"
#import "CCPLANSViewController.h"
#import "CCWQViewController.h"
#import "CCRecordViewController.h"
#import "STLocationUp.h"
#import "STCarDistanceVC.h"
#import "STTabbarVC.h"
#import "CCNoticeViewController.h"
#import "CCUtil.h"
#import "ASIHTTPRequest.h"

@interface STMainVC()
{
    NSDictionary * versonDic;//更新dic
    NSInteger timeInterval0;
}


@end
@implementation STMainVC

-(void)setUpLocationTraker{
    self.locationTracker = [[LocationTracker alloc]init];
    [self.locationTracker startLocationTracking];
    //设定向服务器发送位置信息的时间间隔
    //开启计时器
    if ([self.locationUpdateTimer isValid]) {
        [self.locationUpdateTimer invalidate];
    }
    [NSThread sleepForTimeInterval:3];
    [self performSelector:@selector(updateLocation) withObject:nil afterDelay:3];

    NSInteger now=timeInterval0*60;
    self.locationUpdateTimer =
    [NSTimer scheduledTimerWithTimeInterval:now
                                     target:self
                                   selector:@selector(updateLocation)
                                   userInfo:nil
                                    repeats:YES];
    
}
-(void)updateLocation {

    
    [self.locationTracker updateLocationToServer];
}
-(void)getSignInfo:(NSDictionary *)dic{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *final=[CCUtil basedString:KQ_Rule_Url withDic:dic];
        ASIHTTPRequest *Requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [Requset setRequestMethod:@"GET"];
        [Requset startSynchronous];
        NSData *responData=[Requset responseData];
        if (responData.length==0) {
            [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
            return;
        }
        NSDictionary *  responseArr=[[NSJSONSerialization JSONObjectWithData:responData options:NSJSONReadingMutableLeaves error:nil] objectForKey:@"data"];
        
        NSString *signDaysString = responseArr[@"days"];
        NSArray *   signDays = [signDaysString componentsSeparatedByString:@","];
        NSMutableArray *arr_replace = [NSMutableArray array];
        [signDays enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [arr_replace addObject:@(obj.integerValue)];
        }];
        signDays = arr_replace.copy;
        [[NSUserDefaults standardUserDefaults]setObject:signDays forKey:@"curSignDays"];
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"ruleDic"];
        [NSKeyedArchiver archiveRootObject:responseArr toFile:docDir];
    });
}
-(void)getSetting{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSString *final=[CCUtil basedString:accountUrl withDic:nil];
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [requset setTimeOutSeconds:20];
    [ requset setUseCookiePersistence : YES ];
    [requset setRequestMethod:@"GET"];
    [requset startSynchronous];
    NSData *Data=[requset responseData];
    if (Data.length==0) {
        [CCUtil showMBProgressHUDLabel:@"登录失败" detailLabelText:nil];
        return;
    }
    
        NSDictionary * jsonDic0=[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
        NSString *ecid = jsonDic0[@"ecId"];
        NSString *memberid =jsonDic0[@"memberId"];
        NSInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour;
          NSCalendar *calender=[NSCalendar currentCalendar];
        
       NSDateComponents*  comps=[calender components:unitFlags fromDate:[NSDate date]];
        
        NSInteger year=[comps year];
        NSInteger month=[comps month];
        NSString *yearMonth = [NSString stringWithFormat:@"%ld-%ld",(long)year,(long)month];
        if (month<10) {
            yearMonth = [NSString stringWithFormat:@"%ld-0%ld",(long)year,(long)month];
        }
        NSDictionary *setDic = @{@"ecId":ecid,@"memberId":memberid,@"yearMonth":yearMonth};
        NSString *final1=[CCUtil basedString:signSetting withDic:setDic];
        ASIHTTPRequest *Requset1=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [Requset1 setRequestMethod:@"GET"];
        [Requset1 startSynchronous];
        NSData *responData1=[Requset1 responseData];
        NSDictionary *jsonResult=[NSJSONSerialization JSONObjectWithData:responData1 options:NSJSONReadingMutableLeaves error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self->timeInterval0 = [jsonResult[@"signFrq"] integerValue];
            [self setUpLocationTraker];
        });
     });
}
-(void)viewDidLoad{
    [super viewDidLoad];
    self.lableNav.text = @"工作";
    
    [self checkUpDate];//检查更新
    //添加照片
    [self getSignInfo:nil];
    [self getSetting];//获取签到频率
   // [self setUpLocationTraker];
    UIImageView *igv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,kFullScreenSizeWidth, kFullScreenSizeHeght*0.4)];
    //igv.image = [UIImage imageNamed:@"wqt-main"];
    [self.view addSubview:igv];
    //切换ui

    //下面的按钮
    CGFloat height_All_left = kFullScreenSizeHeght-CGRectGetHeight(igv.frame)-CGRectGetHeight(self.tabBarController.tabBar.bounds);
    CGFloat image_height = height_All_left/3.0;
    NSArray *picNames = @[@"pic2",@"pic3",@"pic4",@"pic5",@"pic6",@"pic7",@"picNotice"];
    NSArray *titleArrays = @[@"我的任务",@"计划安排",@"外勤工作",@"签到签退",@"位置上报",@"行车里程",@"系统公告"];
    for (int i=0; i<7; ++i) {
        STClickView *clickView = [[STClickView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth/3.0*(i%3), CGRectGetMaxY(igv.frame)+(i/3)*image_height,kFullScreenSizeWidth/3.0,image_height) picName:picNames[i] labelText:titleArrays[i]];
        clickView.tag = 100+i;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushInto:)];
        tapGes.numberOfTouchesRequired = 1;
        tapGes.numberOfTapsRequired = 1;
        [clickView  addGestureRecognizer:tapGes];
        [self.view addSubview:clickView];
    }
    for (int i=1; i<3; ++i) {
        UIImageView *verLine = [[UIImageView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth/3.0*(i%3), CGRectGetMaxY(igv.frame)+(i/3)*image_height, 1, image_height*3)];
        [self.view addSubview:verLine];
        verLine.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    }
    for (int i=1; i<3; ++i) {
        UIImageView *verLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(igv.frame)+i*image_height, kFullScreenSizeWidth, 1)];
        [self.view addSubview:verLine];
        verLine.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    }
    
    
}
//检查更新
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
-(void)trueUser{
    self.view.userInteractionEnabled = YES;
}
//任务推送
-(void)pushInto:(UIGestureRecognizer *)rego{
    self.view.userInteractionEnabled = false;
    [self performSelector:@selector(trueUser) withObject:nil afterDelay:2];
    UIView *viewA = rego.view;
    NSInteger tagA = viewA.tag-100;
    switch (tagA) {
        case 0:
            // 任务
        {
            CCMyTaskViewController *mytask = [[CCMyTaskViewController alloc]init];
            mytask.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mytask animated:YES];
        }
            break;
        case 1:
        {//计划
            
            CCPLANSViewController *plan=[[CCPLANSViewController alloc]init];
            plan.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:plan animated:YES];
        }
            break;
        case 2:
        {//外勤
            CCWQViewController *wq = [[CCWQViewController alloc]init];
            wq.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:wq animated:YES];
        }
            break;
        case 3:
        {
            //签到前途
            CCRecordViewController *recore = [[CCRecordViewController alloc]init];
            recore.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:recore animated:YES];
        }
            break;
        case 4:
        {
            //地址
            STLocationUp *locaton  = [[STLocationUp alloc]init];
            locaton.hidesBottomBarWhenPushed  = YES;
            [self.navigationController pushViewController:locaton animated:YES];
        }
            break;
        case 5:
        {
            //  行车里程
            STCarDistanceVC *disc = [[STCarDistanceVC alloc]init];
            disc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:disc animated:YES];
        }
            break;
        case 6:
        {
            CCNoticeViewController *notice = [[CCNoticeViewController alloc]init];
            notice.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:notice animated:YES];
        }
            break;
        default:
            break;
    }
    
    
}
@end
