//
//  CCUtil.m
//  CCField
//
//  Created by 马伟恒 on 14-10-13.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCUtil.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import <sys/sysctl.h>
#import "STTabbarVC.h"
#import "STMainVC.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import "CCAppDelegate.h"
@implementation CCUtil
+(NSString *)basedString:(NSString *)baseSting withDic:(NSDictionary *)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        dic=@{@"currentPage": @"1",@"pageSize":@"10"};
    }
    int AllCount=[dic allKeys].count;
    NSString *final=[NSString stringWithString:baseSting];
    for (int i=0; i<AllCount; i++) {
        NSString *biaoji=@"?";
        if (i>0) {
            biaoji=@"&";
        }
        NSString *key=[dic allKeys][i];
        NSString *value=[dic objectForKey:key];
        final=[final stringByAppendingFormat:@"%@%@=%@",biaoji,key,value];
    }
    return final;
}

 

+(NSString*)timeCurrte
{
    NSString *timeString=@"http://117.78.42.226:8081/outside/dispatcher/signmgr/getCurrentTime?";
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:timeString]];
    [requset setRequestMethod:@"GET"];
    [requset startSynchronous];
    NSData *Data=[requset responseData];
    if (Data.length==0) {
        [CCUtil showMBProgressHUDLabel:@"请检查网络" detailLabelText:nil];
        return @"";
    }
    NSDictionary *dicJson=[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
     NSString *Key=[dicJson valueForKey:@"message"];
    return Key;
}

+(NSString *)changeWithInt:(NSString *)strCode{
    NSString *string=@"进行中";
    if ([strCode isEqualToString:@"4"]) {
        string=@"超时完成";
    }
    if ([strCode isEqualToString:@"2"]) {
        string=@"进行中";
    }
    if ([strCode isEqualToString:@"3"]) {
        string=@"完成";
    }
    //    if ([strCode isEqualToString:@"0"]) {
    //        string=@"未完成";
    //    }
    if ([strCode isEqualToString:@"-1"]) {
        string=@"超时";
    }
    return string;
}

+(UIColor *)colorByStringCode:(NSString *)strCode{
    UIColor *color=[UIColor colorWithRed:80.0/255 green:170.0/255 blue:60.0/255 alpha:1];
    if ([strCode isEqualToString:@"未完成"])
    {
        color=[UIColor grayColor];
    }
    if ([strCode isEqualToString:@"超时"])
    {
        color=[UIColor redColor];
    }
    
    
    return color;
}
 
+(NSDate*) convertDateFromString:(NSString*)uiDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[formatter dateFromString:uiDate];
    return date;
}
+(NSString *)changeDateWithInterval:(NSTimeInterval)spaceTime{
    NSString *final=[NSString string];
    if (spaceTime<0) {
        final=[NSString stringWithFormat:@"距离签到还有00时00分00秒"];
        return final;
    }
    int h=spaceTime/3600;
    int m=(spaceTime-h*3600)/60;
    int s=spaceTime-h*3600-m*60;
    final=[NSString stringWithFormat:@"距离签到还有%d时%d分%d秒",h,m,s];
    return final;
    
}
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}
+(NSString *)currentStamp{
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter2 setTimeStyle:NSDateFormatterShortStyle];
    //[dateFormatter setDateFormat:@"hh:mm:ss"]
    [dateFormatter2 setDateFormat:@"SSS"];
    NSString *stamp = [dateFormatter2 stringFromDate:[NSDate date]];
    return stamp;
}

 
+(void)showMBProgressHUDLabel:(NSString *)labelText{
    UIWindow *app=[[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD*HUD = [[MBProgressHUD alloc] initWithView:app];
    [app addSubview:HUD];
    HUD.labelText = labelText;
    HUD.mode = MBProgressHUDModeText;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(2.0);
    } completionBlock:^{
        [HUD removeFromSuperview];
    }];
}

//显示一秒后消失
+(void)showMBProgressHUDLabel:(NSString *)labelText detailLabelText:(NSString *)detailsLabelText{
    
    UIWindow *app=[[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD*HUD = [[MBProgressHUD alloc] initWithView:app];
    dispatch_async(dispatch_get_main_queue(), ^{
        [app addSubview:HUD];
        HUD.labelText = labelText;
        HUD.detailsLabelText =detailsLabelText;
        HUD.userInteractionEnabled = false;
        HUD.mode = MBProgressHUDModeText;
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(1.0);
        } completionBlock:^{
            [HUD removeFromSuperview];
        }];
    });

}
NSInteger day;
NSString *startTime;
NSString *endTime;
NSString *startTime1;//第二次签到
NSString *endTime1;//第二次签退
NSDateFormatter *formatter;
+(BOOL)whetherCanUPload{
    //1.0
    NSArray *signDays = [[NSUserDefaults standardUserDefaults]objectForKey:@"curSignDays"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"ruleDic"];
    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:docDir];
    
    startTime=dic[@"time1"];
    
    
    if ([dic[@"signTimes"] intValue]==2) {
        endTime1 = dic[@"time2"];
    }
    else{
        endTime = dic[@"time2"];
        startTime1=dic[@"time3"];
        endTime1 = dic[@"time4"];
    }
    
    if (day==0) {
        NSDate *Date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:Date];
        day = [comps day];
        
    }
    if (![signDays containsObject:@(day)]) {
        return NO;
    }
    BOOL autoUP=[[NSUserDefaults standardUserDefaults]boolForKey:@"auto"];
    if (!autoUP) {
        return NO;
    }
    NSDate *date1=[NSDate date];
    NSInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour;
    
    NSDateComponents * comps=[[NSCalendar currentCalendar] components:unitFlags fromDate:date1];
    
    NSInteger year=[comps year];
    NSInteger month=[comps month];
    NSInteger day=[comps day];
    if (!formatter) {
        formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }

     if ([dic[@"signTimes"] intValue]==2) {
        startTime = [NSString stringWithFormat:@"%ld-%ld-%ld %@",(long)year,month,day,startTime];
        NSDate *startDate = [formatter dateFromString:startTime];
        endTime1 = [NSString stringWithFormat:@"%ld-%ld-%ld %@",(long)year,month,day,endTime1];
        NSDate *endDate = [formatter dateFromString:endTime1];
        if ([date1 timeIntervalSinceDate:startDate]<0) {
            return NO;
        }else if ([date1 timeIntervalSinceDate:endDate]>=0)
        {
            //下班之后,停止定位和计时器
            UINavigationController *nav =   (UINavigationController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
            if (![nav isKindOfClass:[UINavigationController class]]) {
                return NO;
            }
            CLLocationManager *ma = [LocationTracker sharedLocationManager];
            [ma stopUpdatingLocation];
            STTabbarVC *tab1 = nav.viewControllers[0];
            STMainVC *main = ((UINavigationController *)tab1.viewControllers[1]).viewControllers[0];
            main.locationTracker.shareModel.shouldStopTimer = YES;
            [main.locationTracker.shareModel.fiveMinutesTimer invalidate];
            [main.locationTracker.shareModel.delay10Seconds invalidate];
            [main.locationTracker.shareModel.timer invalidate];
            [main.locationTracker._locService stopUserLocationService];
            return NO;
        }
     }
    else{
        //四次比较，在上班时间内上传 startTime，endtime，starttime1,endtime1
        
        startTime = [NSString stringWithFormat:@"%ld-%ld-%ld %@",(long)year,month,day,startTime];
        NSDate *startDate = [formatter dateFromString:startTime];
        endTime = [NSString stringWithFormat:@"%ld-%ld-%ld %@",(long)year,month,day,endTime];
        NSDate *endDate = [formatter dateFromString:endTime];
        
        startTime1 = [NSString stringWithFormat:@"%ld-%ld-%ld %@",(long)year,month,day,startTime1];
        NSDate *startDate1 = [formatter dateFromString:startTime1];
        
         endTime1 = [NSString stringWithFormat:@"%ld-%ld-%ld %@",(long)year,month,day,endTime1];
        NSDate *endDate1 = [formatter dateFromString:endTime1];

        if ([date1 timeIntervalSinceDate:startDate]<0) {
            return NO;
        }
        else{
            //防止session过期请求失败，在下午上班之前，进行，
//             if ([date1 timeIntervalSinceDate:startDate1]<-300&&[date1 timeIntervalSinceDate:startDate1]>-400) {
//                 //在推送之前进行登录，不然进来就是失效的
//                 CCAppDelegate *app = (CCAppDelegate*)[UIApplication sharedApplication].delegate;
//                 [app LOGIN];
//             }
            
            if ([date1 timeIntervalSinceDate:endDate]>0&&[date1 timeIntervalSinceDate:startDate1]<0) {
                return NO;
            }
            if ([date1 timeIntervalSinceDate:endDate1]>=0) {
                //下班之后,停止定位和计时器
                UINavigationController *nav =   (UINavigationController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
                if (![nav isKindOfClass:[UINavigationController class]]) {
                    return NO;
                }
                CLLocationManager *ma = [LocationTracker sharedLocationManager];
                [ma stopUpdatingLocation];
                STTabbarVC *tab1 = nav.viewControllers[0];
                STMainVC *main = ((UINavigationController *)tab1.viewControllers[1]).viewControllers[0];
                main.locationTracker.shareModel.shouldStopTimer = YES;
                [main.locationTracker.shareModel.fiveMinutesTimer invalidate];
                [main.locationTracker.shareModel.delay10Seconds invalidate];
                [main.locationTracker.shareModel.timer invalidate];
                [main.locationTracker._locService stopUserLocationService];
                return NO;
            }
         }
      }
    return YES;
    
    //    NSString *nowTime=[formatter stringFromDate:date1];
    //    //判断月日 yyyy-MM-dd HH:mm
    //    NSString *startStr=[[NSUserDefaults standardUserDefaults]objectForKey:START_TINE];
    //    NSString *endStr=[[NSUserDefaults standardUserDefaults]objectForKey:END_TIME];
    //
    //
    //
    //    NSString *hour=[nowTime substringWithRange:NSMakeRange(8, 2)];
    //    NSLog(@"%@",hour);
    //    //星期几 和 时间
    
    //    NSCalendar *calender=[NSCalendar currentCalendar];
    //    NSDateComponents *comps;
    //    NSDate *date=[NSDate date];
    //    //星期几
    //    comps=[calender components:(NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit) fromDate:date];
    //    NSInteger weekday=[comps weekday];
    //    NSString *str=[NSString stringWithFormat:@"%d",weekday-1];
    //    switch ([str intValue]) {
    //        case 0:
    //            str=@"日";
    //            break;
    //        case 1:
    //            str=@"一";
    //            break;
    //        case 2:
    //            str=@"二";
    //            break;
    //        case 3:
    //            str=@"三";
    //            break;
    //        case 4:
    //            str=@"四";
    //            break;
    //        case 5:
    //            str=@"五";
    //            break;
    //        case 6:
    //            str=@"六";
    //            break;
    //        default:
    //            break;
    //    }
    //
    //
    //    NSString *weekDays=[[NSUserDefaults standardUserDefaults]objectForKey:UPLOAD_DAYS];
    //    if (weekDays.length==0) {
    //        weekDays=@"一,二,三,四,五,六,日";
    //    }
    //    if ([weekDays rangeOfString:str].location==NSNotFound) {
    //        return NO;
    //    }
    //
    //
    //
    //    NSString *strstart=startStr.length>1?[startStr substringWithRange:NSMakeRange(0, 2)]:@"0";
    //    NSString *strEnd=[endStr hasPrefix:@"99"]?@"99":[endStr substringWithRange:NSMakeRange(0, 2)];
    //    if ([hour intValue]<[strstart intValue]) {
    //        return NO;
    //    }
    //    if ([hour intValue]>[strEnd intValue]) {
    //        return NO;
    //    }
    //    //min
    //    NSString *startStrMIN=startStr.length>1?[startStr substringWithRange:NSMakeRange(3, 2)]:@"0";
    //    NSString *endStrMin=[endStr hasPrefix:@"99"]?@"99":[endStr substringWithRange:NSMakeRange(3, 2)];
    //    NSString *nowMIn=[nowTime substringWithRange:NSMakeRange(10, 2)];
    //    if ([nowMIn intValue]+60*[hour intValue]<[startStrMIN intValue]+60*[strstart intValue]) {
    //        return NO;
    //    }
    //    if ([nowMIn intValue]+60*[hour intValue]>[endStrMin intValue]+60*[strEnd intValue]) {
    //        return NO;
    //    }
    //    return YES;
}
//开启加载框
+(void)showMBLoading:(NSString *)mainTitle detailText:(NSString *)detailTitle{
    //加载框
    UIWindow *app=[[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *bd=[[MBProgressHUD alloc]initWithView:app];
    [app addSubview:bd];
    [app bringSubviewToFront:bd];
    bd.tag=123456;
    bd.dimBackground=NO;
    bd.detailsLabelText=detailTitle;
    [bd show:YES];
}
//隐藏加载框
+(void)hideMBLoading{
    //去掉加载框
    UIWindow *app=[[UIApplication sharedApplication] keyWindow];
    MBProgressHUD *bd=(MBProgressHUD *)[app viewWithTag:123456];
    [bd removeFromSuperview];
    bd=nil;
    for (UIView *sub in app.subviews) {
        if ([sub isKindOfClass:[MBProgressHUD class]]) {
            [sub removeFromSuperview];
        }
    }
}
+ (BOOL)isContainsEmoji:(NSString *)string {
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    isEomji = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                isEomji = YES;
            }
        } else {
            if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                isEomji = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                isEomji = YES;             } else if (0x2934 <= hs && hs <= 0x2935) {                 isEomji = YES;             } else if (0x3297 <= hs && hs <= 0x3299) {                 isEomji = YES;             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {                 isEomji = YES;             }         }     }];    return isEomji;
}

//获取设备型号

+ (NSString *)getCurrentDeviceModel:(UIViewController *)controller
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6S";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6S Plus";
    
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}
//signStatus：0-正常 2-缺勤 3-迟到 4-早退
+(NSString *)getStringWithStatus:(NSString *)status{
    if ([status isKindOfClass:[NSNull class]]) {
        return @"缺勤";
    }
    if ([status isKindOfClass:[NSString class]]) {
        return status;
    }
    NSString *sign_Str=nil;
    NSString *flag =nil;
    if ([status isKindOfClass:[NSDictionary class]]) {
        flag =((NSDictionary *)status)[@"confirmFlag"];
        status = ((NSDictionary *)status)[@"signStatus"];
    }
    NSDictionary *dic=@{@"0":@"审核中",@"1":@"通过",@"2":@"拒绝"};
    switch ([status intValue]) {
        case 0:
            sign_Str=@"正常";
            break;
        case 1:
            sign_Str=@"异常";
            break;
        case 2:
            sign_Str=@"缺勤";
            break;
        case 3:
            sign_Str=@"迟到";
            break;
        case 4:
            sign_Str=@"早退";
            break;
        default:
            break;
    }
    if (![flag isKindOfClass:[NSNull class]]) {
        sign_Str = dic[flag];
    }
    return sign_Str;
}
+(UIColor *)getColorFromStatus:(NSString *)status{
    if ([status isKindOfClass:[NSNull class]]) {
        return [UIColor redColor];
    }
    NSArray *redArray=@[@"缺勤",@"迟到",@"早退"];
    if ([redArray containsObject:status]) {
        return [UIColor redColor];
    }
    return [UIColor blackColor];
    
    
    if ([status isKindOfClass:[NSString class]]) {
        return [UIColor blackColor];
    }
    UIColor *color = nil;
    NSString *flag =nil;
    
    if ([status isKindOfClass:[NSDictionary class]]) {
        //根据status int值区分
        flag =((NSDictionary *)status)[@"confirmFlag"];
        
        status = ((NSDictionary *)status)[@"signStatus"];
    }
    
    switch ([status intValue]) {
        case 0:
            color=[UIColor blackColor];
            break;
        case 1:
            color=[UIColor redColor];
            break;
        case 2:
            color=[UIColor redColor];
            break;
        case 3:
            color=[UIColor redColor];
            break;
        case 4:
            color=[UIColor redColor];
            break;
            
        default:
            break;
    }
    return color;
}
+(void)shakeAnimationForView:(UIView *)view{
    CALayer*viewLayer=[view layer];
    CABasicAnimation*animation=[CABasicAnimation
                                
                                animationWithKeyPath:@"transform"];
    animation.duration=0.02;
    animation.repeatCount = 10;
    animation.autoreverses=YES;
    animation.fromValue=[NSValue valueWithCATransform3D:CATransform3DRotate
                         
                         (viewLayer.transform, -0.03, 0.0, 0.0, 0.03)];
    animation.toValue=[NSValue valueWithCATransform3D:CATransform3DRotate
                       
                       (viewLayer.transform, 0.03, 0.0, 0.0, 0.03)];
    [viewLayer addAnimation:animation forKey:@"wiggle"];
    
}
+(BOOL)whetherUsefulCoordinate:(CLLocationCoordinate2D)point{
    CLLocationDegrees lat = point.latitude;
    CLLocationDegrees lng = point.longitude;
    if (lng>140||lng<73) {
        return NO;
    }
    if (lat<3||lat>54) {
        return NO;
    }
    return YES;
}
+(UIImage *)getLogoFrom:(NSString *)stirng{
    
    NSString *firstLetter = nil;
    if (stirng.length<3) {
        firstLetter = stirng;
    }
    else{
        firstLetter = [stirng substringFromIndex:stirng.length-2];
        }
    CGRect rect = CGRectMake(0, 0, 80, 80);
    UIGraphicsBeginImageContext(rect.size);
    //获取图片
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ref, 1.0);
    CGContextSetRGBFillColor(ref, 122/255.0, 170/255.0, 216.0/255, 1);
    CGContextFillRect(ref, rect);
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    
    style.alignment = NSTextAlignmentCenter;
    
    //文字的属性
    
    NSDictionary *dic = @{
                          
                          NSFontAttributeName:[UIFont systemFontOfSize:25],
                          
                          NSParagraphStyleAttributeName:style,
                          
                          NSForegroundColorAttributeName:[UIColor whiteColor]
                          
                          };

    
    [firstLetter drawInRect:CGRectMake(7, 22, 60, 30) withAttributes:dic];
    UIImage *igv = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return igv;
}
@end
